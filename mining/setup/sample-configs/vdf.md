---
description: >-
  Example arweave configuration for a VDF server
---

{% hint style="info" %}
- Since VDF server will not mine or sign any blocks, they do not need access to your wallet.json
{% endhint %}

# 1. Overview

- You'd like to run a dedicated node to compute and publish VDF
- You are running on an Apple M4 processor (the fastest benchmarked processor as of September, 2025)
- You've decided not to configure any storge modules no have your VDF server mine (this is the most common setup)
- You'll use the publicly available NSFW filter provided by Shepherd
- You only want to provide VDF for the following nodes:
  - `1.2.3.4`
  - `5.6.7.8`
  - `5.6.7.8:1985`
  - `node.example.com`
- Run your VDF server with:
  - `peers.vdf_client` set to restrict which nodes can query your server's VDF
  - `vdf.algorithm: hiopt_m4` to enable a VDF algorithm optimized for the M4 processor
  - `peers.local` set to include the nodes you provide vdf for
- Run your nodes with:
  - `peers.local` set to include the VDF node address

# 2. Sample Directory Structure

- `data_dir`: `/opt/data`
- Storage module symlinks: None

# 3. Sample Launch Command

Launch your VDF server with the configuration file shown in the next section:

```sh
./bin/start --config_file /opt/arweave/config.yaml
```

# 4. Sample Configuration File (config.yaml)

```yaml
data_dir: /opt/data
peers:
  trusted:
    - peers.arweave.xyz
  vdf_client:
    - 1.2.3.4
    - 5.6.7.8
    - 5.6.7.8:1985
    - node.example.com
  local:
    - 1.2.3.4
    - 5.6.7.8
    - 5.6.7.8:1985
    - node.example.com
randomx:
  large_pages: true
vdf:
  algorithm: hiopt_m4
transactions:
  blocklist:
    urls:
      - "https://public_shepherd.arweave.net"
```
