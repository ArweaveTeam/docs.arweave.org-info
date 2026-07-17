---
description: Example arweave configuration for solo mining
---

# Solo Mining

{% hint style="info" %}
* When mining your node needs to have a valid wallet installed - see [Node Wallet](https://github.com/ArweaveTeam/docs.arweave.org-info/blob/master/mining/setup/node-wallet.md)
* For the following examples we will alway use `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` or `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY` as mining addresses. **Replace them with your own address(es) before running the sample commands.**
{% endhint %}

## 1. Overview

* You've downloaded and packed all your data to 16TB disks using the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
* You'll use one of the DHA-provided public VDF servers
* You'll use the publicly available NSFW filter provided by Shepherd
* Run your miner with:
  * `mining.enabled: true`
  * `peers.vdf_server` set to `vdf-server-3.arweave.xyz` to use the DHA-provided VDF server
* See [Running Your Node](../running.md) for more information

## 2. Sample Directory Structure

* Mount points for 16TB disks that will store the packed data:
  * `/mnt/a`
  * `/mnt/b`
* `data_dir`: `/opt/data`
* Storage module symlinks:
  * `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

## 3. Sample Launch Command

Launch your node with the configuration file shown in the next section:

```sh
./bin/start --config_file /opt/arweave/config.yaml
```

## 4. Sample Configuration File (config.yaml)

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
  enabled: true
  address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
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
