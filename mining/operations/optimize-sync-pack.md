---
description: >-
  Tips for optimizing the sync and pack process
---

# 1. Overview

**Most important performance tip:** Do not mine while you pack. The two processes are both resource intensive and will slow each other down. (i.e. omit the `mine` flag from your configuration) If you've already removed the `mine` flag, continue on below for more optimization tips.

There are 3 primary bottlenecks when syncing and packing:

1. Your network bandwidth *(used to download chunks from peers)*
2. Your CPU *(used to pack and unpack chunks)*
3. Your disk write speed *(used to write chunks to disk)*

And to a lesser degree:

4. RAM *(more heavily used in mining than in syncing/packing, but can become a bottleneck under
  certain situations)*

If any of the 3 primary resources are maxed out: congratulations! Your configuration is syncing
and packing as fast as it can!

# 2. Increasing Bandwidth

Not much to do here other than negotiate a faster internet connection, or find a second one.

# 3. Increasing CPU

Packing and unpacking can be parallelized across chunks, so you can add more cores or increase
the clock speed to increase your packing speed. See the
[Benchmarking](benchmarking.md) guide for guidance on evaluating CPU pack
speed.

# 4. Increasing Disk Write Speed

During the syncing and packing phase you will typically hit a network bandwidth or CPU
bottleneck before you hit a disk IO bottleneck (the reverse is true once you start mining).

If you believe you've hit a disk IO bottleneck you have a few options.

First, confirm that you're getting your expected disk write speed. You can use tools like `fio`
or `dd` to measure your disks write speed. If it is below your expected speed, you'll want to
check your system configuration (software and hardware) for issues. 

Second, you can add more disks to your node. This is really only relevant if you have
partitions that you intend to sync and pack but which you haven't added to your node
configuration. As a general rule you should add all your storage modules to your node while
syncing and packing as this will increase your disk IO bandwidth as well as help fully
use your network and CPU bandwidth.

Third, you can buy faster disks. This is generally not recommended to unblock a syncing and
packing bottleneck as there's a good chance that extra IO speed will go unused once you
start mining. Including it here for completeness.

# 5. Increasing RAM

The RAM guidelines mentioned in the [Guide](mining-guide.md#preparation-ram) are
focused on mining. Often RAM is not a primary bottleneck during syncing and packing. If you
are maxing out your RAM: review the guidelines below. It's possible you can optimize your node
configuration.

# 6. Increasing Utilization

Okay, so you've reviewed your bottlenecks and determined that **none** of them are at 
capacity. Here are some tips to increase syncing and packing speed.

## 6.1 sync_jobs

The `sync_jobs` flag controls the number of concurrent requests your node will make to peers
to download data. The default is `100`. Increasing this number should increase your utilization
of all resources: the amount of data you pull from peers (network bandwidth), the number of
chunks you're packing (CPU), and the volume of data written to disk (disk IO).

However, it is possible to increase this number **too much**. This can:

1. Cause your node to be rate-limited / throttled by peers and ultimately decrease your
bandwidth utilization.
2. Increase your RAM utilization due to backed up sync jobs. This is particularly common if
your miner has a poor network connection (e.g. high latency or data loss). Increasing the
volume of slow/hanging requests can cause a backup which eventually leads to an out of memory
error.

Setting `sync_jobs` to `200` or even `400` is unlikely to cause any issues. But before you
increase it even further our recommendation is to first confirm:
1. Your CPU and network bandwidths are below capacity
2. Your network connectivity is good (e.g. using tools like `mtr` to track packet loss)

## 6.2 storage_module

As mentioned above under [Increasing Disk Write Speed](#4-increasing-disk-write-speed) syncing
to all your storage modules at once will maximize your available disk write bandwidth. The
same applied to network bandwidth. Adding more storage modules when syncing increases the
set of peers you can pull data from (as different peers share different parts of the weave
data). This will help your node maximize its network bandwidth by pulling from the "best" set
of peers available at a given time.

## 6.3 Repacking

If you configure your node to repack from one local storage module to another the node
will prioritize that over pulling data from peers. This can cause you to max out your CPU
capacity while your network bandwidth stays low.

This is not a problem. It simply means your node will max out its CPU doing local repacks before
it begins searching for peers to download more data from. If you'd rather focus on syncing, 
just make sure to configure your node without any repacking. Two examples of configurations
that will cause local repacking:

1. `storage_module 9,unpacked storage_module 9,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`
2. `storage_module 16,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY.replica.2.9 storage_module 16,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

**Note:** As mentioned in [Syncing & Packing](../overview/syncing-and-packing.md#2-packing), whenever you sync data - even if you are syncing to
`unpacked` - you will likely have to perform at least one packing operation. 

## 6.4 Multiple Full Replicas

If you intend to build more than 1 packed full replica, the following approach should get
you there fastest:

1. Download all the data to `unpacked` storage modules
2. Build each packed replica using [Cross-Module Repacking](../setup/configuration.md#21-cross-module-repack) from
  your `unpacked` storage modules
3. You can either keep the `unpacked` data around for later, or, you can do a
  [Repack-in-Place](../setup/configuration.md#22-repack-in-place) when building your final
  packed replica.

This approach will reduce your download time (since you only have to download the data once)
and reduce the number of packing operations (since you only have to unpack peer data once).

**Note:** This approach is not recommended if your goal is to have 1 or fewer packed replicas.
It will work, but won't be any faster than just syncing straight to packed storage modules.

