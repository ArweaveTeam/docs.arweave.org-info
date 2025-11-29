---
description: >-
  Example arweave configuration for coordinated mining
---

{% hint style="info" %}
- When mining your Exit Node needs to have a valid wallet installed - see [Node Wallet](../node-wallet.md)
- For the following examples we will alway use `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` or `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY` as mining addresses. **Replace them with your own address(es) before running the sample commands.**
{% endhint %}

# 1. Overview

- Please review the [Coordinated Mining](../../overview/coordinated-mining.md) guide for more information
- You are running a coordinated mining cluster with the following nodes:
  - Exit Node at IP:PORT 10.0.0.100:1984
  - Worker 1 at IP:PORT 10.0.0.101:1985
  - Worker 2 at IP:PORT 10.0.0.102:1986
- You've downloaded and packed all your data to 16TB disks using the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
- Each miner has 4 partitions
- You'll use one of the DHA-provided public VDF servers forwarded through your Exit Node
- You'll use the publicly available NSFW filter provided by Shepherd
- See the [Coordinated Mining](../../overview/coordinated-mining.md) guiide  and [Running Your Node](../configuration.md) for more information

# 2. Sample Directory Structure

## 2.1 Exit Node Directory Structure

- `data_dir`: `/opt/data`

## 2.2 Worker 1 Directory Strcuture

- Mount point for 16TB disk that will store the packed data:
    - `/mnt/a`
- `data_dir`: `/opt/data`
- Storage module symlinks:
    - `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 ` ->  `/mnt/a/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/a/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

## 2.2 Worker 2 Directory Strcuture

- Mount point for 16TB disk that will store the packed data:
    - `/mnt/b`
- `data_dir`: `/opt/data`
- Storage module symlinks:
    - `/opt/data/storage_modules/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 ` ->  `/mnt/b/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
    - `/opt/data/storage_modules/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` ->  `/mnt/b/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

# 3.Sample Command-line Configuration

## 3.1 Exit Node Command-line Configuration

```
./bin/start \
    enable randomx_large_pages \
    peer peers.arweave.xyz \
    data_dir /opt/data \
    transaction_blacklist_url https://public_shepherd.arweave.net \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    coordinated_mining \
    local_peer 10.0.0.101:1985 \
    local_peer 10.0.0.102:1986 \
    cm_peer 10.0.0.101:1985 \
    cm_peer 10.0.0.102:1986 \
    cm_api_secret arweave_is_great_right \
    vdf_server_trusted_peer vdf-server-3.arweave.xyz \
    vdf_server_trusted_peer vdf-server-4.arweave.xyz \
    vdf_client_peer 10.0.0.101:1985 \
    vdf_client_peer 10.0.0.102:1986
```

## 3.2 Worker 1 Command-line Configuration

./bin/start \
    enable randomx_large_pages \
    peer peers.arweave.xyz \
    data_dir /opt/data \
    transaction_blacklist_url https://public_shepherd.arweave.net \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    port 1985 \
    coordinated_mining \
    local_peer 10.0.0.100:1984 \
    local_peer 10.0.0.102:1986 \
    cm_peer 10.0.0.100:1984 \
    cm_peer 10.0.0.102:1986 \
    cm_api_secret arweave_is_great_right \
    cm_exit_peer 10.0.0.100:1984  \
    vdf_server_trusted_peer 10.0.0.100:1984 \
    storage_module 0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 1,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 2,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 3,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 

## 3.3 Worker 2 Command-line Configuration

./bin/start \
    enable randomx_large_pages \
    peer peers.arweave.xyz \
    data_dir /opt/data \
    transaction_blacklist_url https://public_shepherd.arweave.net \
    mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    port 1986 \
    coordinated_mining \
    local_peer 10.0.0.100:1984 \
    local_peer 10.0.0.102:1985 \
    cm_peer 10.0.0.100:1984 \
    cm_peer 10.0.0.102:1985 \
    cm_api_secret arweave_is_great_right \
    cm_exit_peer 10.0.0.100:1984  \
    vdf_server_trusted_peer 10.0.0.100:1984 \
    storage_module 4,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 5,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 6,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 \
    storage_module 7,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 