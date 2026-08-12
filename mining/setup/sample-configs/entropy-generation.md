---
description: >-
  Example arweave configurations for entropy generation.
---

{% hint style="info" %}
- For the following examples we will alway use `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` or `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY` as mining addresses. **Replace them with your own address(es) before running the sample commands.**
{% endhint %}

# 1. Overview

- You're just getting started and want to generate entropy before you sync and pack your data
- You'll pack the data to 16TB disks using the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
- You'll use one of the DHA-provided public VDF servers
- You'll use the publicly available NSFW filter provided by Shepherd
- Run your miner with:
  - `sync.jobs: 0`
  - `packing.entropy.workers` greater than 0 (default is fine)
- Wait until you see a message like the following for each storage module:
    - Console: `The storage module X is prepared for 2.9 replication.`
    - Log: `event: storage_module_entropy_preparation_complete, store_id: X`
- See [Running Your Node](../running.md) for more information

# 2. Sample Directory Structure

- Mount points for 16TB disks that will store the packed data:
    - `/mnt/a`
    - `/mnt/b`
- `data_dir`: `/opt/data`
- Storage module symlinks:
    - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 ` ->  `/mnt/a/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 ` ->  `/mnt/b/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

# 3. Sample Launch Command

Launch your node with the configuration file shown in the next section:

```sh
./bin/start --config_file /opt/arweave/config.yaml
```

# 4. Sample Configuration

The same configuration in YAML, JSON, and command-line form:

{% tabs %}
{% tab title="YAML" %}
`/opt/arweave/config.yaml`:

```yaml
data_dir: /opt/data
peers:
  trusted:
    - peers.arweave.xyz
  vdf_server:
    - vdf-server-3.arweave.xyz
randomx:
  large_pages: true
mining:
  address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
sync:
  jobs: 0
transactions:
  blocklist:
    urls:
      - "https://public_shepherd.arweave.net"
storage_modules:
  - partition: 0
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 1
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 2
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 3
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 4
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 5
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 6
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 7
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
```
{% endtab %}

{% tab title="JSON" %}
`/opt/arweave/config.json`:

```json
{
    "data_dir": "/opt/data",
    "peers": {
        "trusted": ["peers.arweave.xyz"],
        "vdf_server": ["vdf-server-3.arweave.xyz"]
    },
    "randomx": {
        "large_pages": true
    },
    "mining": {
        "address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
    },
    "sync": {
        "jobs": 0
    },
    "transactions": {
        "blocklist": {
            "urls": ["https://public_shepherd.arweave.net"]
        }
    },
    "storage_modules": [
        { "partition": 0, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 1, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 2, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 3, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 4, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 5, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 6, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 7, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" }
    ]
}
```
{% endtab %}

{% tab title="CLI" %}
With the CLI form there is no config file - every option is passed as a flag, with list options as a single-quoted JSON value (see [Command-line Flags](../configuration.md#3-command-line-flags) for the value syntax). The pre-2.9.6 space-separated launch style also still works ([Legacy Configuration](../legacy-configuration.md)). For example:

```sh
./bin/start \
    --data_dir /opt/data \
    --peers.trusted '["peers.arweave.xyz"]' \
    --peers.vdf_server '["vdf-server-3.arweave.xyz"]' \
    --randomx.large_pages \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    --sync.jobs 0 \
    --transactions.blocklist.urls '["https://public_shepherd.arweave.net"]' \
    --storage_modules '[
        {"partition": 0, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 1, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 2, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 3, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 4, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 5, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 6, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 7, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"}]'
```
{% endtab %}
{% endtabs %}
