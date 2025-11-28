
## Test Environment

The test environment is set up when running tests (locally via `./bin/test` or `./bin/shell`).

To see some of the macros configured for the test environment see the `test` profile in `rebar.config`.

The majority of macros overridden for the test environment are defined throughout the header files using
`-ifdef(AR_TEST).` directives.

Some notable constants overridden for tests:

1. RandomX operations

See `STUB_RANDOMX` set in `rebar.config`, used for defining `ar_mine_randomx.erl` functions.

RandomX is a relatively slow hashing algorithm, which would substantially increase the test runtime unless mocked.

2. VDF computation

See `INITIAL_VDF_DIFFICULTY` set in `rebar.config`, used in `ar.hrl` to define the default values for VDF difficulty fields of the `#nonce_limiter_info` record (`nonce limiter` is another name for `VDF` used in some parts of the codebase).

Computing every VDF step takes approximately one second on the mainnet which is too long for tests.

VDF computation controls the mining pace, which we do not want to be too fast either so we add a simple test implementation of `ar_vdf:compute2/3` where we introduce explicit short sleeps to define the mining pace.

3. VDF difficulty retarget

See `VDF_DIFFICULTY_RETARGET` in `rebar.config`, used in `ar_block:compute_next_vdf_difficulty/1`.

VDF difficulty update happens every 1200 steps on mainnet (approx 1200 seconds) that is too long for tests so we make it much lower.

4. Block Trail

See `STORE_BLOCKS_BEHIND_CURRENT` in `ar.hrl`.

This constant defines the number of blocks downloaded when joining the network (`ar_join.erl` downloads `2 * ar_block:get_max_tx_anchor_depth()` blocks, and the anchor depth is determined by this constant). In production, it is set to 50 blocks, but in tests, it is overridden to 10 blocks.

## Debugging Tests

Execute `./bin/shell` to launch test nodes and open an Erlang shell with a test environment.

The script launches 5 test nodes including the one the shell is attached to - this is the "main" node. The other 4 nodes are named `peer1`, `peer2`, `peer3`, and `peer4`.

You can run individual tests:

```sh
eunit:test(ar_fork_recovery_tests:height_plus_one_fork_recovery_test_()).
```

If they fail, all the nodes stay up and you can inspect them to troubleshoot.

Below we walk you through a number of common scenarios and interfaces.

#### Launching Arweave

Note that at launch, test nodes do not have a fully initialized Arweave state. The simplest way to start an Arweave node is to run `ar_test_node:start/0`.

```sh
(main-localtest@127.0.0.1)1> ar_test_node:start().
ok
```

Under the hood, it creates a new account and a genesis block with a single transaction uploading 3
256 KiB chunks of data and initializes the Arweave node with it.

#### Managing Nodes

The shell is attached to the main node. To execute code on other nodes, we need to make Erlang RPC calls - `ar_test_node:remote_call/4` is a convenient wrapper for this. Let's launch Arweave on `peer1`:

```sh
(main-localtest@127.0.0.1)4> ar_test_node:remote_call(peer1, ar_test_node, start, []).
ok
```

#### Health Check

Note that we have initialized two nodes on two different genesis blocks. This is not a very interesting setup.

The node is configured with a new TCP port every time, use `ar_test_node:peer_port/1` to learn it.

```sh
(main-localtest@127.0.0.1)5> ar_test_node:peer_port(main).
65494
(main-localtest@127.0.0.1)6> ar_test_node:peer_port(peer1).
65498
```

```sh
$ curl localhost:65494
{"version":5,"release":89,"queue_length":0,"peers":0,"node_state_latency":2,"network":"arweave.localtest","height":0,"current":"DE2MpboqbBWRiRH4wj2_afFE71YHToXeVJzs40ONzUwLX4Pkp0Uhdlo2WyXe08h7","blocks":1}

$ curl localhost:65498
{"version":5,"release":89,"queue_length":0,"peers":0,"node_state_latency":5,"network":"arweave.localtest","height":0,"current":"7djulC-ju_6fFTywjAJoiwCGwpBhbbnmbpTxQrAhnkL1f0mNzByFxeI4tx-BiIDB","blocks":1}
```

