---
description: Example arweave configuration for coordinated mining
---

# Coordinated Mining

{% hint style="info" %}
* When mining your Exit Node needs to have a valid wallet installed - see [Node Wallet](https://github.com/ArweaveTeam/docs.arweave.org-info/blob/master/mining/setup/node-wallet.md)
* For the following examples we will alway use `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI` or `Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY` as mining addresses. **Replace them with your own address(es) before running the sample commands.**
{% endhint %}

## 1. Overview

* Please review the [Coordinated Mining](../../overview/coordinated-mining.md) guide for more information
* You are running a coordinated mining cluster with the following nodes:
  * Exit Node at IP:PORT 10.0.0.100:1984
  * Worker 1 at IP:PORT 10.0.0.101:1985
  * Worker 2 at IP:PORT 10.0.0.102:1986
* You've downloaded and packed all your data to 16TB disks using the mining address `En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
* Each miner has 4 partitions
* You'll use one of the DHA-provided public VDF servers forwarded through your Exit Node
* You'll use the publicly available NSFW filter provided by Shepherd
* See the [Coordinated Mining](../../overview/coordinated-mining.md) guiide and [Running Your Node](../running.md) for more information

## 2. Sample Directory Structure

### 2.1 Exit Node Directory Structure

* `data_dir`: `/opt/data`

### 2.2 Worker 1 Directory Strcuture

* Mount point for 16TB disk that will store the packed data:
  * `/mnt/a`
* `data_dir`: `/opt/data`
* Storage module symlinks:
  * `/opt/data/storage_modules/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_0_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_1_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_2_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/a/storage_module_3_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

### 2.2 Worker 2 Directory Strcuture

* Mount point for 16TB disk that will store the packed data:
  * `/mnt/b`
* `data_dir`: `/opt/data`
* Storage module symlinks:
  * `/opt/data/storage_modules/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_4_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_5_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
  * `/opt/data/storage_modules/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9` -> `/mnt/b/storage_module_7_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

## 3. Sample Configuration

Each node gets its own configuration, shown below in YAML, JSON, and command-line form. Run `./bin/arweave config help cm` for more information on the coordinated mining options.

### 3.1 Exit Node Configuration

{% tabs %}
{% tab title="YAML" %}
`/opt/arweave/config.yaml`:

```yaml
data_dir: /opt/data
peers:
  trusted:
    - peers.arweave.xyz
  local:
    - 10.0.0.101:1985
    - 10.0.0.102:1986
  cm_peer:
    - 10.0.0.101:1985
    - 10.0.0.102:1986
  vdf_server:
    - vdf-server-3.arweave.xyz
    - vdf-server-4.arweave.xyz
  vdf_client:
    - 10.0.0.101:1985
    - 10.0.0.102:1986
randomx:
  large_pages: true
mining:
  address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
cm:
  enabled: true
  api_secret: perma_secret
transactions:
  blocklist:
    urls:
      - "https://public_shepherd.arweave.net"
```

Launch command:

```sh
./bin/start --config_file /opt/arweave/config.yaml
```
{% endtab %}

{% tab title="JSON" %}
`/opt/arweave/config.json`:

```json
{
    "data_dir": "/opt/data",
    "peers": {
        "trusted": ["peers.arweave.xyz"],
        "local": ["10.0.0.101:1985", "10.0.0.102:1986"],
        "cm_peer": ["10.0.0.101:1985", "10.0.0.102:1986"],
        "vdf_server": ["vdf-server-3.arweave.xyz", "vdf-server-4.arweave.xyz"],
        "vdf_client": ["10.0.0.101:1985", "10.0.0.102:1986"]
    },
    "randomx": {
        "large_pages": true
    },
    "mining": {
        "address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
    },
    "cm": {
        "enabled": true,
        "api_secret": "perma_secret"
    },
    "transactions": {
        "blocklist": {
            "urls": ["https://public_shepherd.arweave.net"]
        }
    }
}
```

Launch command:

```sh
./bin/start --config_file /opt/arweave/config.json
```
{% endtab %}

{% tab title="CLI" %}
With the CLI form there is no config file - every option is passed as a flag, with list options as a single-quoted JSON value (see [Command-line Flags](../configuration.md#3-command-line-flags) for the value syntax). The pre-2.9.6 space-separated launch style also still works ([Legacy Configuration](../legacy-configuration.md)). For example:

```sh
./bin/start \
    --data_dir /opt/data \
    --peers.trusted '["peers.arweave.xyz"]' \
    --peers.local '["10.0.0.101:1985", "10.0.0.102:1986"]' \
    --peers.cm_peer '["10.0.0.101:1985", "10.0.0.102:1986"]' \
    --peers.vdf_server '["vdf-server-3.arweave.xyz", "vdf-server-4.arweave.xyz"]' \
    --peers.vdf_client '["10.0.0.101:1985", "10.0.0.102:1986"]' \
    --randomx.large_pages \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    --cm.enabled \
    --cm.api_secret perma_secret \
    --transactions.blocklist.urls '["https://public_shepherd.arweave.net"]'
```
{% endtab %}
{% endtabs %}

### 3.2 Worker 1 Configuration

{% tabs %}
{% tab title="YAML" %}
`/opt/arweave/config.yaml`:

```yaml
data_dir: /opt/data
peers:
  trusted:
    - peers.arweave.xyz
  local:
    - 10.0.0.100:1984
    - 10.0.0.102:1986
  cm_peer:
    - 10.0.0.100:1984
    - 10.0.0.102:1986
  cm_exit: 10.0.0.100:1984
  vdf_server:
    - 10.0.0.100:1984
randomx:
  large_pages: true
mining:
  address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
cm:
  enabled: true
  api_secret: perma_secret
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
```

Launch command (the `--port` flag overrides any value in the configuration file):

```sh
./bin/start --config_file /opt/arweave/config.yaml --port 1985
```
{% endtab %}

{% tab title="JSON" %}
`/opt/arweave/config.json`:

```json
{
    "data_dir": "/opt/data",
    "peers": {
        "trusted": ["peers.arweave.xyz"],
        "local": ["10.0.0.100:1984", "10.0.0.102:1986"],
        "cm_peer": ["10.0.0.100:1984", "10.0.0.102:1986"],
        "cm_exit": "10.0.0.100:1984",
        "vdf_server": ["10.0.0.100:1984"]
    },
    "randomx": {
        "large_pages": true
    },
    "mining": {
        "address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
    },
    "cm": {
        "enabled": true,
        "api_secret": "perma_secret"
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
        { "partition": 3, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" }
    ]
}
```

Launch command (the `--port` flag overrides any value in the configuration file):

```sh
./bin/start --config_file /opt/arweave/config.json --port 1985
```
{% endtab %}

{% tab title="CLI" %}
With the CLI form there is no config file - every option is passed as a flag, with list options as a single-quoted JSON value (see [Command-line Flags](../configuration.md#3-command-line-flags) for the value syntax). The pre-2.9.6 space-separated launch style also still works ([Legacy Configuration](../legacy-configuration.md)). For example:

```sh
./bin/start \
    --data_dir /opt/data \
    --port 1985 \
    --peers.trusted '["peers.arweave.xyz"]' \
    --peers.local '["10.0.0.100:1984", "10.0.0.102:1986"]' \
    --peers.cm_peer '["10.0.0.100:1984", "10.0.0.102:1986"]' \
    --peers.cm_exit 10.0.0.100:1984 \
    --peers.vdf_server '["10.0.0.100:1984"]' \
    --randomx.large_pages \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    --cm.enabled \
    --cm.api_secret perma_secret \
    --transactions.blocklist.urls '["https://public_shepherd.arweave.net"]' \
    --storage_modules '[
        {"partition": 0, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 1, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 2, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 3, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"}]'
```
{% endtab %}
{% endtabs %}

### 3.3 Worker 2 Configuration

{% tabs %}
{% tab title="YAML" %}
`/opt/arweave/config.yaml`:

```yaml
data_dir: /opt/data
peers:
  trusted:
    - peers.arweave.xyz
  local:
    - 10.0.0.100:1984
    - 10.0.0.101:1985
  cm_peer:
    - 10.0.0.100:1984
    - 10.0.0.101:1985
  cm_exit: 10.0.0.100:1984
  vdf_server:
    - 10.0.0.100:1984
randomx:
  large_pages: true
mining:
  address: "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
cm:
  enabled: true
  api_secret: perma_secret
transactions:
  blocklist:
    urls:
      - "https://public_shepherd.arweave.net"
storage_modules:
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

Launch command:

```sh
./bin/start --config_file /opt/arweave/config.yaml --port 1986
```
{% endtab %}

{% tab title="JSON" %}
`/opt/arweave/config.json`:

```json
{
    "data_dir": "/opt/data",
    "peers": {
        "trusted": ["peers.arweave.xyz"],
        "local": ["10.0.0.100:1984", "10.0.0.101:1985"],
        "cm_peer": ["10.0.0.100:1984", "10.0.0.101:1985"],
        "cm_exit": "10.0.0.100:1984",
        "vdf_server": ["10.0.0.100:1984"]
    },
    "randomx": {
        "large_pages": true
    },
    "mining": {
        "address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"
    },
    "cm": {
        "enabled": true,
        "api_secret": "perma_secret"
    },
    "transactions": {
        "blocklist": {
            "urls": ["https://public_shepherd.arweave.net"]
        }
    },
    "storage_modules": [
        { "partition": 4, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 5, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 6, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" },
        { "partition": 7, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI" }
    ]
}
```

Launch command:

```sh
./bin/start --config_file /opt/arweave/config.json --port 1986
```
{% endtab %}

{% tab title="CLI" %}
With the CLI form there is no config file - every option is passed as a flag, with list options as a single-quoted JSON value (see [Command-line Flags](../configuration.md#3-command-line-flags) for the value syntax). The pre-2.9.6 space-separated launch style also still works ([Legacy Configuration](../legacy-configuration.md)). For example:

```sh
./bin/start \
    --data_dir /opt/data \
    --port 1986 \
    --peers.trusted '["peers.arweave.xyz"]' \
    --peers.local '["10.0.0.100:1984", "10.0.0.101:1985"]' \
    --peers.cm_peer '["10.0.0.100:1984", "10.0.0.101:1985"]' \
    --peers.cm_exit 10.0.0.100:1984 \
    --peers.vdf_server '["10.0.0.100:1984"]' \
    --randomx.large_pages \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
    --cm.enabled \
    --cm.api_secret perma_secret \
    --transactions.blocklist.urls '["https://public_shepherd.arweave.net"]' \
    --storage_modules '[
        {"partition": 4, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 5, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 6, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"},
        {"partition": 7, "packing_format": "replica_2_9", "packing_address": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI"}]'
```
{% endtab %}
{% endtabs %}
