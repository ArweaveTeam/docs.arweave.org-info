---
description: >-
  A guide to syncing and packing
---

One of the first things you'll do when mining is sync and pack some or all of the weave data.

# 1. Syncing

"Syncing" refers to the process of downloading data from network peers. When you launch your
miner you'll configure a set of storage modules that cover some or all of the weave. Your
node will continuously check for any gaps in your configured data and then search out peers 
from which to download the missing data.

# 2. Packing

Storage modules can be either "unpacked" (e.g. `storage_module 16,unpacked`) or "packed"
(e.g. `storage_module 16,En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`). Before you can mine
data it must be packed to your mining address. There are two symmetric operations that
fall under the "packing" umbrella:

1. `pack` - Symmetrically encrypt a chunk of data with your mining address.
2. `unpack` - Decrypt a packed chunk of data.

Both operations consume roughly the same amount of computational power. See the
[Benchmarking Guide](../operations/benchmarking.md) for more details.

As of Arweave 2.9 there is one main packing format: `replica.2.9`. You can read the full [Arweave 2.9 Whitepaper here](https://github.com/ArweaveTeam/arweave/blob/master/papers/arweave2_9_2024.pdf). Put simply: the intent is for packing to be an expensive operation - expensive enough that the most profitable strategy is to pack data once and store it to disk rather than store the data unpacked and pack it "on demand". The Arweave packing format relies heavily on [RandomX](https://xmrig.com/benchmark) to implement this cost/benefit tradeoff.

**Note:** You will almost always have to **unpack** data when syncing it. Whichever
peer you sync the data from will likely return it to you packed to its own address. Before
you can do anything with it you will first need to unpack. You may then have to pack it to your
own address. i.e. each chunk of data synced will usually need 1-2 packing operations.

## 2.1 Packing Processes

There are 3 ways to get packed data:

1. **Sync and Pack**: Used when you don't have any data locally. Your node will query chunk
data from peers, unpack it from the peer's address, pack it to your address, and then store it
in your storage module.
2. **Cross Module Repack**: Used when you have data locally but want to repack it to a
different format or address. Your node will read data from one storage module, repack it, and
then write it to a different storage module.
3. **Repack In Place**: Used when you have data locally and want to repack it to a different
format or address and then store it back in the same storage module. Your node will iterate
through your storage module, read chunks, repack them, and then write them back to the same
storage module.

See [Running Your Node](../setup/configuration.md) for a sample configurations of each packing type.

## 2.2 Replica 2.9 Entropy Generation

Starting with the `replica.2.9` format introduced in Arweave 2.9, the packing process is
broken into 2 steps:

1. **Entropy Generation**: Generate a random entropy value for each chunk.
2. **Packing**: Encrypt the chunk data using the entropy value.

Currently the recommended approach when using "Sync and Pack" or
"Cross Module Repack" is to first generate entropy for an entire partition, and then pack data
for it. This is not possible with "Repack In Place" so no special handling is needed for it.
See [Running Your Node](../setup/configuration.md) for for guidance on how to do this.

# 3. Storage Module Data Format

Each storage module has 2 directories `chunk_storage` and `rocksdb`.

## 3.1 `chunk_storage`

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
measurement of the amount of weave data synced.

For reasons [explained below](#42-partitions-are-rarely-full) you will rarely be able to sync a
full 3.6TB partition. However,
your node will continue to search the network for missing chunks so while unlikely it is
possible that a previously "dormant" `chunk_storage` directory to see some activity if
previously missing chunk data comes online. In general, though, once you have "fully" synced
a storage_module you would expect there to be no further writes to the `chunk_storage`
directory. [Below](#4-partition-sizes) we provide an estimate of each partition's "full synced"
size.

## 3.2 `rocksdb`

The `rocksdb` directory contains several [RocksDB](https://rocksdb.org/) databases used to
store metadata related to chunk data (e.g. record keeping, indexing, proofs, etc..).

The exact size of the `rocksdb` directory will vary over time - unlike `chunk_storage` you
should expect the `rocksdb` directory to continue to be written to as long as your node is
running. The current rough size of a `rocksdb` directory is ~100 GB (although it will vary
from partition to partition and node to node).

# 4. Partition Sizes

## 4.1 Measuring

As mentioned [above](#31-chunk_storage) the amount of space your data takes up on disk may
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
- **2,571,878,652,607 bytes (2.6TB, 2.3TiB)** of weave synced for partition 8
  - it is stored **unpacked** on disk and may take up **more or less** than 2.5TB of disk space
- The `default` partition is a temporary staging partition and can be ignored

## 4.2 Partitions are rarely full

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

# 5. Sacrifice Mining

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
as the weave grows - in practice it is likely that a miner is never able to recoup their
initial investment.
2. Putting aside the profitability of sacrifice mining, it is ultimately good for the network
as a whole. Sam breaks down why this is in his [thread](https://twitter.com/samecwilliams/status/1374062282817290247).

That said if you look through the partition size data below you'll notice 2 periods where
partition sizes are materially smaller than the expected 3.6TB (partitions 0-8, and 30-32). We
believe these correspond to periods when miners were experimenting with the strategy,
ultimately abandoning it as they realized it was unprofitable.

# 6. Latest Estimated Partition Sizes

[See tables here](estimated-partition-sizes.md) 

You'll see a table for unpacked as well as packed data. Technically these sizes should match
exactly however

1. The data is pulled from public network nodes so we expect some slight discrepancies based
on which specific data each node has synced
2. Due to changes in partial chunk handling over time, you may see some partitions with
materially different sizes.

For example the  estimated data size for partition 0 varies by about 400GB depending on whether
it is stored unpacked vs. packed.

{% hint style="warning" %}
These numbers are *mostly* reliable, but there is always a chance that a previously
"fully synced" partition grows in size (though never greater than 3.6TB). This can happen
any time the original uploader decides to finally seed their previously unseeded data. In
practice this gets less and less likely the older a partition is.
{% endhint %}

