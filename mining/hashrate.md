# Understanding Hashrate

**Original Author: @Thaseus**

A guide to understanding the fundamentals of AR hashrate and its many variables

{% hint style="warning" %}
The following guide assumes all data is packed using the deprecated `spora_2_6` format, which requires a read rate of 200 MiB/s per partition. For all new packs we recommend using the `composite` format which allows a lower read rate per partition (see [Packing Format](mining-guide.md#Preparation-Packing-Format) for more information). 

This guide should be updated in the future to provide guidance for `composite` format packs.
{% endhint %}

## Preface

This guide provides general information regarding hashrate estimations and discusses the various factors that influence these hashrates. The details presented here are accurate for version 2.7.4 (August 2024). As AR mining evolves, fundamentals may change; every effort will be made to keep this document current.

It is important to note that this document does not guarantee specific hashrates. Each system and its underlying hardware are unique, resulting in different potential hashrates for every miner. Therefore, variances in the values and details provided throughout this document should be expected.

## Hashrate Variables Under Your Control

Several variables contribute to your final hashrate. The key variables you can control are hard drive read speed and the number of fully packed storage modules. The ultimate goal is to achieve the best possible read speed and ensure all storage modules are fully packed, thereby maximizing your hashrate. For the purposes of this section, assume the values discussed are intended to provide optimal hashrate. Lower values may still be acceptable depending on your specific requirements.

### Number of fully packed storage modules

The number one priority is to pack the entire weave into storage modules. This can be accomplished either individually (solo or through [Vird’s Pool](https://ar.virdpool.com/) | [Discord](https://discord.gg/hTCmhGWPEp)) or by sharing a weave with others (e.g. on [Vird’s Pool](https://ar.virdpool.com/) | [Discord](https://discord.gg/hTCmhGWPEp)).

Consider the following example to understand the importance of having all partitions packed. If you possess 50% of the weave (29 partitions), you will generate up to 25% of the maximum possible hashrate. At 75% of the weave (43 partitions), your hashrate will be closer to 50% of the maximum. Packing from the 43rd partition to the full 58 partitions will yield the remaining 50% of the hashrate.

This example is based on the current requirement of 58 partitions and will change over time. However, the underlying principle remains the same: without most or all partitions packed, your hashrate will be significantly lower than those who have them fully packed.

### Read speed of your hard drive

Following the packing of the entire weave, the next critical metric is the read speed of your hard drive. Without delving into excessive detail (further research may be beneficial), it is important to note that hard drives do not sustain their rated read speed across their entire capacity. For example, if a drive is rated at 226MB/s, its actual range is likely closer to...
       
         130MB/s (123MiB/s)     to      226MB/s (215MiB/s)

However, it is important to note that while older drives are rated in MB/s, newer drives are rated in both MB/s and MiB/s.

**1 MB/s ≈ 0.95 MiB/s**

Arweave uses MiB/s as the preferred metric.

For optimal performance with Arweave, your hard drive needs to sustain a read speed of 200 MiB/s throughout the mining process.

Achieving a consistent read speed of 200 MiB/s can be challenging with an older 4TB drive, which is the maximum size for each partition. Consequently, some miners opt for larger or newer drives that offer higher read speeds. This decision is up to you; however, without an average read speed of at least 200 MiB/s, you will not achieve the maximal hashrate.

Not achieving maximal hashrate is OK, as long as it’s close enough and within your budget to implement. Instead, focus on finding drives within your budget that provide the minimum acceptable performance. It is strongly recommended to select drives rated at or above 215 MB/s (older drives were rated in MB/s).
For context, an older 4TB drive rated at 226 MB/s represents some of the highest speed drives from the 2017-2018 era. These drives can range from 183 MB/s for older, slower models to the 290 MB/s range for top-of-the-line new drives available this year. Purchase the best drives that meet your budget to achieve optimal results.

## Hashrate Formula?

While there is an official formula for calculating the absolute maximum hashrate possible, it does not accurately account for the read speed of your hard drives and the missing data from the storage modules in the chain. At the protocol level, assuming perfect read speed, all partitions packed, and a fully utilized weave, you would ideally generate 404 h/s per storage module.

However, this ideal scenario is unattainable as the weave currently has gaps where storage space has been purchased but not yet filled (for more information on this see the [Syncing and Packing Guide](syncing-packing.md#partitions-are-rarely-full)). Presently, the network is 86% full. As new storage modules (partitions) are filled, this percentage will likely increase, gradually raising the overall maximum hashrate possible per storage module.

Below, you will find a custom hashrate formula that considers all relevant variables to provide a highly accurate hashrate estimate. It is crucial not to overestimate the read speed you can achieve, as doing so will result in inaccurate values.

### Formula

For a 100% perfect hashrate as of mid August 2024, it would be…

| Base hashrate                   | Read speed modifier | VDF speed modifier | Hashrate (H/S) | 
| ------------------------------- | ------------------- | ------------------ | -------------- |
| (404 * 58 * (58 / 58) * 0.86) * | (200 / 200) /       | 1                  | = 20,151       |

For a more typical hashrate as of mid August 2024, it would be…

`(404 * 58 * (58 / 58) * 0.86) * (155 / 200) / 1 = 15,617`


Hashrate formula explained

```
( 404              * 58                * (58                / 58)               * 0.86            )
( max h/s possible * packed partitions * (packed partitions / total partitions) * % of Weave used )
```

**Multiplied by**

```
( 155                                                / 200                          )
( your avg read speed in MiB/s across all partitions / required read speed in MiB/s )
```

**Divided by**

```
1
VDF speed modifier (target is 1 second)
```

Unfortunately, it is impossible to achieve an average read speed of 200 MiB/s across all partitions, as some partitions are not full and read rates are often overestimated by miners. Very decent 4TB drives can provide an average read speed in the 170s MiB/s for fully packed drives, but the speeds for partially filled drives will be lower due to missing data.

For estimation purposes, if you are not entirely certain, use an average read speed of 155 MiB/s across all drives until you can observe your own real-world values. This will provide a reasonable hashrate expectation. If you aim to achieve a higher read rate, consider purchasing larger and faster drives, albeit at an increased cost.

Disclaimer: This formula is simplified to a single formula of the H2 Solutions, and not an H1 / 100 + H2 formula. This simplified formula gives you an accurate representation down to less than 1% deviation and makes it easier to understand.

## Troubleshooting Your Hashrate / Common Questions

Below are some common complaints/scenarios from newer miners in regards to their hashrate. While this list is not exhaustive, it will likely point you in the right direction of a solution.

### A new miner is impatient and they are trying to mine while packing

- It is always better to pack all of your partitions before starting to mine
- Mining while packing will take many times longer than simply packing, then mining

### “I packed all of my partitions onto my one server, but my hashrate is very low”

- Most miners will need several servers in order to mine via Coordinated Mining as the CPU capabilities of traditional PC’s, or basic used servers are not powerful enough to handle 50+ partitions

### “I have a bottleneck in my system affecting my read speed”

- Slow hard drives
- PCIe bandwidth issues
- Slow SAS speeds / SAS expander maxed out
- Slow CPU
- Bad configuration
- Thermal throttling of HBA, CPU, etc
- You have not packed all of your partitions

### “I have coordinated mining nodes, all partitions are packed, but my hashrate is low”
- Confirm network settings / connectivity with your CM nodes
- Make sure you are seeing stats appear in the CM section of the miner screen
- Check your configuration

### “My hashrate is very low”

- Have you packed ALL partitions? If no, then do that first.
- Have you reviewed the hashrate formula above to identify expected hashrate?

### My hashrate fluctuates wildly on the mining screen

- Yes it does, but do not worry about the “Current” fields, only review the “Averages”, and please note, the averages take several hours to stabilize

