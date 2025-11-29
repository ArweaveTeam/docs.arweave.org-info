---
description: >-
  Understanding your miner's hashrate
---
**Adapted from a guide originally written by @Thaseus**

A guide to understanding the fundamentals of AR hashrate and its many variables

# 1. Overview

This guide provides general information regarding hashrate estimations and discusses the various factors that influence these hashrates. As AR mining evolves, fundamentals may change; every effort will be made to keep this document current.

It is important to note that this document does not guarantee specific hashrates. Each system and its underlying hardware are unique, resulting in different potential hashrates for every miner. Therefore, variances in the values and details provided throughout this document should be expected.

# 2. Hashrate Variables Under Your Control

Several variables contribute to your final hashrate. The key variables you can control are hard drive read speed and the number of fully packed storage modules. The ultimate goal is to achieve the best possible read speed and ensure all storage modules are fully packed, thereby maximizing your hashrate. For the purposes of this section, assume the values discussed are intended to provide optimal hashrate. Lower values may still be acceptable depending on your specific requirements.

## 2.1 Number of fully packed storage modules

The number one priority is to pack the entire weave into storage modules. This can be accomplished either individually (solo or through [Vird’s Pool](https://ar.virdpool.com/) | [Discord](https://discord.gg/hTCmhGWPEp)) or by sharing a weave with others (e.g. on [Vird’s Pool](https://ar.virdpool.com/) | [Discord](https://discord.gg/hTCmhGWPEp)).

Consider the following example to understand the importance of having all partitions packed. If the weave has 100 partitions and you have 50% of them fully packed (50 partitions), you will only generate up to 25% of the maximum possible hashrate. At 75% of the weave (75 partitions), your hashrate will be closer to 50% of the maximum. We'll break down the math below, but it's important to highlight the underlying principle: without most or all partitions packed, your hashrate will be significantly lower than those who have them fully packed.

## 2.2 Read speed of your hard drive

The next critical metric is the read speed of your hard drive. If you have the weave fully packed, you will need to sustain on average 5 MiB/s read speed per partition. This data is read from 2 different 2.5 MiB ranges and will typically involve a disk seek. If you are mining on 16 TB disks each storing 4 partitions, you will need to sustain a 20 MiB/s read rate across 8 seeks. Dropping below this read rate is fine, it will just mead a lower hashrate - but there are no other penalties.

Note: In earlier versions of Arweave the required read rate was 200 MiB/s per partition (40x higher than it is now). At that time the disk read rate was far more critical and difficult to achieve.

## 2.3 Note on Terminology and Units

KB and KiB, MB and MiB, TB and TiB are all, confusingly, different metrics. The world (including the Arweave documentation) does not use the consistently.

- 1 KB = 1,000 bytes
- 1 KiB = 1,024 bytes
- 1 MB = 1,000,000 bytes
- 1 MiB = 1,048,576 bytes
- 1 TB = 1,000,000,000 bytes
- 1 TiB = 1,073,741,824 bytes

You will note that many drives report their capacity and read rate in MB and TB whereas the target read rates listed above are in MiB/s. You can do the math as needed, ignore the difference, or use this rough guide:

**1 MB/s ≈ 0.95 MiB/s**

# 3. Hashrate Formula

There is a formula you can use to estimate your hashrate. It is based on several factors:
1. Amount of data packed
2. VDF speed
3. Disk Read Rate

The number that comes out is then normalized.

## 3.1 The Normalization Factor

As described in the [Understanding Mining](mining.md#2-hash-your-data) guide a miner will generate 640 raw hashes for each 5 MiB of data it reads. For historical reasons when reporting the hashrate we normalize that number to 400. This is due to earlier versions of the protocol that yielded a different number of raw hashes for each range of data read - normalizing to 400 was necessary to ensure all packing formats yielded the same chance of finding a valid solution.

After normalizing to 400 we discount the H1 hashes by 100x. This has to do with how a hash is compared with the network difficulty to determine whether it is a valid solution.

1. Network difficulty is pulled from the latest valid block
2. Each hash is converted to a decimal number
3. The H1 hash is compared with 100x the difficulty, the H2 hash is compared with difficulty as it is.

This has the effect of making it 100x harder for each H1 hash to yield a valid solution. Another way to represent this is just to say each H1 hash is worth 1/100 of an H2 hash.

The end result is that, in an ideal scenario with a fully packed weave, each partition yields 404 normalized hashes.

### 3.1.2 Why discount H1?

The H1 hash is discounted to provide a strong financial incentive for miners to pack the full weave - or to collaborate with other miners to pack the full weave. Since the H2 hash is selected across the full weave a miner who packs the same partition multiple times will have a lower effective hashrate than a miner who packs different partitions. This helps ensure that all weave data is replicated equally and is the underlygin principle mentioned [above](#21-number-of-fully-packed-storage-modules).

## 3.2 Ideal Hashrate

If the full weave is 100 partitions, an ideal miner will have these characteristics:

- 360TB of packed data (3.6TB per partition)
- VDF Speed: 1s
- Sustained disk read speed fo 5 MiB/s per partition

This ideal miner will have an effective hashrate of 40,400:

| H1         | H2           | VDF  | Hashrate
| ---------- | ------------ | ---- | --------
| (4 x 100 + | 400 x 100) / | 1s = | 40,400

That means they have 40,400 chances every second to find a valid solution.

## 3.3 Real Hashrate

In practice the ideal never exists, this ideal scenario is unattainable as the weave currently has gaps where storage space has been purchased but not yet filled (for more information on this see the [Syncing and Packing Guide](syncing-and-packing.md#42-partitions-are-rarely-full)). The impact of these gaps varies, as of August, 2024 the weave was about 86% full. As new storage modules (partitions) are filled, this percentage will likely increase, gradually raising the overall maximum hashrate possible per storage module.

We'll now walk through n example for a miner with sub-optimal characteristics:

- 240 TB of packed data
  - for simplicity we'll represnt this as having 66% of the weave
- VDF Speed: 1.05s
- Sustained disk read speed of 2 MiB/s per partition
  - for simplicity we'll represent this as being to read 40% of each dat arange

| H1                       | H2                               | VDF     | Hashrate
| ------------------------ | -------------------------------- | ------- | --------
| (4 x 0.4 x 100 x 0.66  + | 400 x 0.4 x 100 x 0.66 x 0.66) / | 1.05s = | 6,738

Breakin that down a bit:
- The 0.4 multiplier indicate that for each range the miner is allowed to read, it can only read 40% of it in time, reducing the hashes it can generate
- The 0.66 term under H1 indicates that there is only a 66% change that the randomly selected partition offset falls in data that the miner has packed
- The (0.66 x 0.66) erm under H2 indicates that the unmpacked data has a quadratic impact on H2 hashes. For each missing H1 hash the miner loses the opportunity to even select an H2 offset (the first 0.66 term). And even when the miner is able to gnerate an H1 hash, there is only a 66% change that the full-weave H2 offset falls in data that the miner has packed.
- Finally the 1.05s VDF indicates that because the miner's VDF is slow it only gets a chance at generating hashes ever 1.05 seconds and not ever second (a loss of 5% hashrate)