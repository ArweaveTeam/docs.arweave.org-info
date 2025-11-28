---
description: >-
  Want to start mining on Arweave? You've come to the right place! Get set up
  with this quick and easy guide, and join our awesome network of ever-growing
  miners.
---

# Mining Guide

{% hint style="info" %}
For any questions and support queries regarding mining on Arweave, we strongly recommend that you join our [**Discord server**](https://discord.gg/GHB4fxVv8B) and visit our [Github Discussions](https://github.com/ArweaveTeam/arweave/discussions) as these are the hubs of our mining and developer communities. There you will find plenty of community members and Arweave team members available to help you out 🤖
{% endhint %}

{% hint style="warning" %}
Miners are responsible for their own compliance with data protection laws (such as GDPR) and other applicable laws in their jurisdiction. Data storage laws vary country to country. Failure to adhere to these laws may entail substantial legal risks for the miner. Please only participate in mining Arweave data if you have understood the legal implications of doing so and consider seeking legal advice.&#x20;
{% endhint %}


## Preparation


### Preparation: Packing Format

Before you can configure your storage you'll have to decide on a packing format. The legacy packing format, `spora_2_6`, is still supported, but for new packs we recommend using the new `replica.2.9` format. The `replica.2.9` can be packed more quickly and with lower CPU requirements. Additonally while mining data packed to `replica.2.9` your optimal read rate is just 5 MiB/s per partition vs. 200 MiB/s for `spora_2_6`. This table summarizes the differences:

| Packing Format | Time to pack (benchmarked to spora_2_6) | Disk read rate per partition when mining against a full replica |
|----------------|-----------------------------------------|--------------------------------------------------------|
| `spora_2_6`    | 1x                                      | 200 MiB/s                                              |
| `replica.2.9`  | TBD (but more quickly)                  | 5 MiB/s                                                |

If we assume that a good quality enterprise hard disk drive can sustain 200 MiB/s read rate, then with `spora_2_6` you could only store a single 4TB partition per 4TB HDD. However with `replica.2.9` you could conceivably store and mine 40x 4TB partitions (or 160 TB) on a single  HDD - well beyond the capacity of today's HDDs. 

Note: The effective hashrate for a full replica packed to any of the supported packing formats is the same. A miner who has packed a full replica to `spora_2_6` or `replica.2.9` can expect to find the same number of blocks on average, but with the `replica.2.9` miner reading fewer chunks from their storage per second. This allows the miner to use larger hard drives in their setup, without increasing the necessary bandwidth between disk and CPU.

Also note: When mining, all storage modules within the same replica must be packed to the same packing format. For example, a single miner will not be able to build a solution involving chunks from `storage_module_1_addr` and `storage_module_2_addr.replica.2.9` even if the packing address is the same.

For guidance on how to pack your data see the example configurations in the [Examples](examples.md) guide.

The packing format you select will influence what hardware configuration provides the best return. For more information on mining hardware see the [Hardware Guide](setup/hardware.md).

#### Copying Data Across Storage Modules

When a node starts, it copies (and packs, if required) the data from one storage module to another, in the case when there are two or more intersecting storage modules. For example, if you specify `storage_module 11,unpacked storage_module 11,[mining_address].replica.2.9` and there is some data in the "unpacked" module that is absent from the "mining address" module, the data will be packed with this mining address and stored in `11,[mining_address].replica.2.9`.

If you want to repack a storage module, do not rename the existing one - renaming will not cause repacking, create a new storage module instead.

#### Unpacked Storage Modules

If you want to sync many replicas of the weave, it makes sense to first create an "unpacked" replica. Then, packing for each mining address will be two times faster compared to repacking a replica packed with another mining address. To configure a storage module for storing unpacked data, specify "unpacked" instead of the mining address.

For example, to sync an unpacked partition 12, specify `storage_module 12,unpacked` on startup. As with the other storage modules, make sure the `[data_dir]/storage_modules/storage_module_12_unpacked` folder resides on the desired disk (if you do not create the directory in advance, the node will create it for you so the data will end up on the disk `[data_dir]/storage_modules`is mounted to.) After the replica is synced, you can copy it to the other machines where its contents would be copied and packed for the storage modules you configure there.

### Preparation: RAM

- **Minimum**: 8 GB + 1 GB per mining partition
- **Recommended**: 8 GB + 2 GB per mining partition

The node determines the amount of chunks to read in memory while mining automatically. If your node runs out of memory anyway, try setting the `mining_server_chunk_cache_size_limit` option in the command line (specify the number of 256 KiB to cache).




If you would like to see a log of your miner’s activity, you can run `./bin/logs -f` in the Arweave directory in a different terminal. Sometimes it is helpful to look at the debug logs which are written if the node is started with the `debug` flag in the command line - `./bin/debug-logs -f`

The mining console should eventually look like this:

```
============================ Mining Performance Report ===============================

VDF Speed: 1.00 s
H1 Solutions: 0
H2 Solutions: 0
Confirmed Blocks: 0
Local mining stats:
```

#### Receiving Mining Rewards

When you mine a block, the console shows:

```
Produced candidate block ....
```

Approximately 20 minutes later, you should see

```
Your block ... was accepted by the network!
```

Note that occasionally your block won't be confirmed (the chain chooses a different fork).

{% hint style="warning" %}
You do not immediately receive the block reward after mining a block. There is a delay in the release of block rewards for miners by approximately thirty days or 30 \* 24 \* 30 blocks. Your node does **not** need to stay online in order to receive your reserved mining rewards. This mechanism is designed to discourage signing the same block several times and several competitive forks in general - the network detects these cases and may slash the reserved rewards and revoke the mining permission from the corresponding mining address. Also, the mechanism incentivizes miners to be aligned with the network for at least the medium-term.
{% endhint %}

{% hint style="info" %}
To see the total number of Winston (divide by 1000_000_000_000 to get the AR value) reserved for you address, browse to https://arweave.net/wallet/\[your-mining-address]/reserved\_rewards\_total.
{% endhint %}

#### Staying in Sync

Watch for the following warnings in your mining console:

{% code overflow="wrap" %}

```
WARNING: Peer 138.197.232.192 is 5 or more blocks ahead of us. Please, double-check if you are in sync with the network and make sure your CPU computes VDF fast enough or you are connected to a VDF server.
```

{% endcode %}

If you see them shortly after joining the network, see if they disappear in a few minutes - everything might be fine then. Otherwise, it is likely your processor cannot keep up with VDF computation or there are network connection issues. While VDF execution is done by a single core/thread, the validation of the VDF checkpoints in a block header can be done in parallel (with multiple threads). To speed up VDF validation, try restarting the node with a higher value for `max_vdf_validation_thread_count` (e.g., the number of CPU threads - 1).

#### Defragmenting Storage

Due to Arweave node specifics (storing data in the sparse files), the read throughput during mining after the initial sync might be suboptimal on some disks. In the performance reports printed in the console you can see the estimated optimal performance in MiB/s, per configured storage module. The first number estimates the optimum on a small dataset, the second - on the dataset close in size to the weave size. If the actual performance of a storage module is noticeably lower, consider running a defragmentation procedure to improve your mining performance on this module. (Re)start the miner with the following parameters (in this example, the storage module storing the partition 8 will be defragmented):

```
./bin/start run_defragmentation defragment_module 8,YOUR-MINING-ADDRESS.replica.2.9 defragmentation_trigger_threshold 500000000 ...
```

The defragmentation is performed before startup. Only chunk files larger than `defragmentation_trigger_threshold` bytes and those which have grown by more than 10% since the last defragmentation of this module will be updated. Note the defragmentation may take a lot of time.



## Troubleshooting

### Make sure your node is accessible on the Internet

An important part of the mining process is discovering blocks mined by other miners. Your node needs to be accessible from anywhere on the Internet so that your peers can connect with you and share their blocks.

To check if your node is publicly accessible, browse to `http://[Your Internet IP]:1984`. You can [obtain your public IP here](https://ifconfig.me/), or by running `curl ifconfig.me/ip`. If you specified a different port when starting the miner, replace "1984" anywhere in these instructions with your port. If you can not access the node, you need to set up TCP port forwarding for incoming HTTP requests to your Internet IP address on port 1984 to the selected port on your mining machine. For more details on how to set up port forwarding, consult your ISP or cloud provider.

If the node is not accessible on the Internet, the miner functions but is significantly less efficient.

## Staying up to Date

- Join our [Discord](https://discord.gg/GHB4fxVv8B) server
- Visit our [Github Discussions](https://github.com/ArweaveTeam/arweave/discussions)

Once you are successfully mining on the Arweave, you will need to stay up to date with new releases. Check the #announcements channel on the Arweave Miners discord server to learn about new releases. We will announce any steps you need to take to stay up to speed - particularly updates that require you to perform an action within a certain time period in order to stay in sync with the network.
