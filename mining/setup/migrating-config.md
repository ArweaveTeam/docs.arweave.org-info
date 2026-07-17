---
description: >-
  Migrating a legacy config.json or launch command to the current
  configuration format
---

# Migrating Your Configuration

Arweave 2.9.6 introduced the current configuration system: dotted option keys, JSON/YAML config files with nested keys, `--long` command-line flags, and `AR_*` environment variables. Earlier releases used a flat `config.json` schema and space-separated command-line arguments (`mine`, `data_dir /opt/data`, `storage_module 0,...`) - documented in [Legacy Configuration](legacy-configuration.md).

Legacy configurations still load, so upgrading the node does not force an immediate rewrite. This guide covers converting when you're ready.

{% hint style="info" %}
**Upgrading from 2.9.5.1?** The release after 2.9.5.1 ships the `convert_config` tool described below. After upgrading, run it once against your existing `config.json` to produce an equivalent file in the current format, review the output, and switch your launch command to `--config_file`.
{% endhint %}

# 1. Converting a Config File

`convert_config` reads a legacy `config.json` and writes an equivalent file in the current JSON or YAML format:

```sh
./bin/arweave convert_config yaml config.json config.yaml
# or
./bin/arweave convert_config json config.json config-new.json
```

The conversion applies every legacy field mapping for you. Review the output, then launch with it:

```sh
./bin/start --config_file /opt/arweave/config.yaml
```

## 1.1 Example

A typical legacy solo-mining `config.json`:

```json
{
    "enable": ["randomx_large_pages"],
    "peers": ["188.166.200.45", "163.47.11.64"],
    "data_dir": "/opt/data",
    "vdf_server_trusted_peers": ["vdf-server-3.arweave.xyz"],
    "transaction_blacklist_urls": ["https://public_shepherd.arweave.net"],
    "storage_modules": [
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9",
        "1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9"
    ],
    "mining_addr": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",
    "mine": true
}
```

converts to this YAML:

```yaml
data_dir: /opt/data
mining:
  address: En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI
  enabled: true
peers:
  trusted:
    - 188.166.200.45
    - 163.47.11.64
  vdf_server:
    - vdf-server-3.arweave.xyz
randomx:
  large_pages: true
storage_modules:
  -
    packing_address: En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI
    packing_format: replica_2_9
    partition: 0
  -
    packing_address: En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI
    packing_format: replica_2_9
    partition: 1
transactions:
  blocklist:
    urls:
      - "https://public_shepherd.arweave.net"
```

There is no mechanical rule for mapping a legacy option name to its current key - options were renamed and regrouped case by case. To look up any mapping, use `./bin/arweave config help <group>` (see [Configuring Your Node](configuration.md#5-discovering-options)): every option that replaces a legacy option lists the legacy name on a `legacy:` line. For example:

```
$ ./bin/arweave config help mining
...
  mining.enabled
    Automatically start mining once the network has been joined.
    default: false
    runtime: false
    legacy: mine
...
```

Two behaviors of the conversion worth noting:

* `convert_config` refuses a config that declares custom (non-partition) bucket sizes (e.g. `"0,2000000000000,addr.replica.2.9"`): converting requires renaming the storage modules directories which is out of scope for `convert_config`. Either stay on the legacy config, or follow [Migrating Custom Bucket Sizes Manually](#12-migrating-custom-bucket-sizes-manually). Whole-partition modules are handlined by `convert_config`.
* The output contains only the options your legacy config set - nothing is added for options left at their defaults, and peer entries keep exactly the spelling you wrote (hostnames stay hostnames; no port is appended).

## 1.2 Migrating Custom Bucket Sizes Manually

`convert_config` refuses configs with custom (non-partition) bucket sizes because the current notation [names storage module directories differently](directory-structure.md#4-storage-modules): a legacy custom-bucket module lives in `storage_module_[bucket_size]_[bucket_index]_[packing]`, while a range module lives in `storage_module_[range_start]_[range_end]_[packing]`. Migrating such a config means renaming directories on disk, which you should do deliberately, with the node stopped.

The recommended workflow:

1. Make a copy of your legacy `config.json` with the `storage_modules` and `defragment_modules` entries removed, and run `convert_config` on the copy. This converts everything else automatically.
2. Stop your node.
3. For each custom-bucket-size module, compute its byte range: `range_start = bucket_index * bucket_size` and `range_end = (bucket_index + 1) * bucket_size`. For example, the legacy entry `"5,1000000000000,[addr].replica.2.9"` (bucket size 1 TB, index 5) covers the range 5000000000000 to 6000000000000.
4. Rename the module's directory to the range form. Continuing the example:

```sh
mv [data_dir]/storage_modules/storage_module_1000000000000_5_[addr].replica.2.9 \
   [data_dir]/storage_modules/storage_module_5000000000000_6000000000000_[addr].replica.2.9
```

5. Add all your storage modules back to the converted config: whole-partition modules as `partition` entries, custom-size modules with their computed `range_start` / `range_end`:

```yaml
storage_modules:
  - partition: 0
    packing_format: replica_2_9
    packing_address: "[addr]"
  - range_start: 5000000000000
    range_end: 6000000000000
    packing_format: replica_2_9
    packing_address: "[addr]"
```

6. Start the node with the converted config and confirm each module finds its data.

Only custom-bucket-size modules need the rename - whole-partition directories (`storage_module_[partition]_[packing]`) keep their names.

# 2. Converting a Launch Command

If you configure your node on the command line rather than in a file, translate each legacy argument to its `--` flag. For example:

```sh
# Legacy:
./bin/start \
    enable randomx_large_pages \
    peer 188.166.200.45 \
    data_dir /opt/data \
    mine \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI

# Current:
./bin/start \
    --randomx.large_pages \
    --peers.trusted 188.166.200.45 \
    --data_dir /opt/data \
    --mining.enabled \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI
```

For list-heavy configurations, move the configuration into a YAML or JSON file. Lists and structured options such as storage modules *can* be passed as a single-quoted JSON value (`--peers.trusted '["a:1984", "b:1984"]'` - a repeated flag doesn't accumulate, the last occurrence wins), but a file is easier to read and maintain.

# 3. Gotchas

## 3.1 One Style Per Launch

The node decides which configuration style a launch uses by inspecting its arguments and environment: if any `--long` flag or any recognized `AR_*` environment variable is present, the **entire launch** is parsed in the current style; otherwise it is parsed in the legacy style. The two styles cannot be mixed in one launch - a single `AR_*` variable (for example an `AR_PORT` exported in your shell profile) flips the whole launch to the current style, and legacy tokens like `mine` or `data_dir /opt/data` will then be rejected as unknown arguments. Convert the whole command line and config file together.

## 3.2 Dotted vs. Nested Keys

Dotted keys are only valid on the command line (`--mining.enabled`) and in environment variable names (`AR_MINING_ENABLED`) - in config files they are not valid, and every option must be written as a nested object. When hand-converting a config, translate each dotted key into its nested form (`mining.enabled` becomes `enabled:` under a `mining:` block). See [Configuring Your Node](configuration.md#2-the-configuration-file).

## 3.3 DNS Hostnames in Peer Lists

`convert_config` preserves peer entries exactly as you wrote them - hostnames stay hostnames and are never resolved during conversion (converting works offline). Resolution happens when the node loads the config, at every startup, just as it did with your legacy file - so round-robin DNS names like `peers.arweave.xyz` keep re-resolving over time. A trusted-peer entry that fails to resolve at startup is logged and skipped; the node boots with the remaining peers.
