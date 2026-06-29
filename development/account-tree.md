# Account Tree

How Arweave stores the account tree in memory: the relationship between the
*account tree*, the *patricia tree*, the *diff DAG*, the *sink*, *diffs*, and the
previous / following / uncle reconstruction.

---

## Cast of characters

### Concepts


| Concept           | What it is                                                                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **account tree**  | a block's full state — the mapping `address → {balance, last_tx, denomination, mining_permission}`. One per block                                                         |
| **patricia tree** | the radix-trie structure that implements one account tree (shared-prefix paths, content-hashed nodes); **its** root hash is the block's `wallet_list`                                                        |
| **sink**          | the **current account tree** — the one representation stored as a full tree, resting at the chain tip. Every other (older) tree exists only as a *diff* against it. It moves **forward** as new blocks extend the tip (`set_current`), and **backward** to hash a block on a competing fork, serve a historical `get_chunk`, or reach the fork point during a reorg — see Layer 4                                                       |
| **diff**          | the **edge between two consecutive blocks** — a map `{address → new value \| remove}` of the accounts that changed from one to the next (forward, older → newer)                                                             |
| **diff DAG**      | the **whole graph** of block states wired together by *diff* edges — spanning the blocks the node still keeps (a recent window up to the current tip, pruned; **not** back to genesis), plus any forks it stores. One node is kept as a full tree (the *sink*); every other exists only as the diffs along the path to it, so all are reachable from that one copy |
| **parent / child** | adjacent blocks: a child block extends its parent |
| **sibling** | two blocks with the same parent — a fork |
| **ancestor / descendant** | a block reachable by following parents (ancestor) or children (descendant) |
| **uncle** | a sibling of an ancestor — a block on a competing fork (e.g. `B1'` is `B2`'s uncle: the sibling of `B2`'s parent `B1`) |


### Modules


| Module                     | Role                                                                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **`ar_account_tree`**      | gen_server **manager** of the **account tree** — the single, serialized point of access. Owns the ETS table (the **sink**) and the **diff DAG**, and drives every operation on it: moving the sink, applying / reversing **diffs**, and persisting         |
| **`ar_patricia_tree_ets`** | the ETS **patricia tree** that backs the **sink**: a single mutable ETS table holding one full tree, mutated in place to represent whichever block's tree the sink currently points at             |
| **`ar_patricia_tree`**     | the immutable map-based **patricia tree**, used where a standalone tree is needed (genesis, peer download, JSON serialization, disk reads) |
| **`ar_diff_dag`**          | the **diff DAG**: stores the **diffs** as edge labels and the **sink** pointer (the `Sink` element)                             |


> **"wallet" naming:** `ar_wallet` (keypair / address / signing utilities) is *upstream* of all this — it mints the addresses that key the account tree, then steps out; it isn't one of the data structures here. `B#block.wallet_list` is the legacy field name for the account-tree **root hash**.

### Why a patricia trie?

The account tree is re-hashed **every block**, but a block changes only a handful of accounts out of potentially millions. A patricia trie gives two properties that matter, at once:

**1. Local updates.** An account's position is fixed by its address bytes, so
insert / update / delete touches exactly one root-to-leaf path. `insert` marks
those nodes `no_hash` (dirty) and `compute_hash` reuses every still-cached hash,
so re-hashing walks only the dirtied paths — cost ∝ accounts-changed, not tree
size.

**2. Canonical root.** Every node must derive the identical root for the same
account set, regardless of the order updates arrived in. A patricia trie is
canonical by construction — its shape is a pure function of the keys present
(`order_independence_test_` pins this down).

**The naive alternative — a sorted-leaf Merkle tree — gives (2) but not (1).**
Sort the accounts by id and hash them up a balanced binary tree. The sort is
deterministic, so the root is canonical — but the leaves are *positional*:
inserting a new account (which happens constantly) shifts every later leaf and
forces an `O(n)` re-hash, every block.

```
patricia:        insert addr 0x4F…  → dirty 1 path  → re-hash O(depth)
sorted-leaf MT:  insert addr 0x4F…  → shifts all leaves > 0x4F…
                                     → re-hash O(n)   ← every block
```

**Not height-balanced — and that's fine.** A patricia trie isn't kept balanced;
its depth just follows the keys. Two reasons that doesn't hurt:

- **Depth is capped by the key length, not `n`.** Addresses are 32 bytes and the
  trie branches one byte at a time, so any root-to-leaf path crosses at most 32
  branch nodes (each consumes a distinct, deeper byte). Even a maximally lopsided
  trie makes an update `O(32)` — a constant in `n`. No set of keys turns a
  patricia update into an `O(n)` operation; that failure mode doesn't exist. (The
  sorted-leaf tree's `O(n)` isn't a worst case — it's what *every* insert costs.)
