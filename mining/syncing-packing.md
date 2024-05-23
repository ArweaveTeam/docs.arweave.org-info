---
description: >-
  A guide to syncing and packing
---

# Syncing and Packing

One of the first things you'll do when mining is sync and pack some or all of the weave data.

## Syncing

"Syncing" refers to the process of downloading data from network peers. When you launch your
miner you'll configure a set of storage modules that cover some or all of the weave. Your
node will continuously check for any gaps in your configured data and then search out peers 
from which to download the missing data.

## Packing

Storage modules can be either "unpacked" (e.g. `storage_module 16,unpacked`) or "packed"
(e.g. `storage_module 16,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`). Before you can mine
data it must be packed to your mining address. There are two symmetric operations that
fall under the "packing" umbrella:

1. `pack` - Symmetrically encrypt a chunk of data with your mining address.
2. `unpack` - Decrypt a packed chunk of data.

Both operations consume roughly the same amount of computational power. See the
[benchmarking guide](hardware.md#benchmarking-your-miner) for more details.

**Note:** You will almost always have to **unpack** data when syncing it. Whichever
peer you sync the data from will likely return it to you packed to its own address. Before
you can do anything with it you will first need to unpack. You may then have to pack it to your
own address. i.e. each chunk of data synced will usually need 1-2 packing operations.

## Storage Module Format

Each storage module has 2 directories `chunk_storage` and `rocksdb`.

### `chunk_storage`

This directory stores the actual weave data in a series of roughly 2GB sparse files. Each
file contains 8000 chunks stored as `<< Offset, ChunkData >>`.

- `Offset` is a 3-byte integer used to handle partial chunks (i.e. chunks less than 256KiB).
  This is only relevant for unpacked data as packed chunks are always 256 KiB.
- `ChunkData` is the 256 KiB (262,144 bytes) chunk data.

The maximum file size is 2,097,176,000 bytes. Each file is named with the starting offset of
the chunks it contains (e.g. `chunk_storage` file `75702992896000` stores the 8000 chunks
starting at weave offset 75,702,992,896,000).

A full partition will contain 3.6 TB (3,600,000,000,000 bytes) of chunk data. Depending
on how you've configured your storage modules, your `chunk_storage` directory may only store
a subset of a partition.

The data stored may be packed or unpacked - and the two formats will often take up
**different** amount of space. For this reason we suggest you rely on the
`v2_index_data_size_by_packing` metric in order to track the amount of data that you have
synced. Diskspace measuring tools (e.g. `du`, `ls -l`) will not be able to give an accurate
measurment of the amount of weave data synced.

For reasons [explained below](#partitions-are-rarely-full) you will rarely be able to sync a
full 3.6TB partition. However,
your node will continue to search the network for missing chunks so while unlikely it is
possible that a previously "dormant" `chunk_storage` directory to see some activity if
previously missing chunk data comes online. In general, though, once you have "fully" synced
a storage_module you would expect there to be no further writes to the `chunk_storage`
directory. [Below](#partition-sizes) we provide an estimate of each partition's "full synced"
size.

### `rocksdb`

The `rocksdb` directory contains several [RocksDB](https://rocksdb.org/) databases used to
store metadata related to chunk data (e.g. record keeping, indexing, proofs, etc..).

The exact size of the `rocksdb` directory will vary over time - unlike `chunk_storage` you
should expect the `rocksdb` directory to continue to be written to as long as your node is
running. The current rough size of a `rocksdb` directory is ~100 GB (although it will vary
from partition to partition and node to node).

# Partition Sizes

## Measuring

As mentioned [above](#chunk_storage) the amount of space your data takes up on disk may
not exactly match the amount of weave data that you have synced. This is due to several
factors:
1. `chunk_storage` files are sparse
2. Users can upload partial chunk data (data that is not exactly a multiple of 256 KiB in size)
3. Unpacked data will be stored as it was uploaded with partial chunks stored sparsely at
   256 KiB boundaries
4. Packed data will always be packed to multiples of 256 KiB in size
5. The handling of partial chunks has changed a couple times during Arweave's history

For these reasons we recommend you don't rely on diskspace measuring tools (e.g. `du`,
`ls -l`) to measure the amount of weave data synced. Instead we suggest you rely on the
`v2_index_data_size_by_packing` metric, or the "Performance Mining Report" that is printed
to your console.

Sample metric data:
```
v2_index_data_size_by_packing{store_id="storage_module_19_1",packing="spora_2_6_1",partition_number="19",storage_module_size="3600000000000",storage_module_index="19"} 3110370541568
v2_index_data_size_by_packing{store_id="storage_module_1200000000000_115_1",packing="spora_2_6_1",partition_number="38",storage_module_size="1200000000000",storage_module_index="115"} 1025578106880
v2_index_data_size_by_packing{store_id="storage_module_1200000000000_114_1",packing="spora_2_6_1",partition_number="38",storage_module_size="1200000000000",storage_module_index="114"} 1195550703616
v2_index_data_size_by_packing{store_id="storage_module_1200000000000_116_1",packing="spora_2_6_1",partition_number="38",storage_module_size="1200000000000",storage_module_index="116"} 1195550703616
v2_index_data_size_by_packing{store_id="storage_module_8_unpacked",packing="unpacked",partition_number="8",storage_module_size="3600000000000",storage_module_index="8"} 2571878652607
v2_index_data_size_by_packing{store_id="default",packing="unpacked",partition_number="undefined",storage_module_size="undefined",storage_module_index="undefined"} 262144
```

This indicates that the node has:
- **3,110,370,541,568 bytes (3.1TB, 2.8TiB)** of weave synced for partition 19 
  - it is stored **packed** on disk and may take up **more** than 3.1TB of disk space
- **3,416,679,514,112 bytes (3.4TB, 3.1TiB)** synced for partition 38
  - 3,416,679,514,112 = **102,557,810,6880 + 119,555,070,3616 + 119,555,070,3616**
  - it is stored **packed** on disk and may take up **more** than 3.1TB of disk space
- **2,571,878,652,607 bytes (2.6TB, 2.3TiB)** of weave synced for partiion 8
  - it is stored **unpacked** on disk and may take up **more or less** than 2.5TB of disk space
- The `default` partition is a temporary staging partition and can be ignored

## Partitions are rarely full

You will find as you sync data that you're never able to download a full 3.6TB partition -
and in fact some partitions seem to stop syncing well short of the 3.6TB. There are 2 steps
when adding data to the Arweave network:

1. Submit a transaction with a hash of the data and a fee to reserve space in
the weave.
2. Upload the data to the weave (aka seeding).

The data that is missing from a "fully synced" partition is either data that has been
filtered out by your [content policies](https://arwiki.wiki/#/en/content-policies)
(or the content policies of your peers), or it is data that was never seeded by the uploader.

Typically there are 2 reasons why a user might not seed data after they've paid for it:
1. They're just testing / exploring the protocol
2. They're a miner experimenting with sacrifice mining

## Sacrifice Mining

Sacrifice Mining is a mining strategy where a miner will pay to upload data to the weave but
then never actually seed it. Instead they will keep and mine the data themselves, only sharing
the chunks required for any blocks they mine. The premise is that all of this "sacrificed data"
gives them a hashrate boost that other miners don't have (since the other miners are unable
to mine the unseeded data).

Sam has a good [thread](https://twitter.com/samecwilliams/status/1374062282817290247)
describing this.

The important bits:
1. Both in practice and based on economic models: sacrifice mining is not profitable. The cost
to reserve space on the weave exceeds the incremental revenue a miner can hope to get from the
additional hashrate. The payback period for the initial investment is long and gets longer
as the weave grows - in practice it is likely that a miner is never able to recoupe their
initial investment.
2. Putting aside the profitability of sacrifice mining, it is ultimately good for the network
as a whole. Sam breaks down why this is in his [thread](https://twitter.com/samecwilliams/status/1374062282817290247).

That said if you look through the partition size data below you'll notice 2 periods where
partition sizes are materially smaller than the expected 3.6TB (partitions 0-8, and 30-32). We
believe these correspond to periods when miners were experimenting with the strategy,
ultimately abandoning it as they realized it was unprofitable.

## Latest Estimated Partition Sizes

[See tables here](partition-sizes) 

{% hint style="info" %}
You'll see a table for unpacked as well as packed data. Typically these should be pretty
close (technically they should match exactly, but since this data is pull from public network
nodes we do expect slight discrepancies), but due to changes in partial chunk handling
over time, you may see some partitions with materialy different sizes. For example the 
estimated data size for partition 0 varies by about 400GB depdneing on whether it is stored
unpacked vs. packed.
{% endhint %}

{% hint style="warning" %}
These numbers are *mostly* reliable, but there is always a chance that a previously
"fully synced" partition grows in size (though never greater than 3.6TB). This can happen
any time the original uploader decides to finally seed their previously unseeded data. In
practice this gets less and less likely the older a partition is.
{% endhint %}

# Performance Tips

There are 3 primary bottlenecks when syncing and packing:

1. Your network bandwidth *(used to download chunks from peers)*
2. Your CPU *(used to pack and unpack chunks)*
3. Your disk write speed *(used to write chunks to disk)*

And to a lesser degree:

4. RAM *(more heavily used in mining than in syncing/packing, but can become a bottleneck under
  certain situations)*

If any of the 3 primary resources are maxed out: congratulations! Your configuration is syncing
and packing as fast as it can!

## Increasing Bandwidth

Not much to do here other than negotiate a faster internet connection, or find a second one.

## Increasing CPU

Packing and unpacking can be parallelized across chunks, so you can add more cores or increase
the clock speed to increase your packing speed. See the
[hardware guide](hardware.md#benchmarking-your-miner) for guidance on evaluating CPU pack
speed.

## Increasing Disk Write Speed

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

## Increasing RAM

The RAM guidelines mentioned in the [Mining Guide](mining-guide.md#preparation-ram) are
focused on mining. Often RAM is not a primary bottleneck during syncing and packing. If you
are maxing out your RAM: review the guidelines below. It's possible you can optimize your node
configuration.

## Increasing Utilization

Okay, so you've reviewed your bottlenecks and determined that **none** of them are at 
capacity. Here are some tips to increase syncing and packing speed.

### sync_jobs

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

### packing_rate

In general you shouldn't need to change `packing_rate` - the default value is usually more
than high enough. That said you can increase it with minimal risk of negative consequences.
Consult our [benchmarking guide](hardware.md#benchmarking-your-miner) to determine your CPU's
maximum packing rate and set `packing_rate` to something slightly higher.

### storage_module

As mentioned above under [Increasing Disk Write Speed](#increasing-disk-write-speed) syncing
to all your storage modules at once will maximize your available disk write bandwidth. The
same applied to network bandwidth. Adding more storage modules when syncing increases the
set of peers you can pull data from (as different peers share different parts of the weave
data). This will help your node maximize its network bandwidth by pulling from the "best" set
of peers available at a given time.

### Repacking

If you configure your node to repack from one local storage module to another the node
will prioritize that over pulling data from peers. This can cause you to max out your CPU
capacity while your network bandwidth stays low.

This is not a problem. It simply means your node will max out its CPU doing local repacks before
it begins searching for peers to download more data from. If you'd rather focus on syncing, 
just make sure to configure your node without any repacking. Two examples of configurations
that will cause local repacking:

1. `storage_module 9,unpacked storage_module 9,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`
2. `storage_module 16,Q5EfKawrRazp11HEDf_NJpxjYMV385j21nlQNjR8_pY storage_module 16,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI`

**Note:** [as mentioned earlier](#packing), whenever you sync data - even if you are syncing to
`unpacked` - you will likely have to perform at least one packing operation. 

### Multiple Full Replicas

If you intend to build more than 1 packed full replica, the following approach should get
you there fastest:

1. Download all the data to `unpacked` storage modules
2. Build each packed replica by [locally repacking](examples.md#packing-unpacked-data) from
  your `unpacked` storage modules
3. You can either keep the `unpacked` data around for later, or, you can do a
  [repack_in_place](examples.md#repacking-packed-data-in-place) when building your final
  packed replica.

This approach will reduce your download time (since you only have to download the data once)
and reduce the number of packing operations (since you only have to unpack peer data once).

**Note:** This approach is not recommended if your goal is to have 1 or fewer packed replicas.
It will work, but won't be any faster than just syncing straight to packed storage modules.

