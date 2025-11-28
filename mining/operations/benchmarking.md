---
description: >-
  A guide to benchmarking your miner's performance
---

The arweave node ships with 2 tools you can use to benchmark different elements of your
miner's performance.
- Hashing: `./bin/arweave benchmark hash`
- VDF: `./bin/arweave benchmark vdf`

{% hint style="warning" %}
There are 3 other benchmarking tools (`2.9`, `packing`, and `./data-doctor bench`) that need to be rewritten and can't be relied on to benchmark packing speed.
{% endhint %}

# 1. Hashing

The `hash` benchmark will report the speed in milliseconds to compute an H0 hash as well
as an H1 or H2 hash. These metrics are primarily used while mining.

The times reported are for a single thread (i.e. single core) of
execution. The number of H0 or H1/H2 hashes your system can compute every second of wallclock
time can be scaled up by the number of cores in your CPU. We don't yet have guidance on the
impact of hyperthreading/SMT, so for now best to only count the number of physical cores on
your CPU rather than virtual cores.

Some points to keep in mind. For each VDF step your miner will compute:
- 1 H0 hash for every partition
- 400 H1 hashes for every partition
- 0-400 H2 hashes for every partition
  - *The specific number of H2 hashes is determined by how much of the weave you're mining.*

For the following examples, please keep in mind that with all the benchmarks, these
computations should be taken as guides. In practice your hashing speed will be impacted by a
number of factors not captured by the benchmark (e.g. contention with other processes running,
impact of hyperthreading/SMT, etc...). Also you should budget your CPU capacity to exceed these
calculations in order to accommodate all the other work your miner is doing (both within the
Arweave node and at the system level).

For more information about how hashrate is calculated, please see [Overview - Hashrate](../overview/hashrate.md).

## 1.1 Examples

### 1.1.1 Example 1

- The full weave is 50 partitions
- You are mining all 50 partitions
- Each VDF step you will compute
  - 50 H0 hashes
  - 20,000 H1 hashes *(50 * 400)*
  - 20,000 H2 hashes *(50 * 400)*
- The `hash` benchmark reports
  - H0: **1.5 ms**
  - H1/H2: **0.2 ms**
- Each VDF step you will need **8,075 ms** of compute time (40,000 * 0.2 + 50 * 1.5)
- Implication is that you will need **more than 8-cores** to mine a 1 second VDF.

### 1.1.2 Example 2

- The full weave is 50 partitions
- You are mining 20 partitions
- Each VDF step you will compute
  - 20 H0 hashes
  - 8,000 H1 hashes *(20 * 400)*
  - 3,200 H2 hashes *(20 * (20/50) * 400)*
- The `hash` benchmark reports
  - H0: **1 ms**
  - H1/H2: **0.1 ms**
- Each VDF step you will need **1,140 ms** of compute time (11,200 * 0.1 + 20 * 1)
- Implication is that you will need **more than 1 core** to mine a 1 second VDF.

## 1.2 Options

Usage: `./bin/arweave benchmark hash [options]`
Options:
- `randomx <512|4096>` (default: 512)
- `jit <0|1>` (default: 1)
- `large_pages <0|1>` (default: 1)
- `hw_aes <0|1>` (default: 1)

In general the defaults are fine unless you have a really old CPU. If the benchmark runs without crashing, then you can stick to the defaults.

# 2. VDF Speed

The `vdf` benchmar will report the speed in seconds to compute a VDF.

**Note:** By default the benchmark tool assumes a fixed **VDF difficulty of 600,000**. The Arweave
network VDF difficulty is updated daily in order to target a network average VDF speed of
1 second.

As of November26, 2025, block height 1803283, the Arweave network VDF difficulty is 
**1,106,177**. As VDF difficulty rises, VDF time increases (gets slower), as VDF difficulty
drops, VDF time decreases (gets faster). So today if you use the default options on
the `vdf` benchmark and it reports a
1 second VDF for your CPU, you can expect to achieve 1.14 seconds once connected to the
network. `(1,106,177 / 600,000) * 1 second = 1.84 seconds`

To make this less confusing we recommend specifying the current network difficulty rate when running the benchmark. See below for options.

## 2.1 Options

Usage: `./bin/arweave benchmark vdf [options]`
Options:
- `mode <default|openssl|fused|hiopt_m4>` (default: default)
- `difficulty <vdf_difficulty>` (default: 600,000)
- `verify <true|false> (default: false)`

### 2.1.1 `mode`

This mimics the `vdf` option when running your node and instructs the benchmark tool to use the specifid VDF algorithm. 

### 2.1.2 `difficulty`

Specify the VDF difficulty to use when running the tool. You can check the current network VDF difficulty at https://arweave.net/block/current - search for `vdf_difficulty`

### 2.1.3 `verify`

If `true` then the benchmark tool will verify the VDF output against a slower "debug" VDF algorithm. This is primarily only useful when you're modifying one of the included VDF algorithms.

# 3. Deprecated Tools

There are 3 other benchmarking tools (`2.9`, `packing`, `./data-doctor bench`) that need to be rewritten and can't be relied on to benchmark packing speed.