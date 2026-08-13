# Starting New Weave / Running Your Own Localnet

To start a new weave, create a new data directory

```sh
mkdir -p localnet_data_dir
```
,
create a wallet:

```sh
./bin/create-wallet localnet_data_dir
```
,
create a config file (e.g. `localnet.yaml`):

```yaml
genesis:
  init: true
data_dir: <your-data-dir>
mining:
  enabled: true
  address: <your-mining-addr>
storage_modules:
  - partition: 0
    packing_format: spora_2_6
    packing_address: <your-mining-addr>
```

and run:

```sh
$ ./bin/start-localnet --config_file /path/to/localnet.yaml
```

The given address (if none is specified, one will be generated for you) will be assigned
`1_000_000_000_000` AR in the new weave.

The network name will be `arweave.localnet`. You can not start the same node again with the
`genesis.init` option unless you clean the data directory - you need to either restart with the
`join.start_from_latest_state` option or specify a peer from the same Arweave network via
`--peers.trusted <peer>`. Note that the state is only persisted every 50 blocks so if you
restart the node without peers via `join.start_from_latest_state` before reaching the height 50,
it will go back to the genesis block.

As with mainnet peers, each peer must be run in its own physical or virtual environment (e.g. on its own machine or in its own container or virtual machine). If you try to run two nodes within the same environment you will get an error like `Protocol 'inet_tcp': the name arweave@127.0.0.1 seems to be in use by another Erlang node`

When POST'ing transactions to your localnet make sure to include the `X-Network: arweave.localnet` header. If the header is omitted, the mainnet network will be assumed and the request will fail.

## Configuring localnet

See the `localnet` section in [rebar.config](https://github.com/ArweaveTeam/arweave/blob/master/rebar.config) for instructions on changing
network constants for your localnet.