The `"current"` field stores the hash of the tip block - we can see the nodes are initialized with different blocks.

#### Joining the Network

Instead, we want them to be in the same network. We can use `ar_test_node:join_on/1` to make one node join the network from the other. This is what usually happens on mainnet when we run `./bin/start peer ...`

```sh
(main-localtest@127.0.0.1)10> ar_test_node:join_on(#{ node => peer1, join_on => main }).
<32196.12327.0>
```

We can use `ar_node:get_current_block()` to fetch the tip now.

```sh
(main-localtest@127.0.0.1)8> B0_main = ar_node:get_current_block().
#block{nonce = 0,previous_block = <<>>,
       ...}
(main-localtest@127.0.0.1)9> B0_peer1 = ar_test_node:remote_call(peer1, ar_node, get_current_block, []).
#block{nonce = 0,previous_block = <<>>,
       ...}
(main-localtest@127.0.0.1)10> rr(ar).
[block,block_announcement,block_announcement_response,
 chunk_metadata,chunk_offsets,config,config_webhook,
 nonce_limiter_info,nonce_limiter_update,
 nonce_limiter_update_response,p3_account,p3_config,
 p3_payment,p3_service,p3_transaction,poa,sample_report,tx,
 vdf_session,verify_report]
(main-localtest@127.0.0.1)11> B0_main#block.indep_hash == B0_peer1#block.indep_hash.
true
```

#### Using Records in Shell

Note we called `rr(ar).` to be able to use records defined in `ar.hrl` in the shell - in this case, the `#block` record.

#### Mining

Test nodes do not start mining when launched. To mine a block, run:

```sh
(main-localtest@127.0.0.1)3> ar_test_node:mine().
ok
```

It may be convenient to use the `ar_http_iface_client` module to query the HTTP API from the shell. Usually its methods accept a `Peer` argument which is a `{IP0, IP1, IP2, IP3, Port}` tuple - you can learn via `ar_test_node:peer_ip/1`:

```sh
(main-localtest@127.0.0.1)13> Peer = ar_test_node:peer_ip(main).
{127,0,0,1,65494}
(main-localtest@127.0.0.1)14> ar_http_iface_client:get_info(Peer).
#{<<"blocks">> => 2,
  <<"current">> =>
      <<"z9353ReVppPAWplYmoZyQNaPbdbVcpgBp9CO2nBKpk3HYv3HtuZJUrdpXKeDk0k0">>,
  <<"height">> => 1,<<"network">> => <<"arweave.localtest">>,
  <<"node_state_latency">> => 6,<<"peers">> => 1,
  <<"queue_length">> => 0,<<"release">> => 89,
  <<"version">> => 5}
```

We can see the height has advanced by one because the node has mined a block.

#### Downloading Blocks by Hash

Let's take the current tip and download the block:

```sh
H = ar_util:decode(<<"z9353ReVppPAWplYmoZyQNaPbdbVcpgBp9CO2nBKpk3HYv3HtuZJUrdpXKeDk0k0">>).
<<207,221,249,221,23,149,166,147,192,90,153,88,154,134,
  114,64,214,143,109,214,213,114,152,1,167,208,142,218,
  112,...>>
```

`ar_util:decode` converts Base64Url to the raw binary representation Arweave uses internally.

Now let's retrieve the block:

```sh
(main-localtest@127.0.0.1)18> {Peer, B, _, _} = ar_http_iface_client:get_block_shadow([Peer], H).
{{127,0,0,1,65494},
 #block{nonce = 3,
        ...},
 11207,673236}
```

It is called `get_block_shadow` because it only downloads the block header and `#block.txs` contains a list of transaction identifiers instead of `#tx` records.

The function may search several peers. It returns the peer it downloaded the block from as the first element of the returned tuple.

#### Inspecting Node Configuration

Let's get the node's configuration.

```sh
(main-localtest@127.0.0.1)27> {ok, Config} = arweave_config:get_env().
{ok,#config{...}}
```

#### Storage Modules

Let's see which storage modules are configured:

```sh
(main-localtest@127.0.0.1)28> Config#config.storage_modules.
[{20000000,0,
  {replica_2_9,<<117,193,95,178,157,29,21,233,22,64,184,
                 84,91,31,60,250,232,5,154,148,129,115,
                 110,...>>}},
  ...
```

