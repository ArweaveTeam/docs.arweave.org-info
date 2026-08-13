---
description: >-
  Configuring Arweave with AR_* environment variables
---

# Environment Variables

{% hint style="info" %}
`AR_*` configuration variables are only available from Arweave 2.9.6 onward.
{% endhint %}

Every configuration option can be set through an environment variable. 

# 1. The `AR_*` Naming Convention

The variable name is derived from the option's dotted key: prefix `AR_`, upper-case each segment, and join the segments with underscores.

| Option key | Environment variable |
|---|---|
| `port` | `AR_PORT` |
| `data_dir` | `AR_DATA_DIR` |
| `mining.enabled` | `AR_MINING_ENABLED` |
| `mining.address` | `AR_MINING_ADDRESS` |
| `sync.jobs` | `AR_SYNC_JOBS` |
| `network.server.tcp.max_connections` | `AR_NETWORK_SERVER_TCP_MAX_CONNECTIONS` |

Values are written the same way as on the command line:

```sh
AR_DATA_DIR=/opt/data \
AR_MINING_ENABLED=true \
AR_MINING_ADDRESS=En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
./bin/start
```

Use `./bin/arweave config help <group>` to look up an option's dotted key - the environment variable name follows mechanically from it. `AR_*` variables that do not match a known option key are ignored, so double-check the spelling when a setting doesn't seem to take effect.

Environment variables set scalar values: booleans, numbers, strings, and single peers (`AR_PEERS_TRUSTED=188.166.200.45:1984` becomes a one-element list). A value that starts with `[` or `{` is parsed as JSON, so lists and structured options can also be set this way - wrap the value in single quotes so the shell passes it through intact:

```sh
AR_PEERS_TRUSTED='["peers.arweave.xyz", "188.166.200.45:1984"]' ./bin/start
```

For anything beyond a couple of entries, a [configuration file](configuration.md#2-the-configuration-file) may be easier to read and maintain.

# 2. `AR_CONFIG_FILE`

`AR_CONFIG_FILE` points the node at a JSON or YAML configuration file, exactly like the `--config_file` flag:

```sh
AR_CONFIG_FILE=/opt/arweave/config.yaml ./bin/start
```

Only one config file can be given per launch - setting both `AR_CONFIG_FILE` and `--config_file` is an error.

# 3. Precedence and the Configuration Style

Environment variables sit in the middle of the [precedence order](configuration.md#4-precedence): they override values from the config file and are overridden by command-line flags.

# 4. `ARNODE` and `ARCOOKIE`

Two additional variables configure the Erlang VM itself rather than Arweave options: `ARNODE` sets the [Erlang node name](https://www.erlang.org/doc/system/distributed.html#nodes) and `ARCOOKIE` the [Erlang cookie](https://www.erlang.org/doc/system/distributed.html#security). You'll need them when [running multiple nodes on one server](../operations/multiple-nodes.md), and commands that talk to a running node - such as [`config get` / `config set`](dynamic-configuration.md) - must be invoked with the same `ARNODE` / `ARCOOKIE` values the node was launched with.
