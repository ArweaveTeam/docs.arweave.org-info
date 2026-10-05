---
description: >-
  A guide to incoming HTTP rate limiting and outbound request throttling
---

{% hint style="info" %}
The rate limiter is available from Arweave **2.9.7**. Use `config help` on your installed node to check the options and defaults supported by that version.
{% endhint %}

# 1. Rate limiter

The Arweave node limits incoming HTTP requests to regulate resource use and handle uneven load. Endpoints are assigned to limiter groups, each of which can be configured independently.

## 1.1 Hybrid rate limiting

Requests are checked in this order: concurrency, sliding window, then leaky bucket. Sliding-window and leaky-bucket budgets are tracked per peer IP, ignoring the port.

### 1.1.1 Concurrency

Each pool has an arbitrary limit for the allowed concurrent requests being handled. Once the limit is reached further requests will be rejected.

The HTTP server also has a separate connection limit (`network.server.tcp.max_connections`).

### 1.1.2 Sliding window

After passing the concurrency check, a request is admitted if the peer has room within `sliding_window_limit` over the preceding `sliding_window_duration` milliseconds. Such requests consume only sliding-window budget.

Once the sliding-window budget is exhausted, requests fall through to the leaky bucket. Setting `sliding_window_limit` to `0` sends all requests directly to the bucket after the concurrency check.

### 1.1.3 Leaky bucket

The bucket tracks consumed capacity for each peer. Each admitted overflow request adds one token to this counter. Every `leaky_tick_ms` milliseconds, the worker drains up to `tick_reduction` tokens from each peer's counter. Requests are rejected when the sliding window is exhausted and the consumed bucket capacity has reached `leaky_rate_limit`.

Setting `leaky_rate_limit` to `0` disables the leaky bucket limiter, leaving only the sliding-window. For a group that limits requests, the two capacities cannot both be zero.

## 1.2 HTTP responses

Rate-limit and concurrency rejections return HTTP `429 Too Many Requests`. Limiter errors return HTTP `503 Service Unavailable`.

Limited responses advertise `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`, and `RateLimit-Reset-Amount` headers. `RateLimit-Limit` includes the group ID in its policy descriptions, `RateLimit-Remaining` reports remaining budget, and `RateLimit-Reset` is expressed in seconds. Rejections with zero remaining budget also include `Retry-After`; clients should wait before retrying. Bypass groups do not advertise these headers.

# 2. Limiter configuration

The canonical option reference is the help shipped with your node:

```sh
./bin/arweave config help limiter
```

The tables below describe production defaults. Test builds use different defaults for some groups.

## 2.1 Endpoint groups and defaults

| Group | Endpoints | Sliding limit / duration (ms) | Bucket capacity / drain per tick | Drain interval (ms) | Concurrency per worker |
|-------|-----------|------------------------------|----------------------------------|---------------------|------------------------|
| general | All endpoints not assigned below | 3 / 2000 | 450 / 450 | 30000 | 150 |
| chunk | `/chunk`, `/chunk2` and their sub-paths | 1000 / 1000 | 6000 / 6000 | 30000 | 200 |
| data_sync_record | `/data_sync_record` and its sub-paths | 0 / 1000 | 20 / 20 | 30000 | 40 |
| recent_hash_list_diff | `/recent_hash_list_diff` and its sub-paths | 0 / 1000 | 120 / 120 | 30000 | 240 |
| block_index | `/hash_list`, `/hash_list2`, `/block_index`, `/block_index2`, `/block/{type}/{id}/hash_list` | 0 / 1000 | 1 / 1 | 30000 | 2 |
| wallet_list | `/wallet_list`, `/block/{type}/{id}/wallet_list` | 0 / 1000 | 1 / 1 | 30000 | 2 |
| get_vdf | `/vdf`, `/vdf2` | 0 / 1000 | 180 / 180 | 30000 | 90 |
| get_vdf_session | `/vdf/session`, `/vdf2/session`, `/vdf3/session`, `/vdf4/session` | 0 / 1000 | 30 / 30 | 30000 | 30 |
| get_previous_vdf_session | `/vdf/previous_session`, `/vdf2/previous_session`, `/vdf4/previous_session` | 0 / 1000 | 30 / 30 | 30000 | 30 |
| metrics | `/metrics` and its sub-paths | 0 / 1000 | 2 / 2 | 1000 | 2 |
| local_peers | Every request from an IP listed in `peers.local`, regardless of path | Bypassed by default | Bypassed by default | No timer | Bypassed by default |

Local-peer membership is matched by IP, ignoring the port. The `local_peers` group has `no_limit: true` by default. Its ignored limit and timer defaults are internal `infinity` values; operators cannot supply `infinity`. To enable limiting for this group at startup, set `no_limit: false` and supply valid numeric values for all limit and timer fields.

## 2.2 Parameters and runtime support

All keys below have the prefix `limiter.<group_id>.`.