Each storage module stores a particular range of the Arweave dataset. The structure has the format `{Size, Number, Packing}` where `Size` denotes the size in bytes of the stored range, `Number` tells which block of size `Size` inside the weave is stored, counting from 0, and `Packing` signifies how the data will be packed before being stored in this storage module.

For example, the first storage module we see in the snippet above is responsible for storing the first 20 MB of the weave and uses replica 2.9 packing - the go-to packing for miners since Arweave 2.9.

Each storage module is assigned a dedicated folder. For every configured storage module, the node runs an `ar_data_sync` process (that manages various data pipelines) and an `ar_sync_record` process (that maintains in-memory records of currently synced data intervals and persists them on disk).

Storage module identifiers (`StoreID`s) are used to refer to a particular storage module:

```sh
(main-localtest@127.0.0.1)29> StoreID = ar_storage_module:id(hd(Config#config.storage_modules)).
"storage_module_20000000_0_dcFfsp0dFekWQLhUWx88-ugFmpSBc27uYPzr-NM014w.replica.2.9"
```

#### Sync Record

For example, we can query the data intervals stored by the module. We call these intervals "sync records".

```sh
(main-localtest@127.0.0.1)32> ar_sync_record:get(ar_data_sync, StoreID).
{1,{{786432,0},nil,nil}}
```

The `{786432, 0}` interval contains the first three 256 KiB chunks of the weave. The module is configured to store the first 20 MB of the weave, but our dataset only contains 3 chunks initialized in `ar_test_node:start/0`.

The structure returned by `ar_sync_record:get/2` is defined in the `ar_intervals.erl` module. It manages a sorted list of non-intersecting and non-contiguous intervals. Each interval is encoded as an `{EndOffset, StartOffset}` tuple where `EndOffset` is strictly greater than StartOffset.

#### Accessing Metrics

Another way to get an insight into the data stored on the node is to look at the metrics reported by the node - simply call the `GET /metrics` endpoint. Metrics are defined in `ar_metrics.erl`.

One of the most informative metrics is `v2_index_data_size_by_packing`:

```sh
v2_index_data_size_by_packing{store_id="storage_module_0_replica_2_9_1",packing="replica_2_9_1",partition_number="0",storage_module_size="2000000",storage_module_index="0",packing_difficulty="2"} 786432
```

`partition_number` is the 0-based number of the 3.6 TB partition of the dataset. `store_id` and `packing` are anonymised because node operators may not want to expose their account addresses.

#### Setting up a Custom Genesis Block

Instead of using the default genesis block, let's create our own with a custom wallet and storage configuration.

#### Creating Wallets

First, create an ECDSA wallet:

```sh
(main-localtest@127.0.0.1)33> {Priv, Pub} = ar_wallet:new_newkeyfile({ecdsa, secp256k1}).
{{{ecdsa,secp256k1},
  <<216,42,124,81,110,157,100,144,194,61,212,34,181,250,119,
    16,67,143,52,157,9,246,163,177,150,152,...>>,
  <<2,178,161,147,183,230,107,24,250,201,149,17,249,103,15,
    30,120,106,42,8,113,118,16,44,78,...>>},
 {{ecdsa,secp256k1},
  <<2,178,161,147,183,230,107,24,250,201,149,17,249,103,
    15,30,120,106,42,8,113,118,16,44,78,...>>}}
```

Note that we use `ar_wallet:new_keyfile/1` and not `ar_wallet:new/1` because the former does not only generate a new key, but also stores it on disk - the node loads it when it signs mined blocks.

Get the wallet address:

```sh
(main-localtest@127.0.0.1)34> Addr = ar_wallet:to_address(Pub).
<<168,91,62,65,253,161,125,236,107,245,195,213,227,180,
  107,100,182,59,242,8,138,225,96,222,22,23,102,188,231,
  ...>>
(main-localtest@127.0.0.1)35> ar_util:encode(Addr).
<<"qFs-Qf2hfexr9cPV47RrZLY78giK4WDeFhdmvOcg4bk">>
```

#### Providing Initial Balance

Now initialize a genesis block with our wallet funded with 1 million AR:

