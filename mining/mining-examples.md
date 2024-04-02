---
description: >-
  Example arweave configurations for common situations.
---

# Example Arweave Configurations

{% hint style="info" %}
### Note on wallets (aka private keys)
- When packing or repacking you do not need a private key - you will only need a mining address (aka packing address)
- Your mining address is **not** a private key - it is a public address
- When mining, only nodes that will sign blocks need to have a private key / wallet.json stored locally
- If your node will be part of a coordinated mining cluster (and is not the exit node) or is mining as part of a pool, it will never need your private key stored locally
- For the following examples we will alway use `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` and `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY` as mining addresses. **Replace them with your own address(es) before running the sample commands.**
{% endhint %}

## Packing Unpacked Data

### Situation
- You've downloaded 4 partitions of unpacked data
- You want to pack it so you can mine against it
- You've downloaded the unpacked partitiona to an 18TB disk
- You'll pack the data to 4TB disks using the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`

<details>
<summary>Sample Directory Structure</summary>

- Unpacked data mount point: `/mnt/unpacked`
- Mount points for 4TB disks that will store the packed data:
    - `/mnt/packed0`
    - `/mnt/packed1`
    - `/mnt/packed2`
    - `/mnt/packed3`
- `data_dir`: `/opt/data`
- Store module symlinks:
    - `/opt/data/storage_modules/storage_module_0_unpacked` -> `/mnt/unpacked/storage_module_0_unpacked`
    - `/opt/data/storage_modules/storage_module_1_unpacked` -> `/mnt/unpacked/storage_module_1_unpacked`
    - `/opt/data/storage_modules/storage_module_2_unpacked` -> `/mnt/unpacked/storage_module_2_unpacked`
    - `/opt/data/storage_modules/storage_module_3_unpacked` -> `/mnt/unpacked/storage_module_3_unpacked`
    - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed0`
    - `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed1`
    - `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed2`
    - `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed3`
- Wallets: no wallet.json needed since you are only packing
</details>

<details>
<summary>Sample Command-line Configuration</summary>

```
./bin/start \
    peer ams-1.eu-central-1.arweave.net \
    peer blr-1.ap-central-1.arweave.net \
    peer fra-1.eu-central-2.arweave.net
    peer sfo-1.na-west-1.arweave.net \
    peer sgp-1.ap-central-2.arweave.net \
    data_dir /opt/data \
    sync_jobs 200 \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    storage_module 0,unpacked \
    storage_module 0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    storage_module 1,unpacked \
    storage_module 1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    storage_module 2,unpacked \
    storage_module 2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    storage_module 3,unpacked \
    storage_module 3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI 
```
</details>

<details>
<summary>Sample Configuration File (config.json)</summary>

```
{
    "peers": [
      "ams-1.eu-central-1.arweave.net",
      "blr-1.ap-central-1.arweave.net",
      "fra-1.eu-central-2.arweave.net",
      "sfo-1.na-west-1.arweave.net",
      "sgp-1.ap-central-2.arweave.net"
    ],

    "data_dir": "/opt/data",

    "storage_modules": [
        "0,unpacked",
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",
        "1,unpacked",
        "1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",
        "2,unpacked",
        "2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",
        "3,unpacked",
        "3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
    ],
     
    "mining_addr": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",

    "sync_jobs": 200
}
```

## Repacking Packed Data In Place

### Situation
- You've been solo mining against 4 partitions of packed data
- You want to repack it so you can join a mining pool
- You want to repack in place so you don't need any extra storage capacity
- Your packed data is stored on 4TB disks and is packed with the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
- The new mining address is `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY`


<details>
<summary>Sample Directory Structure</summary>

- Mount points for 4TB disks that store your packed data:
    - `/mnt/packed0`
    - `/mnt/packed1`
    - `/mnt/packed2`
    - `/mnt/packed3`
- `data_dir`: `/opt/data`
- Store module symlinks:
    - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed0`
    - `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed1`
    - `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed2`
    - `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed3`
- Wallets: no wallet.json needed since you are only packing
</details>

<details>
<summary>Sample Command-line Configuration</summary>

```
./bin/start \
    peer ams-1.eu-central-1.arweave.net \
    peer blr-1.ap-central-1.arweave.net \
    peer fra-1.eu-central-2.arweave.net \
    peer sfo-1.na-west-1.arweave.net \
    peer sgp-1.ap-central-2.arweave.net \
    data_dir /opt/data \
    sync_jobs 200 \
    mining_addr Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY \
    storage_module 0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY \
    storage_module 1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY \
    storage_module 2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY \
    storage_module 3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY 
```
</details>

<details>
<summary>Sample Configuration File (config.json)</summary>

```
{
    "peers": [
      "ams-1.eu-central-1.arweave.net",
      "blr-1.ap-central-1.arweave.net",
      "fra-1.eu-central-2.arweave.net",
      "sfo-1.na-west-1.arweave.net",
      "sgp-1.ap-central-2.arweave.net"
    ],

    "data_dir": "/opt/data",

    "storage_modules": [
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY",
        "1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY",
        "2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY",
        "3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI,repack_in_place,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY"
    ],
     
    "mining_addr": "Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY",

    "sync_jobs": 200
  }

```
</details>

{% hint style="warning" %}
After repacking in place has completed, rename your directories, eg.
```
mv /opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR /opt/data/storage_modules/storage_module_0_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY

mv /opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR /opt/data/storage_modules/storage_module_1_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY

mv /opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR /opt/data/storage_modules/storage_module_2_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY

mv /opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZR /opt/data/storage_modules/storage_module_3_Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY
```

{% endhint %}


## Repairing a Corrupt RocksDB

### Situation
- When launching your node you get an error that mentions a specific RocksDB database (e.g. `ar_data_sync_chunk_db`)
- One solution is to attempt to repair the RocksDB


<details>
<summary>Sample Directory Structure</summary>

- 4TB disk for partition 0: /mnt/packed0
- data_dir: /opt/data
- Store module symlinks:
  - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` ->  `/mnt/packed0`
- RocksDB location:
  - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI/rocksdb/ar_data_sync_chunk_db`

</details>

<details>
<summary>Sample Command-line Configuration</summary>

```
./bin/start \
    peer ams-1.eu-central-1.arweave.net \
    peer blr-1.ap-central-1.arweave.net \
    peer fra-1.eu-central-2.arweave.net \
    peer sfo-1.na-west-1.arweave.net \
    peer sgp-1.ap-central-2.arweave.net \
    data_dir /opt/data \
    sync_jobs 200 \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    storage_module 0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    repair_rocksdb /opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI/rocksdb/ar_data_sync_chunk_db
```
</details>

<details>
<summary>Sample Configuration File (config.json)</summary>

```
{
    "peers": [
      "ams-1.eu-central-1.arweave.net",
      "blr-1.ap-central-1.arweave.net",
      "fra-1.eu-central-2.arweave.net",
      "sfo-1.na-west-1.arweave.net",
      "sgp-1.ap-central-2.arweave.net"
    ],

    "data_dir": "/opt/data",

    "storage_modules": [
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
    ],
     
    "mining_addr": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",

    "repair_rocksdb": [
        "/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI/rocksdb/ar_data_sync_chunk_db
    ],

    "sync_jobs": 200
  }

```
</details>