---
description: >-
  A guide to building your first Arweave miner.
---

# Mining Hardware Guide

This guide has 2 parts:
1. [Building your miner](#building-your-miner)
2. [Benchmarking your miner](#benchmarking-your-miner)

# Building your miner

There are 2 phases to Arweave mining:

1. Syncing and Packing
2. Mining

This build guide will focus on the mining phase.

The Arweave dataset (called the "weave") is broken up into 3.6TB partitions (3,600,000,000,000 bytes). There are 61 partitions as of October, 2024, although that will grow over time as users upload more data. **The Arweave protocol provides a strong incentive to mine against the complete dataset or multiple copies of the complete dataset (called "full replicas").**

A full replica miner can opt for a single node that reads from all 61 partitions, or they can operate several nodes that each read from a subset of the data and coordinate with each other to assemble a full replica. This is called "coordinated mining". In all cases the primary bottleneck is typically disk read bandwidth. You will need to retain the average read throughput required by your chosen packing format for each partition stored. See the [Packing Format](mining-guide.md#Preparation-Packing-Format) section of the Mining Guide for information about the read rate required per partition for each of the different packing formats.

Below we'll outline the main considerations when building your miner, and provide an example configuration. 

{% hint style="warning" %}
Mining configurations vary tremendously from miner to miner, and we're not yet able to certify specific component compatibility. As you build your miner you will need to verify compatibility between components. 
{% endhint %}

## Mining Platform

{% hint style="warning" %}
The following guide assumes all data is packed using the deprecated `spora_2_6` format. For all new packs we recommend using the `composite` format. The lower read rates that a `composite` packing allows will reduce the hardware resources used during mining (larger disks, lower disk read rate, lower CPU and RAM utilization). 

This guide should be updated in the future to provide guidance for `composite` format packs.
{% endhint %}

There are 2 possible mining configurations:

1. A single node mining a full replica
2. Multiple nodes each mining a partial replica and coordinating together to assemble a full replica

**To date the dominant strategy has been to adopt a multi-node / coordinated mining approach.** As the weave continues to grow we believe this strategy will only increase in popularity.

{% hint style="success" %}
### An example 16-partition node could include:

1. 1x mid-tier Ryzen CPU (e.g. Ryzen 5/7/9)
2. 1x motherboard with at least one PCIe 3.0 8x slot
3. 1x 16-port Host Bus Adapter (HBA)
    - SAS2 or SAS3, LSI or Broadcom HBA, 16i or 16e
    - For example: 
        - LSI SAS 9201-16i (SAS2)
        - Broadcom 9305-16e (SAS3)
4. 4x Mini SAS to SATA breakout cables
    - Mini SAS ports can be either SFF-8087 or SFF-8643
5. 16x 4TB 7200rpm SATA HDDs
6. 1x PSU with at least 16 SATA ports
{% endhint %}

You would then coordinate 3 or more of these nodes to cover the full weave.

It is also possible to configure a single node that mines against more than 16 partitions. We outline the main considerations below to provide guidance should you wish to move away from the example configuration above.

Note: it is also possible to mine efficiently as a partial replica miner. In that case you will want to join a Mining Pool that is able to coordinate your partitions with other miners in the pool so that you are still able to get the full replica hashrate bonus.

## Storage Bandwidth

**The primary bottleneck of a miner is storage read bandwidth**. Specifically you need to maintain at least an average 200MB/s read throughput per 3.6TB partition. Read throughput is measured from the disk to the CPU. The main components involved are:

1. Hard Disk Drive (HDD)
2. Host Bus Adapter (HBA) (optionally with SAS expander)
3. PCIe slots on the motherboard

We'll now cover each component in a bit more depth. 

### Hard Disk Drive (HDD)

**The main requirement is that your HDDs are able to provide an average read throughput of 200MB/s per 3.6TB partition.** Since modern 7200rpm HDDs are typically rated for 200MB/s, the simplest and recommended approach is to buy one 4TB HDD for every partition you plan to mine. The extra 0.4TB is used for metadata stored adjacent to the weave data.

However, each miner's situation is different and miners may find it more profitable to mine different configurations, for example:

1. Distribute 3 partitions across 4x 3TB HDDs
2. Use 8TB HDDs, assign 1 partition to each HDD, and use the extra space for infrequently accessed storage.

Similarly, both SATA and SAS HDDs will work fine, you will just need to ensure compatibility between the HDDs, cabling, and other components. 

### Host Bus Adapter (HBA)

Most motherboards don't integrate enough SATA connectors to support 16+ disks, so you will likely need at least one HBA. There are many, many different HBAs to choose from. The first question is: how many disks will you connect to the HBA? Once you have that number you can work through the following attributes to select your HBA:

1. SAS version
2. Number of SAS lanes
3. Optional SAS expander
4. Number of PCIe lanes and PCIe version
5. Internal or external SAS ports
6. Miscellaneous

Let's work through them assuming our sample configuration of 16 SATA disks per node.

16 SATA disks will require a total of 16 x 1.2Gbps = 25.6 Gbps of sustained, average read throughput. 

{% hint style="info" %}
Note: we don't recommend using RAID. In general neither software nor hardware RAID provide enough benefits to offset the cost and complexity - and under some configurations can hurt performance. As always: each miner's situation is different. Some miners with expertise or access to hardware may find RAID configurations that are beneficial.
{% endhint %}

#### SAS Version

SAS (stands for Serial-Attached SCSI) is a data transfer protocol. There are 3 different speed standards for SAS

- SAS-1: 3 Gbps per lane
- SAS-2: 6 Gbps per lane
- SAS-3: 12 Gbps per lane

All the standards are interoperable, however when combining cables and peripherals at different SAS standards, the data transfer throughput is determined by the slowest component. e.g. if you attach a SAS-1 expander to a SAS-3 HBA, your throughput will be 3 Gbps per lane, not 12 Gbps per lane.

Because of this we recommend deciding on a standard early and selecting all components at that standard or higher. 

{% hint style="info" %}
We recommend sticking with SAS-2 or SAS-3 as it will help ensure the SAS speed does not become a bottleneck if you decide to add more disks in the future.
{% endhint %}

#### Number of SAS Lanes

HBA product names end in a number and a letter, like 8i, 16i, 16e. The number refers to the number of SAS lanes supported by the HBA. There are 4 lanes per HBA connector (typically a Mini-SAS connector, but there are other ports too). So a "SAS-2 LSI HBA 16i" has 4 connectors, each with 4 SAS lanes, for a total of 16 lanes. 16 lanes x 6 Gbps = 96 Gbps of aggregate throughput.

Without using a SAS expander (discussed below) each HBA lane can connect directly to a single HDD. So if you want to support 16 disks, you need a 16-lane (sometimes called 16-port) HBA. Each disk requires 1.2 Gbps of read bandwidth, which is well below the SAS bandwidth (all versions). 

{% hint style="info" %}
We recommend using a 16i or 16e HBA to connect 16 disks. 
{% endhint %}

As you may have noticed each HBA lane has enough bandwidth to theoretically support multiple disks. A 6Gbps SAS-2 lane, for example, could theoretically support 5 disks at 1.2 Gbps per disk. To achieve this, you would need to add a SAS Expander.

#### SAS Expander

Using a SAS Expander you can connect multiple disks to each SAS lane on your HBA. Aligning SAS versions is particularly important when using a SAS Expander. For example if you use a SAS-1 Expander with a SAS-2 HBA and try to attach 4 disks to each SAS lane, the lower SAS-1 throughput of 3 Gbps will throttle your read rate.

{% hint style="info" %}
Using a SAS Expander also requires an extra PCIe slot (discussed below), and is one more component to troubleshoot and replace. For these reasons we don't recommend using a SAS expander unless you are prepared for the additional complexity.
{% endhint %}

#### Number of PCIe lanes and PCIe version

The final connection is from the HBA to the motherboard via the PCIe slot.

{% hint style="info" %}
To ensure the PCIe bandwidth itself does not become a bottleneck we recommend sticking with adapters that use PCIe version 3.0 with 8 PCIe lanes adapters. PCIe 3.0 8x provides 62.4 Gbps of bandwidth which is enough to handle up to 39 disks. 
{% endhint %}

#### Internal vs. External

One more note on the HBA: the letter at the end of the product number (i.e. 16i vs. 16e) refers to "internal" vs. "external" connectors. A 16i HBA will expose the Mini-SAS connectors to the interior of the case, a 16e will expose the MIni-SAS connectors to the exterior of the case. We have no recommendation here as it depends on where you plan to mount your disks.

#### Miscellaneous

Since computer systems are complex and the components incredibly varied, it's possible that there may be other bandwidth limitations in your system separate from the HBA and disks. You may want to review the specifications of any other components in your system to ensure they don't restrict your available read bandwidth.

### PCIe Slots on the Motherboard

As mentioned above in the HBA section, we recommend using 8-lane PCIe 3.0 or better for connecting your HBA and any SAS expanders. You'll want to keep this in mind when buying a motherboard to ensure it has enough slots of the right type to accommodate your HBA(s) and any SAS expanders.

## Note: Syncing and Packing Phase

The preceding hardware configurations focus on the mining phase. Before you can start mining you need to download a full replica (177 TB as of March, 2024) and then pack it to your mining address. Packing is a CPU-intensive encryption process (the weave data is symmetrically encrypted using your mining address). Generally miners will sync and pack in parallel - packing data as they download it.

This phase is heavily bottlenecked by available download bandwidth and CPU capacity. For example if your download bandwidth is 1 Gbps it will take over 16 days to download the full data set. The faster your download speed, the faster you can sync the dataset. However once you start mining, a 100-200 Mbps connection will be more than enough.

After you have downloaded some data you have to pack it. A 16-core Ryzen 9 7950x can pack about 90 MB per second - which means it would take about 22 days to pack the full data set using a single 16-core Ryzen 9 7950x. Since these two phases (syncing and packing) can happen in parallel, this example miner with 1Gbps download bandwidth and a 16-core Ryzen 9 7950x could sync and pack the full data set in 22 days.

The saving grace to all this is that you only need to download and pack the data once per replica. Some miners will rent CPU time and access to bandwidth to reduce the time of this phase.

# Benchmarking your miner

The arweave node ships with 3 tools you can use to benchmark different elements of your
miner's performance.
- Packing: `./bin/benchmark-packing`
- Hashing: `./bin/benchmark-hash` (*currently in `master`, will be released in v2.7.4*)
- VDF: `./bin/benchmark-vdf`

## Packing

The `benchmark-packing` tool will report how many chunks per second you miner can expect
to pack across all cores. In practice you will likely observe less than this number due
other processes that need to run in a full node, taking resources away from packing. But it's
a good metric.

See the [Syncing and Packing guide](syncing-and-packing.md) for more information on how to
interpret this number. Some points to keep in mind:
- While syncing you should expect **1 to 2 packing operations for every chunk written.**
- Each chunk is **256 KiB**

For example, if the `benchmark-packing` tool reports **100 chunks per second** for your CPU,
you can expect you node to sync at an **upper bound speed of 12.5 to 25 MiB/s.**

## Hashing

The `benchmark-hash` tool will report the speed in milliseconds to compute an H0 hash as well
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

### Example 1

- The full weave is 50 partitions
- You are mining all 50 partitions
- Each VDF step you will compute
  - 50 H0 hashes
  - 20,000 H1 hashes *(50 * 400)*
  - 20,000 H2 hashes *(50 * 400)*
- `benchmark-hash` reports
  - H0: **1.5 ms**
  - H1/H2: **0.2 ms**
- Each VDF step you will need **8,075 ms** of compute time (40,000 * 0.2 + 50 * 1.5)
- Implication is that you will need **more than 8-cores** to mine a 1 second VDF.

### Example 2

- The full weave is 50 partitions
- You are mining 20 partitions
- Each VDF step you will compute
  - 20 H0 hashes
  - 8,000 H1 hashes *(20 * 400)*
  - 3,200 H2 hashes *(20 * (20/50) * 400)*
- `benchmark-hash` reports
  - H0: **1 ms**
  - H1/H2: **0.1 ms**
- Each VDF step you will need **1,140 ms** of compute time (11,200 * 0.1 + 20 * 1)
- Implication is that you will need **more than 1 core** to mine a 1 second VDF.

## VDF Speed

The `benchmark-vdf` tool will report the speed in seconds to compute a VDF.

**Note:** The benchmark tool assumes a fixed **VDF difficulty of 600,000**. The Arweave
network VDF difficulty is updated daily in order to target a network average VDF speed of
1 second.

As of May 6, 2024, block height 1419127, the Arweave network VDF difficulty is 
**685,016**. As VDF difficulty rises, VDF time increases (gets slower), as VDF difficulty
drops, VDF time decreases (gets faster). So today if the `benchmark-vdf` tool reports a
1 second VDF for your CPU, you can expect to achieve 1.14 seconds once connected to the
network. `(685,016 / 600,000) * 1 second = 1.14 seconds`

## Some Sample Data

Data as of May 6, 2024. Collected from tiny sample sizes. May be inaccurate.

| Processor | Cores | Packing (chunks per second) | H0 (ms) | H1/H2 (ms) | VDF (seconds) |
| --------- | ----- | ------------------------- | ------ | --------- | ------------ |
| AMD Ryzen 9 5900X | 12 | 233 | 1.60 | 0.13 | 1.16 | 
| AMD Ryzen 9 7950X | 16 | 377 | 1.37 | 0.11 | 1 |
| Intel Core i7-4770 | 8 | 48 |  1.58 | 0.56 |4.94 |
| Mac Mini M2 | 8 | | 12.13 | 0.11 | 0.87 |

