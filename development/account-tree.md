# Account Tree

How Arweave stores the account tree in memory: the relationship between the
account tree, the patricia tree, the diff DAG, the sink, diffs, and the
reconstruction of the previous, following, and uncle representations.

---

## Cast of characters

### Concepts


| Concept           | What it is                                                                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **account tree**  | a block's full state, the mapping `address → {balance, last_tx, denomination, mining_permission}`. One per block                                                         |
| **patricia tree** | the radix-trie structure that implements one account tree with shared-prefix paths and content-hashed nodes; its root hash is the block's `wallet_list`                                                        |
| **sink**          | the current account tree, the one representation stored as a full tree, resting at the chain tip. Every other, older, tree exists only as a diff against it. It moves forward as new blocks extend the tip via `set_current`, and backward to hash a block on a competing fork, serve a historical `get_chunk`, or reach the fork point during a reorg. See Layer 4                                                       |
| **diff**          | the edge between two consecutive blocks, a map `{address → new value \| remove}` of the accounts that changed from one to the next, older to newer                                                             |
| **diff DAG**      | the whole graph of block states wired together by diff edges. It spans the blocks the node still keeps, a recent window up to the current tip, pruned and not reaching back to genesis, plus any forks it stores. One node is kept as a full tree, the sink; every other exists only as the diffs along the path to it, so all are reachable from that one copy |
| **parent, child** | adjacent blocks: a child block extends its parent |
| **sibling** | two blocks with the same parent, a fork |
| **ancestor, descendant** | a block reachable by following parents is an ancestor, one reachable by following children is a descendant |
| **uncle** | a sibling of an ancestor, a block on a competing fork. For example `B1'` is `B2`'s uncle: the sibling of `B2`'s parent `B1` |


### Modules


| Module                     | Role                                                                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **`ar_account_tree`**      | gen_server manager of the account tree, the single serialized point of access. Owns the ETS table that holds the sink and owns the diff DAG, and drives every operation on them: moving the sink, applying and reversing diffs, and persisting         |
| **`ar_patricia_tree_core`** | the shared patricia tree algorithm — insert, get, delete, hash, iterate — parameterized by a storage backend. The two variants below supply storage and delegate here |
| **`ar_patricia_tree_ets`** | the ETS storage backend that backs the sink: a single mutable ETS table holding one full tree, mutated in place to represent whichever block's tree the sink currently points at             |
| **`ar_patricia_tree`** | the immutable, map-based storage backend, used where a standalone tree is needed: genesis, peer download, JSON serialization, disk reads |
| **`ar_diff_dag`**          | the diff DAG: stores the diffs as edge labels and the sink pointer                             |


To address a potential naming confusion, `ar_wallet` manages cryptographic wallets. It generates keypairs, translates public keys to wallet addresses, and verifies signatures, and is not directly related to account management. The connection is that wallet addresses are keys in the account tree, produced from public keys via the `ar_wallet:to_address` functions. For example, `ar_wallet:to_address(TX#tx.owner)` returns the address the transaction takes funds from. A transaction can send AR to any 32-byte target, which ends up as a key in the account tree but may not have an actual cryptographic wallet behind it. The protocol also used to allow shorter target values, so the account tree has an entry for the `<<>>` empty-binary key. `B#block.wallet_list` is the legacy field name for the account-tree root hash.

### Why a patricia trie?

The account tree is re-hashed every block, yet a block changes only a handful of
accounts out of potentially millions. Therefore, we need a structure that scales well
with the growing number of total entries while the number of updated entries remains below
a fixed upper bound. Currently the maximum number of updates possible per block is 2002 -
1000 tx source addresses + 1000 tx target address + 1 reward address + possibly 1 banned address.

The core strength of the patricia tree is that it does not require rebalancing:

- Depth is capped by the key length. Addresses are 32 bytes and the
  trie branches one byte at a time, so any root-to-leaf path crosses at most 32
  branch nodes. Traversing the path from root to leaf takes `O(32)`.
- Width is capped by 256 so hashing intermediate nodes is `O(256)`.
- In practice the tree is far shallower. Addresses are hashes of public keys, so they
  are distributed nearly uniformly. The expected depth is ≈ `log256(n)`, about 3 bytes deep
for millions of accounts.

---

## Example

Consider the following chain state:

- `B0`, `B1`, `B1'`, `B2` are blocks. The chain forks after `B0`: `B1` and
  `B1'` are siblings, and `B2` extends `B1`, the tip.
- `a`, `b`, `c` are accounts. Each is a 4-tuple
  `{balance, last_tx, denomination, mining_permission}`, but the diagram shows
  only the balance for readability, so `a:5` means account `a` has balance 5.

```
        B0  {a:10, b:20}
       /  \
     B1'   B1   {a:5,  b:25}
   {a:7,    \
    b:20,    B2  {a:8, b:22}   ◄── tip
    c:3}
```

---

## "Account tree" is the concept; "patricia tree" is the structure

`B0`'s account tree is logically just a map from each account's address to
its value:

```
a → {balance:10, …}
b → {balance:20, …}
```

It is stored as a patricia radix trie keyed by that address, a ≤ 32-byte hash. Accounts whose addresses share leading bytes share the beginning of the path from the root to the leaf. To compute the root hash, we hash each node's contents, and the hashes combine recursively to produce the root, the block's `wallet_list`:

```
                (root) #h0
                   │
        a, b share a leading prefix
                   │
                (inner) #h1
               /          \
           leaf a        leaf b
          {balance,…} #ha    {balance,…} #hb

   root hash #h0  ==  B0's wallet_list
```

