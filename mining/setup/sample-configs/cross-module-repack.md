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
  -  `sync_jobs 0` to prevent it from trying to sync while you repack
  - each `storage_module` defined twice, once as `unpacked` and once as `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
- See [Running Your Node](../configuration.md) for more information

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

# 3.Sample Command-line Configuration

```
./bin/start \
    enable randomx_large_pages \
    peer peers.arweave.xyz \
    data_dir /opt/data \
    sync_jobs 0 \
    vdf_server_trusted_peer vdf-server-3.arweave.xyz \
    transaction_blacklist_url https://public_shepherd.arweave.net \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    storage_module 0,unpacked \
    storage_module 0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 1,unpacked \
    storage_module 1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 2,unpacked \
    storage_module 2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 3,unpacked \
    storage_module 3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 
```

4. Sample Configuration File (config.json)

```
{
    "enable": [ "randomx_large_pages" ],
    "peers": [ "peers.arweave.xyz" ],
    "data_dir": "/opt/data",
    "vdf_server_trusted_peers": [ "vdf-server-3.arweave.xyz" ],
    "transaction_blacklist_urls": [ "https://public_shepherd.arweave.net" ],

    "storage_modules": [
        "0,unpacked",
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9",
        "1,unpacked",
        "1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9",
        "2,unpacked",
        "2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9",
        "3,unpacked",
        "3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9"
    ],
     
    "mining_addr": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",

    "sync_jobs": 0
}
```
