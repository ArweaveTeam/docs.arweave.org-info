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
- Run your miner with:
  - `vdf_client_peer` flags to restrict which nodes can query your server's VDF
  - `vdf hiopt_m4` to enable a VDF algorithm optimized for the M4 processor

# 2. Sample Directory Structure

- `data_dir`: `/opt/data`
- Storage module symlinks: None

# 3. Sample Command-line Configuration

```
./bin/start \
    enable randomx_large_pages \
    peer peers.arweave.xyz \
    data_dir /opt/data \
    transaction_blacklist_url https://public_shepherd.arweave.net \
    vdf hiopt_m4 \
    vdf_client_peer 1.2.3.4 \
    vdf_client_peer 5.6.7.8 \
    vdf_client_peer 5.6.7.8:1985 \
    vdf_client_peer node.example.com
```

# 4. Sample Configuration File (config.json)

```
{
    "enable": [ "randomx_large_pages" ],
    "peers": [ "peers.arweave.xyz" ],
    "data_dir": "/opt/data",
    "transaction_blacklist_urls": [ "https://public_shepherd.arweave.net" ],

    "vdf": "hiopt_m4",

    "vdf_client_peers": [
        "1.2.3.4",
        "5.6.7.8",
        "5.6.7.8:1985",
        "node.example.com"
    ]
}
```