- **In practice it's far shallower than that.** Addresses are hashes of public
  keys → ~uniformly distributed, so the trie is balanced in expectation:
  ≈ `log256(n)`, about 3 bytes deep for millions of accounts.

So a patricia trie is the structure that is *both* canonical *and* locally
updatable — and the diff-DAG scheme depends on that locality: a diff that
reshuffled the tree would make "one tree + small diffs" cost a full rebuild.

---

## Worked example

Used throughout below — two things to know when reading it:

- **`B0`, `B1`, `B1'`, `B2` are blocks.** The chain forks after `B0`: `B1` and
  `B1'` are siblings, and `B2` extends `B1` (the tip).
- **`a`, `b`, `c` are accounts.** Each is really a 4-tuple
  `{balance, last_tx, denomination, mining_permission}`, but the diagram shows
  **only the balance** for readability — so `a:5` means "account `a` has
  balance 5".

```
        B0  {a:10, b:20}
       /  \
     B1'   B1   {a:5,  b:25}
   {a:7,    \
    b:20,    B2  {a:8, b:22}   ◄── tip
    c:3}
```

---

## Layer 1 — "account tree" is the concept; "patricia tree" is the structure

`B0`'s account tree is logically just a map from each account's **address** to
its value:

```
a → {balance:10, …}
b → {balance:20, …}
```

It's *stored* as a patricia (radix) trie keyed by that address (a 32-byte hash).
Accounts whose addresses share leading bytes share a path; each node hashes its
contents; the hashes bubble up to the root — the block's `wallet_list`:

```
                (root) #h0
                   │
        a, b share a leading prefix
                   │   (one compressed edge)
                (inner) #h1
               /          \
           leaf a        leaf b
          {bal,…} #ha    {bal,…} #hb

   root hash #h0  ==  B0's wallet_list   (the consensus value)
```

The whole trie lives in one mutable ETS table (`ar_patricia_tree_ets`) or one
immutable map (`ar_patricia_tree`).

---

## Layer 2 — many blocks, but the trees barely differ

Each of B0, B1, B1', B2 has its own account tree — but B0→B1 only touched a and
b. Keeping four nearly-identical full tries is mostly wasted memory:

```
   B0 trie     B1 trie     B1' trie    B2 trie
    ▣▣▣         ▣▣▣          ▣▣▣         ▣▣▣      ← 99% duplicated
```

The whole design exists to collapse that into **one** trie plus tiny diffs.

---

## Layer 3 — the diff DAG: one full tree (the "sink") + diffs on the edges

```
   ar_diff_dag  (lives in the gen_server State)
   ┌──────────────────────────────────────────────────┐
   │                                                    │
   │      B0 ───diff{a,b}─── B1                         │
   │      │                   │                         │
   │  diff{a,c}           diff{a,b}                     │
   │      │                   │                         │
   │     B1'                  B2  ◄═══ SINK             │
   │   (virtual)          (fully stored: the ONE        │
   │                       real ETS trie)               │
   └──────────────────────────────────────────────────┘
```

- Each **DAG node** is a block's account-tree representation, identified by its
root hash (`B#block.wallet_list`).
- Only the **sink** (B2) is a real, full patricia trie (the ETS
table). Every other node is *virtual* — it exists only as a diff relative to a
neighbour.
- An **edge diff** is small: `diff(B0→B1) = {a: 10→5, b: 20→25}`. That's it —
two accounts.

So instead of 4 tries, the node stores: 1 trie (B2) + 3 little diffs.

---

## Layer 4 — "reconstructing" another representation = walk edges, apply/reverse diffs

The sink can be *moved* to any DAG node by walking the path and mutating the one
trie. Reading **B0** while the sink is at B2 — reverse each diff as you climb:

```
 sink = B2:  {a:8,  b:22}
   reverse diff(B1→B2) {a:5→8,  b:25→22}  ──►  {a:5,  b:25}   (== B1)
   reverse diff(B0→B1) {a:10→5, b:20→25}  ──►  {a:10, b:20}   (== B0)
 sink now holds B0 in full  ✓
```

Reaching the **uncle** B1' — reverse to the common ancestor B0, then *apply*
down the other branch:

```
 B2  ──reverse──►  B1  ──reverse──►  B0  ──apply diff(B0→B1')──►  B1'
                                          {a:10→7, c:∅→3}
 result: {a:7, b:20, c:3}   (== B1')  ✓
```