```sh
(main-localtest@127.0.0.1)36>[B0] = ar_weave:init([{Addr, 100_000_000_000_000_000_000, <<>>}]).
[#block{nonce = 0,previous_block = <<>>, ...]
```

1 AR equals `1_000_000_000_000` (10^12) Winston.

Note: in the test environment, transaction fees are typically very large. This is because the network is small, so the pricing algorithm considers the token to be very cheap and sets high fees accordingly. When testing scenarios that involve uploading data, it makes sense to start the weave with a large balance so that tests can afford to post transactions.

Now let's configure a storage module for bytes 0 to `4_000_000` with `replica_2_9` packing:

```sh
(main-localtest@127.0.0.1)38> StorageModule = {4_000_000, 0, {replica_2_9, Addr}}.
{4000000,0,
 {replica_2_9,<<168,91,62,65,253,161,125,236,107,245,195,
                213,227,180,107,100,182,59,242,8,138,225,
                96,222,...>>}}
```

Start the node with our custom genesis block and storage module:

```sh
(main-localtest@127.0.0.1)26> ar_test_node:start(#{ b0 => B0, addr => Addr, storage_modules => [StorageModule] }).
ok
```

```sh
(main-localtest@127.0.0.1)52> f(Config), {ok, Config} = arweave_config:get_env().
...
(main-localtest@127.0.0.1)53> Config#config.storage_modules.
[{4000000,0,
  {replica_2_9,<<168,91,62,65,253,161,125,236,107,245,
                 195,213,227,180,107,100,182,59,242,8,
                 138,225,96,...>>}}]
```

```sh
(main-localtest@127.0.0.1)54> Config#config.mining_addr == Addr.
true
```

Let's also bring `peer1` into this new network:

```sh
(main-localtest@127.0.0.1)72> ar_test_node:join_on(#{ node => peer1, join_on => main }).
<32196.405860.0>
```

#### Checking Account Balance

```sh
(main-localtest@127.0.0.1)55> ar_node:get_balance(Addr).
100000000000000000
```

Via HTTP API:

```sh
$ curl localhost:65494/wallet/qFs-Qf2hfexr9cPV47RrZLY78giK4WDeFhdmvOcg4bk/balance
```

#### Sending Transactions

Let's use our account now. We'll send 1 Winston to a random address:

```sh
(main-localtest@127.0.0.1)27> RandomAddr = crypto:strong_rand_bytes(32).
<<...>>
(main-localtest@127.0.0.1)28> TX = ar_test_node:sign_tx({Priv, Pub}, #{ target => RandomAddr, quantity => 1 }).
#tx{...}
```

The `ar_test_node:sign_tx/2` function is a convenient helper that:

1. Fetches a block hash to use as an anchor (via `ar_test_node:get_tx_anchor/1`, which queries `GET /tx_anchor`)
2. Estimates the transaction fee (via `GET /price/{data_size}` or `GET /price/{data_size}/{target}` if a target is specified)
3. Signs the transaction

Now let's post the transaction:

```sh
(main-localtest@127.0.0.1)74> ar_test_node:assert_post_tx_to_peer(main, TX).
{ok,{{<<"200">>,<<"OK">>},
     [{<<"access-control-allow-origin">>,<<"*">>},
      {<<"content-length">>,<<"2">>},
      {<<"date">>,<<"Thu, 20 Nov 2025 16:08:44 GMT">>},
      {<<"server">>,<<"Cowboy">>}],
     <<"OK">>,1763654925536197,1763654925542633}}
```

#### Accessing Mempool

Check the mempool:

```sh
(main-localtest@127.0.0.1)79> {{ok, TXIDs}, Peer} = ar_http_iface_client:get_mempool(Peer).
{{ok,[<<5,101,215,33,72,80,41,200,124,225,226,92,152,
        189,41,77,92,128,24,125,234,8,120,146,134,...>>]},
 {127,0,0,1,65494}}
```

`peer1` has learned about the transaction as well:

```sh
(main-localtest@127.0.0.1)85> Peer1 = ar_test_node:peer_ip(peer1).
{127,0,0,1,65498}
(main-localtest@127.0.0.1)86> {{ok, TXIDs}, Peer1} = ar_http_iface_client:get_mempool(Peer1).
{{ok,[<<5,101,215,33,72,80,41,200,124,225,226,92,152,
        189,41,77,92,128,24,125,234,8,120,146,134,...>>]},
 {127,0,0,1,65498}}
```

In the API:

```sh
$ curl localhost:65494/tx/pending
["BWXXIUhQKch84eJcmL0pTVyAGH3qCHiShmCj-XmKiXg"]
```

```sh
$ curl localhost:65494/tx/BWXXIUhQKch84eJcmL0pTVyAGH3qCHiShmCj-XmKiXg
Pending
```

Check the balances before mining:

```sh
(main-localtest@127.0.0.1)88> ar_node:get_balance(Addr).
100000000000000000
(main-localtest@127.0.0.1)89> ar_node:get_balance(RandomAddr).
0
```

Mine a block:

```sh
(main-localtest@127.0.0.1)34> ar_test_node:mine().
ok
```

Check the mempool again - it should be empty:

```sh
(main-localtest@127.0.0.1)35> ar_http_iface_client:get_pending_txs(Peer).
{{ok,[]},...}
```

Check the balances after mining:

```sh
(main-localtest@127.0.0.1)36> ar_node:get_balance(Addr).
99999999984017435209
(main-localtest@127.0.0.1)37> ar_node:get_balance(RandomAddr).
1
```

The sending address balance decreased by 1 Winston plus the transaction fee, and the receiving address now has 1 Winston.

```sh
(main-localtest@127.0.0.1)15> TX#tx.reward + 1 + 99999999984017435209 == 100_000_000_000_000_000_000.
true
```

#### Fetching Chunks

Before we upload some data, let's look at the chunks already stored in the weave with the genesis block.

```sh
(main-localtest@127.0.0.1)20> ar_data_sync:get_chunk(1, #{ packing => {replica_2_9, Addr}, pack => false }).
{ok,#{chunk_size => 262144,
      chunk =>
          <<168,206,204,22,200,228,55,147,83,129,156,249,149,203,
            143,232,174,186,53,78,14,246,86,144,82,183,...>>,
      tx_path =>
          <<178,38,127,31,158,128,18,154,171,176,133,55,132,229,12,
            114,191,30,110,149,22,208,26,54,115,217,...>>,
      data_path =>
          <<176,23,135,208,212,216,170,39,43,114,112,84,231,252,128,
            75,81,177,146,250,114,67,110,148,94,5,...>>,
      tx_root =>
          <<226,165,118,182,96,174,176,60,3,148,166,87,181,193,186,
            235,27,177,52,205,226,225,234,6,85,243,...>>,
      absolute_end_offset => 262144}}
```

The first argument `ar_data_sync:get_chunk/2` accepts is an offset. This offset is strictly greater than the chunk's start offset (where it begins in the weave)
and less than or equal to the chunk's end offset. Therefore, the following call fetches the same chunk:

```sh
(main-localtest@127.0.0.1)20> ar_data_sync:get_chunk(262144, #{ packing => {replica_2_9, Addr}, pack => false }).
{ok,#{chunk_size => 262144,
      chunk =>
          <<168,206,204,22,200,228,55,147,83,129,156,249,149,203,
            143,232,174,186,53,78,14,246,86,144,82,183,...>>,
      tx_path =>
          <<178,38,127,31,158,128,18,154,171,176,133,55,132,229,12,
            114,191,30,110,149,22,208,26,54,115,217,...>>,
      data_path =>
          <<176,23,135,208,212,216,170,39,43,114,112,84,231,252,128,
            75,81,177,146,250,114,67,110,148,94,5,...>>,
      tx_root =>
          <<226,165,118,182,96,174,176,60,3,148,166,87,181,193,186,
            235,27,177,52,205,226,225,234,6,85,243,...>>,
      absolute_end_offset => 262144}}
```

Add 1 to the offset, and we get a new chunk:

```sh
(main-localtest@127.0.0.1)22> ar_data_sync:get_chunk(262144 + 1, #{ packing => {replica_2_9, Addr}, pack => false }).
{ok,#{chunk_size => 262144,
      chunk =>
          <<133,232,24,98,34,222,100,193,62,117,143,4,5,220,35,94,
            64,221,26,181,83,99,238,190,89,136,...>>,
      tx_path =>
          <<178,38,127,31,158,128,18,154,171,176,133,55,132,229,12,
            114,191,30,110,149,22,208,26,54,115,217,...>>,
      data_path =>
          <<176,23,135,208,212,216,170,39,43,114,112,84,231,252,128,
            75,81,177,146,250,114,67,110,148,94,5,...>>,
      tx_root =>
          <<226,165,118,182,96,174,176,60,3,148,166,87,181,193,186,
            235,27,177,52,205,226,225,234,6,85,243,...>>,
      absolute_end_offset => 524288}}
```

`pack => false` tells the function not to repack the chunk in case it is not stored in the desired packing.

```sh
(main-localtest@127.0.0.1)23> ar_data_sync:get_chunk(262144 + 1, #{ packing => unpacked, pack => false }).
{error,chunk_not_found}
```

However, we can ask to pack it for us:

```sh
(main-localtest@127.0.0.1)24> ar_data_sync:get_chunk(262144 + 1, #{ packing => unpacked, pack => true }).
{ok,#{chunk_size => 262144,
      chunk =>
          <<0,1,0,0,0,1,0,1,0,1,0,2,0,1,0,3,0,1,0,4,0,1,0,5,0,1,...>>,
      tx_path =>
          <<178,38,127,31,158,128,18,154,171,176,133,55,132,229,12,
            114,191,30,110,149,22,208,26,54,115,217,...>>,
      data_path =>
          <<176,23,135,208,212,216,170,39,43,114,112,84,231,252,128,
            75,81,177,146,250,114,67,110,148,94,5,...>>,
      unpacked_chunk =>
          <<0,1,0,0,0,1,0,1,0,1,0,2,0,1,0,3,0,1,0,4,0,1,0,5,0,1,...>>,
      tx_root =>
          <<226,165,118,182,96,174,176,60,3,148,166,87,181,193,186,
            235,27,177,52,205,226,225,234,6,85,243,...>>,
      absolute_end_offset => 524288}}
```

#### Uploading Data

Let's create a transaction to upload 2 MiB of data:

```sh
(main-localtest@127.0.0.1)45> Data = crypto:strong_rand_bytes(2 * 1024 * 1024).
<<...>>
(main-localtest@127.0.0.1)46> DataTX = ar_test_node:sign_tx({Priv, Pub}, #{ data => Data }).
#tx{...}
```

Post the transaction:

```sh
(main-localtest@127.0.0.1)28> ar_test_node:assert_post_tx_to_peer(main, DataTX).
{ok,{{<<"200">>,<<"OK">>},
     [{<<"access-control-allow-origin">>,<<"*">>},
      {<<"content-length">>,<<"2">>},
      {<<"date">>,<<"Thu, 20 Nov 2025 16:41:06 GMT">>},
      {<<"server">>,<<"Cowboy">>}],
     <<"OK">>,1763656867804420,1763656867833993}}
```

Mine a block to include the transaction:

```sh
(main-localtest@127.0.0.1)48> ar_test_node:mine().
ok
```

#### Disk Pool

Let's take a look at the metrics:

```sh
v2_index_data_size_by_packing{store_id="storage_module_4000000_0_replica_2_9_1",packing="replica_2_9_1",partition_number="0",storage_module_size="4000000",storage_module_index="0",packing_difficulty="2"} 786432
v2_index_data_size_by_packing{store_id="default",packing="unpacked",partition_number="undefined",storage_module_size="undefined",storage_module_index="undefined",packing_difficulty="0"} 2097152
```

The data has been uploaded to the "default" storage module. The default storage module runs even when no storage modules are configured, its main purpose is to cache and distribute data uploaded by clients via `POST /chunk` or attached to transactions using the "data" field. Once some data receives a sufficient number of confirmations (blocks on top), it is either moved to the storage modules covering the corresponding range, if any, or deleted.

Let's mine two more blocks and watch the new data moved to the configured storage module.

```sh
(main-localtest@127.0.0.1)40> ar_test_node:mine().
ok
```

