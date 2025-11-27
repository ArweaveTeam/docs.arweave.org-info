---
description: >-
  Planning your miner's hardware configuration
---

# 1. Overview

This guide will outline the main considerations when building your miner and provide an example configuration.

{% hint style="warning" %}
Mining configurations vary tremendously from miner to miner, and we're not yet able to certify specific component compatibility. As you build your miner you will need to verify compatibility between components. 
{% endhint %}

The Arweave dataset (called the "weave") is broken up into 3.6TB partitions (3,600,000,000,000 bytes). There are 103 partitions as of November, 2025, although that will grow over time as users upload more data. **The Arweave protocol provides a strong incentive to mine against the complete dataset or multiple copies of the complete dataset (called "full replicas").** For more details on how hashrate is calculated and why it's important to mine as close to a full replica as possible see [Overview - Hashrate](../overview/hashrate.md).

There are 3 operating phases with different resource bottlenecks:

## 1.1 Syncing and Packing

In this phase a miner is syncing weave data and preparing it to be mined. Data is ready to be mined only after entropy has been generated and the data has been packed to that entropy. See [Overview - Syncing and Packing](../overview/syncing-and-packing.md) for more information about this process.

During this phase the main resource bottlenecks are (roughly in order):

1. [Network bandwidth](#32-network-bandwidth)
2. [CPU](#341-cpu-while-packing)
3. [Storage bandwidth](#31-storage-bandwidth)
4. [RAM](#33-ram)

## 1.2 Mining

In this phase a miner has all of their data packed and stored and is now mining it. See [Overview - Hashrate](../overview/hashrate.md) for more information about the mining process.

During this phase the main resource bottlenecks are (roughly in order):

1. Storage space
2. [Storage bandwidth](#31-storage-bandwidth)
3. [RAM](#33-ram)
4. [CPU](#342-cpu-while-mining)

## 1.3 VDF Computation

VDF computation isn't a distinct phase, it happens all the time and is an input to both mining and block validation. Since VDF speed has a strong impact on mining hashrate, most miners opt to use a dedicated VDF server optimized for the task. This is not required, though. As of November 2025 the fastest observed VDF computation is on Apple Silicon (e.g. M4).

The main resource bottleneck whe computing VDF:

1. [CPU](#343-cpu-while-computing-vdf) (specifically single-threaded SHA256 compute speed)

# 2. Mining Platform

Although the resource requirements differ materially between the Syncing & Packing and Mining phases, most miners opt to use the same hardware configuration throughout. So whilke it is possible to have dedicated Syncing & Packing servers and dedicated Mining server, we will focus on the single-platform approach for this guide.

There are 2 possible mining configurations:

1. [Solo Miner](../overview/node-types.md#1-solo-miner): A single node mining a full replica
2. [Coordinated Miner](../overview/node-types.md#2-coordinated-miner): Multiple nodes each mining a partial replica and coordinating together to assemble a full replica

**To date the dominant strategy has been to adopt a multi-node / coordinated mining approach.** As the weave continues to grow we believe this strategy will only increase in popularity.

{% hint style="warning" %}
This sample node was configured before the `replica.2.9` packing format was introduced. Prior to `replica.2.9` it was important for miners to be able to sustain an average read rate of **200 MB/s** from each **4TB** HDD. Storage bandwidth is still important, but the optimal read rate has dropped to **20 MB/s** per **16TB** HDD. With these improvements it's possible that miners with lower read bandwidth can still mine optimally. However until we have examples of those configurations working well, we are leaving in place the recommendation for highly optimized storage bandwidth.
{% endhint %}

{% hint style="success" %}
## An example 64-partition (256TB) node could include:

1. 1x mid-tier Ryzen CPU (e.g. Ryzen 5/7/9)
2. 1x motherboard with at least one PCIe 3.0 8x slot
3. 1x 16-port Host Bus Adapter (HBA)
    - SAS2 or SAS3, LSI or Broadcom HBA, 16i or 16e
    - For example: 
        - LSI SAS 9201-16i (SAS2)
        - Broadcom 9305-16e (SAS3)
4. 4x Mini SAS to SATA breakout cables
    - Mini SAS ports can be either SFF-8087 or SFF-8643
5. 16x 16TB 7200rpm SATA HDDs (for 64 partitions of mineable weave data)
6. 1x 1TB SSD or NVMe (for `data_dir`)
8. 1x PSU with at least 16 SATA ports
{% endhint %}

You would then coordinate 2 or more of these nodes to cover the full weave.

It is also possible to configure a single node that mines against more than 64 partitions. We outline the main considerations below to provide guidance should you wish to move away from the example configuration above.

Note: it is also possible to mine efficiently as a partial replica miner. In that case you will want to join a [Mining Pool](../overview/node-types.md#3-pool-miner) that is able to coordinate your partitions with other miners in the pool so that you are still able to get the full replica hashrate bonus.

# 3. Resource bottlenecks

This section attempts to break down the different hardware bottlenecks and provide some guidance in designing your system. We also suggest you review the [Operations - Benchmarking](../operations/benchmarking.md) guide for some direction on benchmarking your system to estimate its mining, packing, and VDF performance.

# 3.1 Storage Bandwidth

An efficient miner needs to maintain at last an average of 5MB/s read throughput per 3.6TB partition while mining. In our example configuration we used 16TB HDDs that can each fit 4 partitions. So the miner will need to maintain read throughput of 20MB/s. Read throughput is measured from the disk to the CPU. The main components involved are:

1. Hard Disk Drive (HDD)
2. Host Bus Adapter (HBA) (optionally with SAS expander)
3. PCIe slots on the motherboard

We'll now cover each component in a bit more depth. 

## 3.1.1 Solid State Drive (SSD) for `data_dir`

Most of this section is focused on bandwidth requirements for mining weave data. In addition to weave data, every Arweave node (miner or othwerwise) needs to allocate space for the `data_dir`. You can read more about the `data_dir` in [Setup - Directory Structure](directory-structure.md). The data in `data_dir` is read and written frequently by all node services. Because of this we recommend that it be stored on an NVMe or SSD. Storing your `data_dir` on an HDD can negatively impact the peformance of all node operations. The minimum recommended size for the `data_dir` is 256GB - a larger size will provide you some buffer as datasets grow as well as allow you to store more of the blockchain history. A larger `data_dir` isn't required for efficient mining, but it allows your node to participate more fully with the network and can limit the frequency of configuration changes and data cleanup tasks. Many miners opt for a 500GB or 1TB `data_dir`.

## 3.1.2 Hard Disk Drive (HDD)

**The main requirement is that your HDDs are able to provide an average read throughput of 5MB/s per 3.6TB partition.** For example, a 16TB HDD storing 4 partitions would need to sustain an average read rate of 20MB/s. The extra 0.4TB is used for metadata stored adjacent to the weave data.

However, each miner's situation is different and miners may find it more profitable to mine different configurations, for example:

1. Use smaller disks with fewer partitions (e.g. 1x 4TB HDD with 1 partition, 1x 8TB HDD with 2 partitions, etc..)
2. Distribute 3 partitions across 4x 3TB HDDs
3. Use even larger disks (e.g. 1x 24TB HDD with 6 partitions that can sustain 30MB/s read rate)

Similarly, both SATA and SAS HDDs will work fine, you will just need to ensure compatibility between the HDDs, cabling, and other components. 

## 3.1.3 Host Bus Adapter (HBA)

Most motherboards don't integrate enough SATA connectors to support 16+ disks, so you will likely need at least one HBA. There are many, many different HBAs to choose from. The first question is: how many disks will you connect to the HBA? Once you have that number you can work through the following attributes to select your HBA:

1. SAS version
2. Number of SAS lanes
3. Optional SAS expander
4. Number of PCIe lanes and PCIe version
5. Internal or external SAS ports
6. Miscellaneous

Let's work through them assuming our sample configuration of 16x 16TB SATA disks per node.

16x 16TB SATA disks will require a total of 16 x 160Mbps = 2.56 Gbps of sustained, average read throughput. (Note: 20MB/s = 160Mbps)

{% hint style="info" %}
Note: we don't recommend using RAID. In general neither software nor hardware RAID provide enough benefits to offset the cost and complexity - and under some configurations can hurt performance. As always: each miner's situation is different. Some miners with expertise or access to hardware may find RAID configurations that are beneficial.
{% endhint %}

### SAS Version

SAS (stands for Serial-Attached SCSI) is a data transfer protocol. There are 3 different speed standards for SAS

- SAS-1: 3 Gbps per lane
- SAS-2: 6 Gbps per lane
- SAS-3: 12 Gbps per lane

All the standards are interoperable, however when combining cables and peripherals at different SAS standards, the data transfer throughput is determined by the slowest component. e.g. if you attach a SAS-1 expander to a SAS-3 HBA, your throughput will be 3 Gbps per lane, not 12 Gbps per lane.

Because of this we recommend deciding on a standard early and selecting all components at that standard or higher. 

{% hint style="info" %}
We recommend sticking with SAS-2 or SAS-3 as it will help ensure the SAS speed does not become a bottleneck if you decide to add more disks in the future.
{% endhint %}

### Number of SAS Lanes

HBA product names end in a number and a letter, like 8i, 16i, 16e. The number refers to the number of SAS lanes supported by the HBA. There are 4 lanes per HBA connector (typically a Mini-SAS connector, but there are other ports too). So a "SAS-2 LSI HBA 16i" has 4 connectors, each with 4 SAS lanes, for a total of 16 lanes. 16 lanes x 6 Gbps = 96 Gbps of aggregate throughput.

Without using a SAS expander (discussed below) each HBA lane can connect directly to a single HDD. So if you want to support 16 disks, you need a 16-lane (sometimes called 16-port) HBA. Each 16TB disk requires 160 Mbps of read bandwidth, which is well below the SAS bandwidth (all versions). 

{% hint style="info" %}
We recommend using a 16i or 16e HBA to connect 16 disks. 
{% endhint %}

As you may have noticed each HBA lane has enough bandwidth to theoretically support multiple disks. A 6Gbps SAS-2 lane, for example, could theoretically support 37x 16TB disks at 160 Mbps per disk. To achieve this, you would need to add a SAS Expander.

### SAS Expander

Using a SAS Expander you can connect multiple disks to each SAS lane on your HBA. Aligning SAS versions is particularly important when using a SAS Expander. For example if you use a SAS-1 Expander with a SAS-2 HBA and try to attach 30x 16TB disks to each SAS lane, the lower SAS-1 throughput of 3 Gbps will throttle your read rate.

{% hint style="info" %}
Using a SAS Expander also requires an extra PCIe slot (discussed below), and is one more component to troubleshoot and replace. For these reasons we don't recommend using a SAS expander unless you are prepared for the additional complexity.
{% endhint %}

### Number of PCIe lanes and PCIe version

The final connection is from the HBA to the motherboard via the PCIe slot.

{% hint style="info" %}
To ensure the PCIe bandwidth itself does not become a bottleneck we recommend sticking with adapters that use PCIe version 3.0 with 8 PCIe lanes adapters. PCIe 3.0 8x provides 62.4 Gbps of bandwidth which is enough to handle up to 390x 16TB disks. 
{% endhint %}

### Internal vs. External

One more note on the HBA: the letter at the end of the product number (i.e. 16i vs. 16e) refers to "internal" vs. "external" connectors. A 16i HBA will expose the Mini-SAS connectors to the interior of the case, a 16e will expose the MIni-SAS connectors to the exterior of the case. We have no recommendation here as it depends on where you plan to mount your disks.

### Miscellaneous

Since computer systems are complex and the components incredibly varied, it's possible that there may be other bandwidth limitations in your system separate from the HBA and disks. You may want to review the specifications of any other components in your system to ensure they don't restrict your available read bandwidth.

## 3.1.4 PCIe Slots on the Motherboard

As mentioned above in the HBA section, we recommend using 8-lane PCIe 3.0 or better for connecting your HBA and any SAS expanders. You'll want to keep this in mind when buying a motherboard to ensure it has enough slots of the right type to accommodate your HBA(s) and any SAS expanders.

## 3.1.5 Storage Bandwidth while Packing

Depending on how you're packing data as well other resource constraints (e.g. network bandwidth, CPU), it's possible for storage read or write bandwidth to become a bottleneck while packing. Some examples:

- It's often possible to generate 1 GB per second of packing entropy. In this case you may want to ensure you're always packing entropy for several disks at once to avoid hitting a write bandwidth bottleneck.
- When syncing and packing you'll need to read the previously written entropy from disk, pack a chunk, and then write the packed chunk back to disk. Storage bandwidth can be noticeably impacted here due to need to read and write, as well as seek to different locations.
- A similar read, write, and seek bottleneck can also surface while repacking in place.

As noted [below](#351-cpu-while-packing) a saving grace for packing is the fact that you only have to do it once data range. Once complete you can mine that packed data forever without repacking.

See [Overview - Syncing and Packing](../overview/syncing-and-packing.md) for more information on the packing process.

# 3.2 Network Bandwidth

## 3.2.1 Bandwidth While Mining

While mining the network bandwidth requirements are low. The main network activities are:

1. Receive new blocks and transactions to be validated
2. Share validated blocks and transactions with peers
3. Share mined blocks with peers
4. Continue to share chunk data in order to maintain your node reputation. See [Overview - Node Reputation](../overview/node-reputation.md) for more information.

In general 100 Mbps is more than enough network bandwidth while mining.

## 3.2.2 Bandwidth While Syncing and Packing

Before you can start mining you need to download a full replica (373 TB as of November, 2025). This phase is heavily bottlenecked by available download bandwidth and CPU capacity. For example if your download bandwidth is 1 Gbps it will take over 34 days to download the full data set. The faster your download speed, the faster you can sync the dataset. CPU capacity is covered below.

The saving grace to all this is that you only need to download and pack the data once per replica. Some miners will rent CPU time and access to bandwidth to reduce the time of this phase.

# 3.3 RAM

The current recommendation is to have 1GB of RAM per partition being mined - with a minimum of 8GB. Anecdotally many miners don't exceed 500-700MB of resident memory per partition being mined.

# 3.4 CPU

The CPU requirements while mining, packing, or computing VDF differ substantially. While it's possible and common to use the same CPU while packing and mining, the optimal CPU for computing VDF is not well-suited to mining or packing. More details below.

## 3.4.1 CPU While Packing 

Packing is a parallelizable, CPU-intensive encryption process (the weave data is symmetrically encrypted using your mining address). Generally miners will sync and pack at the same time - packing data as they download it. As of November, 2025, most miners run AMD Ryzens or EPYC processors - although Intel variants are also common.

When selecting a CPU to use for packing your main metric will be how many chunks per second you can pack. Each chunk is 256KiB which means that a 373 TB full replica (as of November, 2025) contains about 1,492,000,000 chunks. You can use these values, as well as the guidance in [Operations - Benchmarking](../operations/benchmarking.md) to estimate how long your chosen CPU will take to pack a full replica. Of note: under some configurations [storage bandwidth](#314-storage-bandwidth-while-packing) and [network bandwidth](#332-bandwidth-while-syncing-and-packing) may replace the CPU as the main packing bottleneck.

## 3.4.2 CPU While Mining

CPU utilization while mining is much lower than packing. [Overview - Hashrate](../overview/hashrate.md) and [Operations - Benchmarking](../operations/benchmarking.md) provide detailed information about estimating hashrate and CPU capacity. As a rough guide you can expect 1 RandomX hash and 1,600 SHA256 hashes per partition per second. So a 100-partition miner needs to compute roughly 100 RandomX hashes (aka H0 hashes), and 160,000 SHA256 hashes (aka H1 and H2 hashes) per second. These hashing computations can be parallelized across cores.

## 3.4.3 CPU While Computing VDF

Computing VDF is a non-parallelizable, CPU-intensive process. At its core VDF is just a large number of recursive/serial SHA256 calculations. Because they are recursive (the output of one hash is used as the input to the next hash) they can **not** be parallelized across cores. VDF speed is determined by the SHA256 hashing speed of a single core.

To date the fastest VDF speed has been observed on Apple's M-class chips (e.g. M4). In order to maximize mining hashrate it's recommended that miners either run their own Mac-based VDF server, or rent access to a 3rd party Mac-based VDF server. 

When packing or simply validating the block chain, a slower VDF speed is fine. Your non-Mac CPU is likely fast enough. The Digital History Associate (DHA) team also operates a few public VDF servers running on M2 processors that are free to use.

For more information about VDF please see [Overview - VDF](../overview/vdf.md) and [Operations - Benchmarking](../operations/benchmarking.md).
