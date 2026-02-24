---
description: >-
  A guide to server-side rate-limiting
---

{% hint style="warning" %}
This page documents a change introduced in version **2.9.6-alpha1**
{% endhint %}

# 1. Rate limiter

To regulate resource use, the arweave node implements rate limiting groups on HTTP endpoints. Endpoints are freely mapped to different groups.

Each group can be independently configured to fit different load profiles.

A list of local nodes in exempt from the rate limiting logic. This list with the peers addresses can be provided in the configuration.

## 1.1 Purpose

The arweave node aims to handle uneven load with mitigate possible starvation.

## 1.2 Hybrid rate limiting

The arweave node implements a hybrid rate-limiting algorithm; a composition of concurrency-monitoring, sliding windows, and leaky bucket limiting. 

By configuration, sliding windows, or leak bucket limiting can be disabled, or be used in combination, but their order of precendence can't be changed.

### 1.2.1 Concurrency

Each pool has an arbitrary limit for the allowed concurrent requests being handled. Once the limit is reached further requests will be rejected.

Please note, that the webservice has a global concurrency limit as well.

### 1.2.2 Sliding Windows

If the concurrency limit is not breached, requests are validated against a Sliding Windows limiter. If the load is within the configured rate for the configured interval, the request will be processed.
However, if the load is over the configured profile, the validation falls back to the Leaky Bucket Tokens algorithm

### 1.2.3 Leaky Bucket Tokens

A leaky bucket token rate limiter is a traffic-shaping algorithm that enforces a steady request rate by adding tokens to a bucket at a fixed rate and allowing requests only when a token is available, effectively smoothing bursts and preventing overload.

Once the leaky bucket tokens are exhausted (limit is reached) the request will be rejected, there is no further option to fall back to.

# 2. Configuration

## 2.1 List of rate limiting groups

- general
- chunk
- data_sync_record
- recent_hash_list_diff
- block_index
- wallet_list
- get_vdf
- get_vdf_session
- get_previous_vdf_session
- metrics

## 2.2 Config parameters

| Name                                                         | Type    | Default Value                                                                 | Description                                                                                          |
|--------------------------------------------------------------|---------|-------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| http_api.limiter.<group_id>.sliding_window_limit             | Number  | 0                                                                             | Amount of requests allowed in Sliding Window limiter                                                 |
| http_api.limiter.<group_id>.sliding_window_duration          | Number  | 1000                                                                          | Sliding Window interval length in milliseconds                                                       |
| http_api.limiter.<group_id>.sliding_window_timestamp_cleanup_interval | Number  | 120000                                                                        | How often sliding window cleanup routine runs (milliseconds)                                         |
| http_api.limiter.<group_id>.sliding_window_timestamp_cleanup_expiry   | Number  | 120000                                                                        | Interval of inactivity after which cleanup routine removes peer from the registry                   |
| http_api.limiter.<group_id>.leaky_limit                      | Number  | general: 450<br>chunk: 6000<br>data_sync_record: 20<br>recent_hash_list_diff: 120<br>block_index: 10<br>wallet_list: 10<br>get_vdf: 90<br>get_vdf_session: 30<br>get_previous_vdf_session: 30<br>metrics: 2 | Leaky bucket token limit; requests beyond this start to be rejected                                  |
| http_api.limiter.<group_id>.leaky_tick_interval              | Number  | 30000                                                                         | Leaky bucket token reduction interval (how often tokens are reduced), in milliseconds               |
| http_api.limiter.<group_id>.leaky_tick_reduction             | Number  | same as leaky_limit                                                           | Number of leaky bucket tokens removed in one run                                                     |
| http_api.limiter.<group_id>.concurrency_limit                | Number  | same as leaky_limit                                                           | Number of concurrent requests allowed per peer                                                       |
| http_api.limiter.<group_id>.is_manual_reduction_disabled     | Boolean | False                                                                         | Whether external requests can reduce leaky tokens                                                    |

## 2.3 Example

```
{
    "enable": [ "randomx_large_pages" ],
    "peers": [
        "chain-1.arweave.xyz",
        "data-2.arweave.xyz",
        "data-3.arweave.xyz",
        "data-4.arweave.xyz",
        "vdf-server-3.arweave.xyz"
    ],
    "data_dir": "/opt/data_dir",
    "vdf_server_trusted_peers": ["vdf-server-3.arweave.xyz"	],
    "transaction_blacklist_urls": ["https://public_shepherd.arweave.net"],

    "storage_modules": [
        "0,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9"
    ],
    "mining_addr": "En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI",

    "max_connections": 250,

    "http_api.limiter.general.sliding_window_limit": 0,
    "http_api.limiter.general.leaky_limit": 450,
    "http_api.limiter.general.leaky_tick_interval": 30000,
    "http_api.limiter.general.leaky_tick_reduction": 450,

    "sync_jobs": 0
}
```

# 3. Metrics

Following metrics are provided per rate-limiting group.

| Name | Type | Description |
|------|------|-------------|
| ar_limiter_response_time_microseconds	| Histogram | Time it took for the limiter to respond to requests|
| ar_limiter_requests_total | Counter | The number of requests the limiter has processed |
| ar_limiter_rejected_total	| Counter |	The number of request were rejected by the limiter |
| ar_limiter_reduce_requests_total | Counter | The number of reduce request by peer in total. (This reduction is requested by the handler when a transaction is successful) |
| ar_limiter_peers | Gauge | The number of peers the limiter is monitoring currently (Connection, Memory) |
| ar_limiter_tracked_items_total | Gauge | The number of timestamps, leaky tokens, concurrent processes are tracked (Memory leaks, process memory use) |
|ar_limiter_leaky_ticks | Counter | The number of leaky bucket ticks the limiter has processed 
(Perhaps, overkill, should confirm correctness of behaviour, when there is no peer to drop etc) |
| ar_limiter_leaky_tick_delete_peer_total | Counter | The number of times a peer has been dropped from the leaky bucket token register |
| ar_limiter_cleanup_tick_expired_sliding_peers_deleted_total | Counter | The number of times a peer has been dropped from the sliding window timestamp register - how many peers have been deleted |
| ar_limiter_leaky_tick_token_reductions_total | Counter | All the consumed leaky bucket tokens that were reduced for all peers in total (How much of the burst is being used) |
| ar_limiter_leaky_tick_reductions_peer | Counter | The times a leaky bucket token reduction had have to be performed for a peer - how many peers have burned tokens|
