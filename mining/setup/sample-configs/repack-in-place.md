---
description: >-
  Example arweave configuration for repacking-in-place
---

{% hint style="info" %}
- When repacking you do not need a private key - you will only need a mining address (aka packing address)
- Your mining address is **not** a private key - it is a public address
- For the following examples we will alway use `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` and `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY` as mining addresses. **Replace them with your own address(es) before running the sample commands.**
{% endhint %}

# 1. Overview

- You've been solo mining against 4 partitions of packed data
- You want to repack it so you can join a mining pool
- You want to repack in place so you don't need any extra storage capacity
- Your packed data is stored on 4TB disks and is packed using the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
- You want to repack your data to the mining address `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY`
- You'll use one of the DHA-provided public VDF servers
- **NOTE** Unlike with the other two repacking processes ("Sync and Pack" and "Cross-Module Repack"), you will **not** need to split up the "Repacking in Place" process into two steps. Entropy generation and repacking will happen in a single step.
- Run your miner with:
  - the special `repack_in_place` syntax for your storage modules
  - `vdf_server_trusted_peer vdf-server-3.arweave.xyz` to use the DHA-provided VDF server
- After the repack in place completes you'll need to rename all your storage module directories
- See [Running Your Node](../configuration.md) for more information


2. Sample Directory Structure

- Mount points for 4TB disks that store your packed data:
    - `/mnt/a`
    - `/mnt/b`
    - `/mnt/c`
    - `/mnt/d`
- `data_dir`: `/opt/data`
- Storage module symlinks:
    - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a`
    - `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b`
    - `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/c`
    - `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/d`
- Wallets: no wallet.json needed since you are only packing

3. Sample Command-line Configuration

```
./bin/start \
    enable randomx_large_pages \
    peer peers.arweave.xyz \
    data_dir /opt/data \
    sync_jobs 200 \
    vdf_server_trusted_peer vdf-server-3.arweave.xyz \
    mining_addr Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY \
    storage_module 0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9 \
    storage_module 1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9 \
    storage_module 2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9 \
    storage_module 3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9 
```

4. Sample Configuration File (config.json)

```
{
    "enable": [ "randomx_large_pages" ],

    "peers": [ "peers.arweave.xyz" ],

    "data_dir": "/opt/data",

    "vdf_server_trusted_peers": [ "vdf-server-3.arweave.xyz" ],
    
    "storage_modules": [
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9",
        "1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9",
        "2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9",
        "3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9"
    ],
     
    "mining_addr": "Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY",

    "sync_jobs": 200
  }

```

{% hint style="warning" %}
After repacking in place has completed, stop your node and rename your directories, eg.
```
mv /opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR.replica.2.9 /opt/data/storage_modules/storage_module_0_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9

mv /opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR.replica.2.9 /opt/data/storage_modules/storage_module_1_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9

mv /opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR.replica.2.9 /opt/data/storage_modules/storage_module_2_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9

mv /opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR.replica.2.9 /opt/data/storage_modules/storage_module_3_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9
```
{% endhint %}