The whole trie lives in one mutable ETS table, `ar_patricia_tree_ets`, or one
immutable map, `ar_patricia_tree`, both driven by the shared algorithm in
`ar_patricia_tree_core`.

### Node structure and how each kind is hashed

Every node is a tuple carrying its parent, its set of children, its cached hash,
the path prefix, and an optional value. This is how `compute_hash` treats each of the three different inputs:

- Leaf: a value and no children. The value is the account itself, stored as a
  tuple, `{balance, last_tx}` for accounts not updated since the re-denomination upgrade, and `{balance, last_tx, denomination, mining_permission}` for the rest.
- Internal node: children hashes and no value of its own. Its hash combines its
  children's hashes. *A node with a single child is compressed, taking that child's
  hash unchanged so the intermediate step adds no hashing.*
- Internal node that also holds a value: both children and a value. *This arises
  when one stored key is a proper prefix of another*, so the shorter key's node
  sits on the path to the longer one. Two 32-byte addresses can never nest this
  way, but the protocol historically allowed targets shorter than 32 bytes, and
  such a short key can be a proper prefix of a full address. It is hashed by first
  hashing the node's own value as if it were a leaf, then combining that leaf hash
  together with the child hashes into the node hash, so the value participates as
  one more entry alongside the children.

The hashing is defined by `ar_block:wallet_list_hash_fun`, and the combining step
goes through `ar_deep_hash`, which takes a list and folds it into one hash. An
internal node's hash is `ar_deep_hash` of the list of its children's hashes in key
order, with the node's own value hash prepended when it has one. A legacy
`{balance, last_tx}` leaf is hashed by passing the list `[address, balance,
last_tx]` to `ar_deep_hash`. The current four-field leaf is the exception: its
fields are length-prefixed and concatenated into a single preimage hashed with
SHA-384 directly, not through `ar_deep_hash`.

---

## The diff DAG: one full tree (the "sink") + diffs on the edges

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

- Each DAG node is a block's account-tree representation, identified by its
root hash, `B#block.wallet_list`.
- Only the sink, B2, is a real, full patricia trie in the ETS table. Every other
node is virtual, existing only as a diff relative to a neighbour.
- An edge diff is small: `diff(B0→B1) = {a: 10→5, b: 20→25}`, just two accounts.

So instead of 4 tries, the node stores 1 trie for B2 plus 3 little diffs.

---

## Reconstructing another representation: walk edges, apply and reverse diffs

The sink can be moved to any DAG node by walking the path and mutating the one
trie. Reading B0 while the sink is at B2, reverse each diff as you climb:

```
 sink = B2:  {a:8,  b:22}
   reverse diff(B1→B2) {a:5→8,  b:25→22}  ──►  {a:5,  b:25}   (== B1)
   reverse diff(B0→B1) {a:10→5, b:20→25}  ──►  {a:10, b:20}   (== B0)
 sink now holds B0 in full  ✓
```

Reaching the uncle B1', reverse to the common ancestor B0, then apply down the
other branch:

```
 B2  ──reverse──►  B1  ──reverse──►  B0  ──apply diff(B0→B1')──►  B1'
                                          {a:10→7, c:∅→3}
 result: {a:7, b:20, c:3}   (== B1')  ✓
```

### Why moving the sink stays cheap: cached intermediate hashes

Each trie node caches its own hash alongside its contents. Applying or reversing
a diff as the sink walks an edge goes through `insert` and `delete`, which mark
only the touched root-to-leaf paths `no_hash` and leave every other node's cached
hash intact. The next `compute_hash` recomputes a node only when its hash is
`no_hash`; a node that still carries a hash is returned as is, and its whole
subtree is skipped.

So re-hashing after the sink moves one edge costs work proportional to the
accounts on that edge's diff, not to the size of the tree. It is the same
locality that makes a single block cheap to hash, now applied per hop. Walking
several edges to reach a distant representation re-hashes only the union of the
paths those diffs touched, never the untouched subtrees between them.

The snapshot mechanism used for non-tip work leans on the same caching. While a
snapshot is active, every write records the pre-snapshot value of the one node it
overwrites, so an excursion accumulates entries only for the nodes it actually
touches, the paths along the diffs it walked. `snapshot_restore` then rewrites
just those nodes back to their recorded values and leaves the rest of the tree
alone; it does not rebuild the tree. Because each recorded value is the node's
exact prior bytes, its cached hash comes back with it, so the tip is restored
clean with nothing left to re-hash.

### Trade-off: memory footprint against recomputation on fork switches

Cached hashes live only in the sink, and only one representation is the sink at a
time. Every hashing of a non-tip representation, such as validating a block on a
competing fork with `apply_block` or `add_wallets`, runs inside a snapshot: it
moves the sink there, hashes, then rolls the sink back to the tip and discards the
hashes it just computed. A read-only excursion like `get_wallet_list_chunk` takes
the same round trip but only reads a range, so it moves the sink without hashing
at all. Either way the work for a fork is never retained: reaching that fork again
re-applies every diff along the path from the tip, re-hashes the paths each block
on the way touches when a root hash is needed, and none of that work is reused on
the next request, which repeats all of it.

This is a deliberate choice of a smaller memory footprint over less computation.
The node keeps exactly one full tree resident and pays to recompute any other
representation on demand, however many times it is asked for. The opposite choice
would cache the hashes, or whole materialized trees, for several representations,
so repeated fork switches reuse earlier work and skip the re-hash, at the cost of
holding more than one tree's worth of nodes in memory. Arweave currently favours
the smaller footprint, on the expectation that a given fork is rarely hashed
often enough for the recomputation to outweigh the memory a cache would cost.
