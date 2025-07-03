---
description: >-
  A guide to monitoring your miner.
---

# Metrics

The arweave node publishes a set of [Prometheus](https://prometheus.io/docs/introduction/overview/) metrics at the `/metrics` endpoint (i.e. 
`<IP>:<PORT>/metrics`) - you can see an example at https://arweave.net/metrics. The `/metrics` endpoint also includes descriptions of each metric.

You can integrate Prometheus with a number of monitoring and visualization tools. Below we'll share some sample dashboards in [Grafana](https://grafana.com/) and some guidance:
1. [Mining Metrics](#mining-metrics)
2. [Syncing and Packing Metrics](#syncing-and-packing-metrics)
3. [Debugging Metrics](#debugging-metrics)

## Setup

1. [Setup Prometheus](https://prometheus.io/docs/prometheus/latest/getting_started/) to scrape the `/metrics` endpoint of your arweave node.
2. When you get to the point of defining Prometheus targets to monitor, add an `instance` label for each target that provides a name for your node (can just be your IP if you want). This isn't required in general, but it will make using the sample dashboard easier. e.g.
```
  - job_name: arweave

    static_configs:
      - targets: ['111.222.333.444:1984']
      labels:
        instance: 'my-miner'
```
Note:  If you have previously set up your job_name with a value other than the default 'arweave', you will get a chance to override that default during the dashboard import in step 4 below.

3. [Setup Grafana](https://grafana.com/docs/grafana/latest/datasources/prometheus/configure-prometheus-data-source/) to visualize the Prometheus data.
4. [Import the sample dashboard](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/import-dashboards/). Sample Dashboard JSON is available [here](grafana.json).

# Mining Metrics

[Sample dashboard in Grafana](grafana-mining.json)

![Sample Dashboard](images/dashboard-mining.png)

## Read Rate

**Metric**: `mining_rate{type="read"}`

This metric tracks the number of chunks read per second. 1 chunk is 256kib.

The protocol allows for up to 800 chunks per partition per VDF step to be read. That equates to roughly 200MiB/s per partition.

**Alerting**:
We recommend setting an alert at 0 MiB/s as that indicates the miner is no longer mining. You may also want to establish a baseline and set an alert if read rate falls some amount below that baseline

## Read Rate vs. Ideal

**Metrics**: `mining_rate{type="read"}` and `mining_rate{type="ideal_read"}`

This metric combines two values:
1. Your miner's actual read rate
2. The ideal read rate for an optimal miner with the same set of data synced and the same VDF speed.

The result is a percentage where 100% indicates you are mining at the ideal rate. The rate can exceed 100% for two reasons:
1. The ideal and actual metrics are calculated on slightly different periods and so there might be some oscillation in the percentage.
2. If your miner is mining as part of a coordinated mining set, the ideal rate is currently calculated assuming your miner is solo mining and doesn't take into account the hashes that your miner will perform for coordinated mining peers. 

**Alerting**:
You may want to establish a baseline and set an alert if read rate falls some amount below that baseline

## Hash Rate

**Metric**: `mining_rate{type="hash"}`

This metric tracks the miner hashrate. The protocol allows for up to 400 H1 hashes and 400 H2 hashes per partition per VDF step. The metric also consider that an H1 hash is 100x less likely to result in a solution and scales the H1 hash count down accordingly. You can roughly interpret that as the protocol allowing 404 solution attempts (combination of H1 and H2 hashes) per partition per VDF step.

Note: hashes are generated after chunks are read, so if your Read Rate chart shows a low read rate, your Hash Rate chart will also be lower.

**Alerting**:
Re recommend setting an alert on 0 as that indicates your miner is no longer mining. You may also want to establish a baseline and set an alert if hashrate falls some amount below that baseline

## Hash Rate vs. Ideal

**Metrics**: `mining_rate{type="hash"}` and `mining_rate{type="ideal_hash"}`

This metric combines two values:
1. Your miner's actual hash rate
2. The ideal hash rate for an optimal miner with the same set of data sync and the same VDF speed.

The result is a percentage where 100% indicates you are mining at the ideal rate. The rate can exceed 100% for two reasons:
1. The ideal and actual metrics are calculated on slightly different periods and so there might be some oscillation in the percentage.
2. If your miner is mining as part of a coordinated mining set, the ideal rate is currently calculated assuming your miner is solo mining and doesn't take into account the hashes that your miner will perform for coordinated mining peers. 

**Alerting**:
You may want to establish a baseline and set an alert if hashrate falls some amount below that baseline

## VDF Step Number

**Metric**: `vdf_step`

This metric tracks the current VDF step number of the node - either calculated locally or received from a trusted VDF server. 

You expect this number to increase roughly every second.

**Alerting**:
We recommend starting with an alert that goes off if there are fewer than 200 steps in a 5-minute period.

## Block Height

**Metric**: `arweave_block_height`

This metric tracks the height of the node's current tip block. We expect this number to increase roughly every 2 minutes, but there can be substantial variation in the block time. 

**Alerting**:
We recommend alerting if you don't see a new block in 15 minutes.

## VDF Step Behind

**Metric**: `block_vdf_advance`

This metric tracks how many VDF steps the node is behind the last block it processed. A negative number means the node is *ahead* of the VDF step in the latest block.

If this number grows too large it can indicate that the node's VDF or VDF server is too slow or has fallen behind.

**Alerting**:
We recommend setting an alert at 200, and adjusting as needed.

# Syncing and Packing Metrics

[Sample dashboard in Grafana](grafana-syncing-packing.json)

## Partition Sizes

**Metric**: `v2_index_data_size_by_packing`

This metric tracks the size of the data synced for each partition and packing format. The
packing format is indicated by the `packing` label, and the partition number is indicated
by the `partition_number` label.

## Entropy Written

**Metric**: `replica_2_9_entropy_stored`

This metric tracks the amount of entropy generated and written to each storage module. The
storage module is indicated by the `store_id` label.

## Total Chunks Written

**Metric**: `chunks_stored`

This widget display the total number of chunks written (in bytes) over the current dashboard
time period. This can provide a gauge of how much data you've synced and packed over
a given time period.

## Chunks Written

**Metric**: `chunks_stored`

This panel tracks the number of chunks written per second (in bytes).  Each chunk written is
assumed to be 256 KiB. This may differ from your packing rate as each chunk written may need
a different number of packing operations (0 to 2 depending on the format the chunk is received
and the format it is written)

**Debugging**: If your node is mining and packing at the same time you may see your hash
rate drop. Consulting this panel can help you determine if an increase in packing activity
corresponds with the drop in hash rate.

## Sync Requests

**Metric**: `http_client_get_chunk_duration_seconds_count`

This metric tracks the the number of `GET /chunk2` requests that your node makes to peers.
This is the primary method through which a node syncs chunks during the Syncing and Packing
phase.

**Debugging**: If you believe your sync rate is too slow, consulting this graph might explain
why. Your node should pull data from several peers at once - if this isn't the case, your
node could be in the process of searching for healthier peers.

## Average Sync Latency

**Metrics**: `http_client_get_chunk_duration_seconds_sum` and `http_client_get_chunk_duration_seconds_count`

This panel tracks the average latency of `GET /chunk2` requests to peers. 

**Debugging**: If you believe your sync rate is too slow, consulting this graph might explain
why. The node should detect and adjust to high latencies by selecting different peers. But it
can take some time to find new peers - during this period syncing/packing rate may dip.



## Packing Rate

**Metric**: `packing_duration_milliseconds_count`

This panel tracks the number of packing operations performed per second. 


# Debugging Metrics

[Sample dashboard in Grafana](grafana-debug.json)

The Debugging Dashboard provides some more detail information that can help with debugging
performance issues. It is split into 3 sections:

1. [Mining](#mining-debug-metrics)
2. [HTTP Requests](#http-requests-debug-metrics)
3. [Debug Mode](#debug-mode-debug-metrics)

## Mining Debug Metrics

![Sample Dashboard](images/dashboard-debug-mining.png)

### Raw Read Rate

**Metric**: `mining_rate{type="raw_read"}`

This panel tracks the time it takes to read a 100MiB recall range per partition. This differs
from the [Mining Read Rate](#read-rate) which tracks the number of chunks read per second. In
particular the Raw Read Rate is not impacted by other bottlenecks in the mining pipeline and
should give you a good indication of the disk speed actually observed by the node.

For example if your disk is capable of reading at 200MiB/s the Raw Read Rate should reflect
this. However if, for example, you have a slow VDF speed, your Mining Read Rate might show
a much lower number.

**Debugging**: If you're not getting the hashrate you expect from your miner, this chart can
help you pinpoint the bottleneck. If this chart is showing lower read rates than you'd expect
you might want to check your hardware or system-level configuration. If this chart is showing
expected read rates, then you'll have to look elsewhere in the pipeline (e.g. VDF Speed,
CPU utilization, RAM utilization, etc.)

### Chunk Cache Size

**Metric**: `mining_server_chunk_cache_size`

This panel tracks the size of your mining chunk cache (in 256 KiB chunks). While mining
your node will need to temporarily cache chunks of data after reading them, this metric
tracks how many of those chunks are currently cached. The cache has a size limit which 
is printed periodically by your node (to the console and to the logs), and can be set
using the `mining_server_chunk_cache_size_limit` launch parameter.

**Debugging**: If your chunk cache size is consistently at or above the limit, your miner
is not able to keep up with its optimal mining rate. This can be for a number of reason,
however one thing you can try is increasing the `mining_server_chunk_cache_size_limit`. If
your miner is only temporarily falling behind (e.g. due to other processes running and
stealing CPU or disk bandwidth), an increased cache can allow your miner to "catch up".

Note: increasing the cache size limit may increase your node's memory usage which can
negatively impact performance if you are running near your system's memory limit.

## HTTP Requests Debug Metrics

![Sample Dashboard](images/dashboard-debug-http.png)

### Total Inbound Requests

**Metrics**: `cowboy_requests_total`, `cowboy_request_duration_seconds_sum`, and `cowboy_request_duration_seconds_count`

These panels track the requests that your node is receiving from peers on the network. They
track number of requests per second, total latency by request type, and average latency per
request per type.

**Debugging**: These charts can help you identify activity that could be impacting your
performance (e.g. mining, syncing, packing). For example a spike in `POST /tx2` or `GET /tx`
might correspond to a period of high Arweave network activity. Or a high total latency servicing
`GET /chunk2` might indicate that your node is serving a lot of chunks to peers. Depending
on the type of activity and how strongly it is impacting your node performance, you can
take different actions.

For example if you believe your node is serving too much chunk data and it is negatively
impacting performance you can set the `get_chunk` `semaphore` (see the help for a brief
description of how to set it - it's only usable via config.json). This will control how many
concurrent `get_chunk` requests your node will handle. Default is 100.

Note: restricting `get_chunk` too much may negatively impact your node's reputation, which
can in turn negatively impact sync rate or block orphan rate.

### Total Outbound Requests

**Metrics**: `cowboy_requests_total`, `cowboy_request_duration_seconds_sum`, and `cowboy_request_duration_seconds_count`

These panels track the requests that your node is making to peers on the network. They
track number of requests per second, total latency by request type, and average latency per
request per type.

**Debugging**: Similar to the [Total Inbound Requests](#total-inbound-requests) chart, you can
use these charts to identify activity that could be impacting your node's performance.

## Debug Mode Metrics

These charts are only populated if you run your node with the `debug` launch parameter.

![Sample Dashboard](images/dashboard-debug-debug.png)

### CPU Load / # Cores

**Metric**: `process_cpu_seconds_total`

Total CPU across all *virtual* cores. If you have a 16-core CPU with Hyperthreading/SMT
enabled, you will likely have 32 virtual cores. Set the dashboard variable appropriately to
get a sense of your overall CPU load.

### Memory

**Metric**: `process_info{type=~"memory}`

This panel tracks the memory used per Erlang process.

### Message Queue

**Metric**: `process_info{type="message_queue"}`

This panel tracks the number of messages stored in each erlang process's message queue.
Erlang processes can be thought of as threads without shared memory. They send messages to
communicate with each other. Before being processed a message is stored in a message queue.
If a process's message queue is growing it means that process is receiving more messages than
it can process.

### Reductions

**Metric**: `process_info{type="reductions"}`

This panel tracks Erlang reductions. Reductions are a measure of Eerlang process activity. 
the more reductions performed by a process, the more CPU cycles it has consumed.
