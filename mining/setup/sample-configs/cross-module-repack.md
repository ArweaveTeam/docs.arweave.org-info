---
description: >-
  Example arweave configuration for cross-module repacking
---


{% hint style="info" %}
- When repacking you do not need a private key - you will only need a mining address (aka packing address)
- Your mining address is **not** a private key - it is a public address
- For the following examples we will alway use `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` and `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY` as mining addresses. **Replace them with your own address(es) before running the sample commands.**
{% endhint %}

# 1. Overview

- You've downloaded 4 partitions of unpacked data
- You want to pack it so you can mine against it
- You've downloaded the unpacked partitions to an 16TB disk
- You'll pack the data to 4TB disks using the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
- You'll use the `replica.2.9` packing format
- You'll use one of the DHA-provided public VDF servers
- You'll use the publicly available NSFW filter provided by Shepherd
- Run your miner with:
  - `sync.jobs: 0` to prevent it from trying to sync while you repack
  - each partition listed twice under `storage_modules`, once with `packing_format: unpacked` and once with `packing_format: replica_2_9` and your packing address
- See [Running Your Node](../running.md) for more information

# 2. Sample Directory Structure

- Unpacked data mount point: `/mnt/unpacked`
- Mount points for 4TB disks that will store the packed data:
    - `/mnt/a`
    - `/mnt/b`
    - `/mnt/c`
    - `/mnt/d`
- `data_dir`: `/opt/data`
- Storage module symlinks:
    - `/opt/data/storage_modules/storage_module_0_unpacked` -> `/mnt/unpacked/storage_module_0_unpacked`
    - `/opt/data/storage_modules/storage_module_1_unpacked` -> `/mnt/unpacked/storage_module_1_unpacked`
    - `/opt/data/storage_modules/storage_module_2_unpacked` -> `/mnt/unpacked/storage_module_2_unpacked`
    - `/opt/data/storage_modules/storage_module_3_unpacked` -> `/mnt/unpacked/storage_module_3_unpacked`
    - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/c/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/d/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

# 3. Sample Launch Command

Launch your node with the configuration file shown in the next section:

```sh
./bin/start --config_file /opt/arweave/config.yaml
```

# 4. Sample Configuration File (config.yaml)

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
    packing_format: unpacked
  - partition: 0
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 1
    packing_format: unpacked
  - partition: 1
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 2
    packing_format: unpacked
  - partition: 2
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
  - partition: 3
    packing_format: unpacked
  - partition: 3
    packing_format: replica_2_9
    packing_address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
```
