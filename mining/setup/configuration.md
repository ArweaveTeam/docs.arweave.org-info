---
description: >-
  A guide to the Arweave node configuration system
---

# 1. Overview

Arweave provides a number of configuration options to control, customize, and tune its operation. Every option has a single canonical dotted key (for example `mining.enabled` or `network.server.tcp.max_connections`) and can be set three ways:

1. In a **configuration file** (JSON or YAML)
2. As an **environment variable** (see [Environment Variables](environment-variables.md))
3. As a **command-line flag**

{% hint style="info" %}
Node configuration changed substantially in Arweave 2.9.6. If you are running an earlier Arweave version please see [Legacy Configuration](legacy-configuration.md). If you have a `config.json` or launch script written for an earlier release, see [Migrating Your Configuration](migrating-config.md) for instructions on converting the old config file. Arweave 2.9.6 maintains backwards compatibilty with the legacy configuration formats so converting your legacy configuration is not required.
{% endhint %}

This guide describes how to configure your node. Once you have a configuration, see [Running Your Node](running.md) for a walkthrough of the main operating phases for different [node types](../overview/node-types.md), with example configurations you can adapt as needed.

# 2. The Configuration File

For anything beyond a couple of options we recommend keeping your configuration in a file. The file may be JSON or YAML - the format is picked from the file extension, which must be `.json` or `.yaml`.

Point the node at the file with the `--config_file` flag:

```sh
./bin/start --config_file /opt/arweave/config.yaml
```

or with the `AR_CONFIG_FILE` environment variable:

```sh
AR_CONFIG_FILE=/opt/arweave/config.yaml ./bin/start
```

Only one config file can be provided per launch - specifying both the flag and the environment variable is an error.

[Command-line flags](#3-command-line-flags) are dotted paths (for example `--mining.enabled`), whereas options in a config file are expressed as nested objects. The dotted form self is not valid in config files. A minimal YAML mining configuration:

```yaml
data_dir: /opt/data
peers:
  trusted:
    - peers.arweave.xyz
mining:
  enabled: true
  address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
storage_modules:
  - partition: 0
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 1
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
```

The same configuration in JSON:

```json
{
    "data_dir": "/opt/data",
    "peers": {
        "trusted": ["peers.arweave.xyz"]
    },
    "mining": {
        "enabled": true,
        "address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
    },
    "storage_modules": [
        {
            "partition": 0,
            "packing_format": "replica_2_9",
            "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
        },
        {
            "partition": 1,
            "packing_format": "replica_2_9",
            "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
        }
    ]
}
```

# 3. Command-line Flags

Every option can also be set as a long flag: the option's dotted path prefixed with `--`.

```sh
./bin/start \
    --data_dir /opt/data \
    --peers.trusted peers.arweave.xyz \
    --mining.enabled \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    --port 1985
```

* Values follow the flag: `--port 1985`, or use the `=` form: `--port=1985`.
* Boolean options can be given as a bare flag (`--mining.enabled` means `true`) or with an explicit value (`--mining.enabled false`).
* Flags set scalar values: booleans, numbers, strings, and single peers (a lone `--peers.trusted 188.166.200.45` becomes a one-element list).
* A flag value that starts with `[` or `{` is parsed as JSON, so lists and structured options can also be set on the command line - wrap the value in single quotes so the shell passes it through intact:

```sh
./bin/start \
    --data_dir /opt/data \
    --peers.trusted '["peers.arweave.xyz", "188.166.200.45:1984"]' \
    --storage_modules '[{"partition": 0, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"}]' \
    --mining.enabled \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI
```

* If the same flag is given more than once, the last occurrence wins - repeating a flag replaces the value, it does not append to a list.

Flags can be combined with a config file - the file holds the stable configuration, and flags override individual options for one launch:

```sh
./bin/start --config_file /opt/arweave/config.yaml --mining.enabled false
```

# 4. Precedence

Values are applied in this order, with later sources overriding earlier ones:

1. Configuration file
2. Environment variables
3. Command-line flags

So a `AR_PORT=1985` environment variable overrides a `port` value from the config file, and a `--port 1986` flag overrides both.

# 5. Configuration Help

The complete, always-current option reference is built into the node:

```sh
# List all option groups with a one-line summary per option:
./bin/arweave config help

# Detailed help for one group (descriptions, defaults, runtime flag,
# and the legacy option name each option replaces):
./bin/arweave config help mining
```

Many options can also be read and changed on a running node - no restart required - with `./bin/arweave config get` and `config set`. These runtime-writable options are marked with a `*` in the top-level `config help` listing. See [Dynamic Configuration](dynamic-configuration.md).

# 6. Required Options

All node types and operating phases require at least the following options

- `data_dir`: indicates where the node should store indices and metadata. See [Directory Structure](directory-structure.md)
- `peers.trusted`: specifies the node's [Trusted Peers](../overview/trusted-peers.md). Your node will use these peers when it initially joins the network so it is important that you trust them to behave honestly.

# 7. Legacy Configuration

Releases before Arweave 2.9.6 used a different configuration style (`config_file config.json` with a flat legacy JSON schema, and space-separated command-line arguments such as `mine` and `data_dir /opt/data`). That style still works, but the two styles cannot be mixed in a single launch. See [Legacy Configuration](legacy-configuration.md) for the legacy style itself, and [Migrating Your Configuration](migrating-config.md) for the `convert_config` tool that converts a legacy `config.json` automatically.