Make sure a new block has been mined and applied:
```sh
(main-localtest@127.0.0.1)44> ar_test_node:assert_wait_until_height(main, 3).
[{<<162,161,197,227,251,60,20,83,168,182,229,45,44,222,
```

```sh
(main-localtest@127.0.0.1)40> ar_test_node:mine().
ok
```
```sh
(main-localtest@127.0.0.1)44> ar_test_node:assert_wait_until_height(main, 4).
[{<<162,161,197,227,251,60,20,83,168,182,229,45,44,222,
```

Now query metrics:

```sh
v2_index_data_size_by_packing{store_id="storage_module_4000000_0_replica_2_9_1",packing="replica_2_9_1",partition_number="0",storage_module_size="4000000",storage_module_index="0",packing_difficulty="2"} 2883584
v2_index_data_size_by_packing{store_id="default",packing="unpacked",partition_number="undefined",storage_module_size="undefined",storage_module_index="undefined",packing_difficulty="0"} 0
```

#### Disk Pool Threshold

There is a special function for getting the current byte threshold separating the disk pool from confirmed data:

```sh
(main-localtest@127.0.0.1)45> ar_data_sync:get_disk_pool_threshold().
2883584
```

The disk pool threshold is the weave size at the `?SEARCH_SPACE_UPPER_BOUND_DEPTH`s block counting from the tip. It is defined in `ar_consensus.hrl` and is set to 3 in the test environment and 50 on mainnet.

#### Inspecting Sync Records After Upload

Fetch the updated sync records:

```sh
(main-localtest@127.0.0.1)15> ar_sync_record:get(ar_data_sync, StoreID).
{1,{{2883584,0},nil,nil}}
```

The sync record now shows bytes 1 through 2883584 are synced (the original 768 KiB plus the 2 MiB we just uploaded).

Note that the `GET /data_sync_record` endpoint (the one `ar_http_iface_client:get_sync_record/1` queries) does not serve these intervals anymore.

```sh
(main-localtest@127.0.0.1)56> ar_http_iface_client:get_sync_record(Peer).
{ok,{0,nil}}
```

This is because the so-called "global" sync record, which aggregates sync records from all storage modules, excludes 2.9 data. Our node is configured only with `replica_2_9` data now.

See `ar_global_sync_record.erl` for the implementation details.

2.9 data is excluded to make syncing more efficient. When a node syncs data, it queries its peers for synced intervals calling `GET /data_sync_record/{Start}/{End}/{Limit}` and then syncs the missing ranges chunk by chunk. Syncing 2.9 data this way is not efficient because 2.9 packing generates entropy (what takes substantial amount of time/computing resources) which is by design shared across chunks spread out across the entire 3.6 TB partition (2 MB partition in tests). That's why syncing it chunk by chunk will cause redundant entropy generation and waste resources. Instead, to look for 2.9 data, the nodes query the `GET /footprint/{partition}/{footprint}` endpoint to query data "footprint" by "footprint" where each footprint is a collection of chunks sharing the entropy as defined by the protocol.

#### Footprint Records

To fetch footprint records, use `ar_footprint_record:get_intervals/3`:

```sh
(main-localtest@127.0.0.1)59> FootprintIntervals = ar_footprint_record:get_intervals(0, 0, StoreID).
...
```

Footprint intervals have the same form as normal intervals but different semantics. Adjacent chunks in the footprint record are not adjacent in the weave. Also, the footprint record stores 256 KiB-bucket numbers instead of byte offsets.

To convert footprint intervals to normal byte-range intervals:

```sh
(main-localtest@127.0.0.1)60> ar_footprint_record:get_intervals_from_footprint_intervals(FootprintIntervals).
...
```

## End-to-end tests

End-to-end (e2e) tests are heavy tests run in an environment close to production. They do not mock RandomX and VDF functions. We do not run them as part of the CI.

Run `./bin/e2e` to execute all e2e tests. You can run individual modules via `./bin/e2e ar_sync_pack_mine_tests`, `./bin/e2e ar_repack_in_place_mine_tests`, and `./bin/e2e ar_repack_mine_tests.erl`.

To run a debug shell in the e2e environment, run `./bin/e2e_shell` and wait until the console reports that `peer2` has started (it will take some time).
