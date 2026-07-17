---
description: >-
  The pre-2.9.6 configuration style: space-separated command-line
  arguments and the flat config.json schema
---

# Legacy Configuration

Releases before Arweave 2.9.6 configured the node with space-separated command-line arguments and a flat `config.json` schema. This page documents that legacy style.

The legacy style still works: a launch with no `--long` flags and no recognized `AR_*` environment variables is parsed in the legacy style. The two styles cannot be mixed in a single launch, and we recommend the [current style](configuration.md) for new configurations - see [Migrating Your Configuration](migrating-config.md) for the option name mappings and the `convert_config` tool that converts a legacy `config.json` automatically.

# 1. Command-line Arguments

Legacy arguments are space-separated tokens with no `--` prefix: a boolean flag is a bare word (`mine`), an option is followed by its value (`data_dir /opt/data`), and repeatable options are given multiple times (one `storage_module` argument per storage module). Features are switched on and off with `enable` / `disable` (e.g. `enable randomx_large_pages`).

Legacy storage modules are described by a bucket size and index rather than a byte range: `storage_module [index],[packing]` covers one 3.6TB mining partition, and `storage_module [index],[bucket_size],[packing]` covers the range `[index * bucket_size, (index + 1) * bucket_size)` for a custom bucket size in bytes (e.g. `storage_module 0,2000000000000,[addr].replica.2.9` for the first 2 TB). The current config expresses these as explicit `range_start` / `range_end` byte ranges instead - including arbitrary ranges the bucket scheme cannot describe.

A legacy solo-mining launch:

```sh
./bin/start \
    enable randomx_large_pages \
    peer peers.arweave.xyz \
    data_dir /opt/data \
    mine \
    vdf_server_trusted_peer vdf-server-3.arweave.xyz \
    transaction_blacklist_url https://public_shepherd.arweave.net \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    storage_module 0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9
```

# 2. The `config.json` File

A legacy configuration file is always JSON, with a flat schema: option names at the top level, feature switches collected in `enable` / `disable` arrays, and storage modules written as `"partition,packing"` strings. The file is loaded with the `config_file` argument:

```sh
./bin/start config_file config.json
```

The same solo-mining configuration as a legacy `config.json`:

```json
{
    "enable": [ "randomx_large_pages" ],
    "peers": [ "peers.arweave.xyz" ],
    "data_dir": "/opt/data",
    "vdf_server_trusted_peers": [ "vdf-server-3.arweave.xyz" ],
    "transaction_blacklist_urls": [ "https://public_shepherd.arweave.net" ],

    "storage_modules": [
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9",
        "1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9"
    ],

    "mining_addr": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",

    "mine": true
}
```

Command-line arguments and a `config_file` can be combined, but we recommend against mixing the two as it can be confusing if there are conflicts between them.

# 3. Differences from the Current Style

- **Option names differ.** Flat legacy names map to the current dotted keys: `mine` → `mining.enabled`, `mining_addr` → `mining.address`, `peer` → `peers.trusted`, and so on. See [Migrating Your Configuration](migrating-config.md) for more information.
- **No environment variables.** The legacy style has no `AR_*` support - setting any recognized `AR_*` variable flips the whole launch to the current style, and legacy tokens like `mine` will then be rejected as unknown arguments.
- **No dynamic configuration.** [`config get` / `config set`](dynamic-configuration.md) operate on current-style dotted keys, on nodes new enough to support them.
- **JSON only.** Legacy config files are always JSON; YAML files are a current-style feature.