| Parameter | Type | Default | Runtime-writable | Description |
|-----------|------|---------|---dd---------------|-------------|
| sliding_window_limit | Non-negative integer | See group table | Yes | Per-peer sliding-window request budget; `0` disables this allowance |
| sliding_window_duration | Positive integer | See group table | Yes | Sliding-window width in milliseconds |
| leaky_rate_limit | Non-negative integer | See group table | Yes | Per-peer bucket capacity; `0` disables overflow allowance |
| leaky_tick_ms | Positive integer | See group table | No | Interval between bucket drains in milliseconds |
| tick_reduction | Positive integer | See group table | Yes | Maximum consumed tokens removed per peer on each drain tick |
| concurrency_limit | Positive integer | See group table | Yes | Maximum in-flight requests shared within each worker |
| timestamp_cleanup_tick_ms | Positive integer | 120000 | No | Interval between sliding-window cleanup sweeps, in milliseconds; expiry uses `sliding_window_duration` |
| is_external_reduction_enabled | Boolean | general: `true`; other groups: `false` | Yes | Allow explicit reduction calls from request handlers |
| no_limit | Boolean | local_peers: `true`; other groups: `false` | No | Bypass all limiting for the group |
| number_of_workers | Non-negative integer | 5; metrics and local_peers: 1 | No | Number of workers; use a positive count for an active group |

The numeric defaults above apply to limiting groups; `local_peers` uses ignored `infinity` defaults for its limit and timer fields. `sliding_window_duration`, `leaky_tick_ms`, and `timestamp_cleanup_tick_ms` must be between **1 and 86,400,000 milliseconds**, inclusive. `timestamp_cleanup_expiry` and `is_manual_reduction_disabled` are not current option names.

## 2.3 Example

This configuration fragment explicitly sets the general group's production defaults:

```yaml
limiter:
  general:
    sliding_window_limit: 3
    sliding_window_duration: 2000
    leaky_rate_limit: 450
    leaky_tick_ms: 30000
    tick_reduction: 450
    concurrency_limit: 150
    is_external_reduction_enabled: true
```

Pass the config file on startup (the file extension must be `.yaml` or `.json`):

```sh
./bin/start --config_file /path/to/config.yaml
```

Inspect or change a runtime-writable setting on a running node:

```sh
./bin/arweave config get limiter.general.leaky_rate_limit
./bin/arweave config set limiter.general.leaky_rate_limit 600
```

Runtime changes are not saved to the configuration file. See [Dynamic Configuration](../setup/dynamic-configuration.md) for prerequisites, validation, and persistence.

# 3. Outbound throttling

The client-side throttler learns a remote peer's quota and throttles requests accordingly. Once the remote peer's quota is exhausted, outgoing requests wait for budget. Requests for an unknown peer/path mapping initially proceed because no quota has been learned yet. Requests for peers that do not advertise the required headers will not be throttled at all.

Throttling groups are learned from remote responses; the `limiter` settings above control your node's incoming requests. The two `throttling` options control process lifecycle, rather than defining outbound requests-per-second limits.

```sh
./bin/arweave config help throttling
```

| Option | Type | Default | Runtime-writable | Description |
|--------|------|---------|------------------|-------------|
| throttling.idle_timeout | Positive integer | 60000 ms | Yes | Time a group process may remain idle before shutting down |
| throttling.max_processes | Positive integer | 1000 | Yes | Active-process threshold used when admitting a new, non-exempt throttling group |

A group is idle when it has received no throttle, throttle-status, or quota-update request for the configured interval, has no queued callers, and has no pending quota refill. Existing groups read a changed `idle_timeout` at their next idle check. An idle group stops and is started again on the next quota update.

{% hint style="info" %}
Use an idle timeout of at least **1000 ms** and a process threshold of at least **50**.
{% endhint %}

For example:

```yaml
throttling:
  idle_timeout: 60000
  max_processes: 1000
```

Both settings can also be changed at runtime:

```sh
./bin/arweave config get throttling.idle_timeout
./bin/arweave config set throttling.idle_timeout 120000
./bin/arweave config set throttling.max_processes 1500
```

# 4. Limiter metrics

The following metrics are provided per limiter group through the node's metrics endpoint. All have a `limiter_id` label. Rejection and error counters also have a `reason` label; `ar_limiter_peers` is declared with a `limiting_type` label. The tracked-items collector exports an `item_type` label for concurrency entries, bucket peer entries, sliding-window timestamps, and sliding-window peer entries.

| Name | Type | Description |
|------|------|-------------|
| ar_limiter_response_time_microseconds | Histogram | Time taken for limiter calls, in microseconds |
| ar_limiter_requests_total | Counter | Requests processed by the limiter |
| ar_limiter_rejected_total | Counter | Requests rejected by the limiter, by reason |
| ar_limiter_requests_error | Counter | Limiter request errors, by reason |
| ar_limiter_reduce_requests_total | Counter | Explicit budget-reduction requests from handlers |
| ar_limiter_peers | Gauge | Peers or in-flight entries tracked by limiting type |
| ar_limiter_tracked_items_total | Gauge | Tracked sliding-window timestamps, bucket peer entries, sliding-window peer entries, or concurrent requests |
| ar_limiter_leaky_ticks | Counter | Bucket drain ticks processed |
| ar_limiter_leaky_tick_delete_peer_total | Counter | Peer entries removed from the bucket register |
| ar_limiter_cleanup_tick_expired_sliding_peers_deleted_total | Counter | Peer entries removed from the sliding-window register during cleanup |
| ar_limiter_leaky_tick_token_reductions_total | Counter | Consumed bucket tokens removed by periodic drains |
| ar_limiter_leaky_tick_reductions_peer | Counter | Peer entries visited during bucket drain ticks |
