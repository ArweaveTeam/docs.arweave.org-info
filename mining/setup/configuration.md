---
description: >-
  A guide to configuring and running your node for different purposes
---

# 0. Overview

Arweave provides a number of configuration options to control, customize, and tune its operation. This guide will describe the main operating phases for different [node types](../overview/node-types.md) and provide example configurations you can adapt as needed.

# 0.1 Run-script

We recommend using the `./bin/start` wrapper script to run your node. This script wraps the core [Arweave entrypoint](../operations/entrypoint.md) with naive auto-restart functionality. If your node crashes, `./bin/start` will wait 15 seconds and then restart it with the same configuration.

{% hint style="warning" %}
Avoid killing the arweave process if at all possible. I.e. **don't** do `kill -9 arweave` or `kill -9 beam` or `kill -9 erl`. To stop the arweave process, use `./bin/stop` and then wait for as long as you can for the node to shutdown gracefully. Sometimes if can take a while for the node to shutdown, which we realize is frustrating, but if you kill the node abruptly it can cause `rocksdb` corruption that can be difficult to recover from. In the worst case you may need to resync and repack a partition. If you can't wait, we recommend using `kill -1` rather thank `kill -9`.
{% endhint %}

# 0.2 Keeping the Miner Running

Linux provides many way to run an application in the background or as a daemon so that it will keep running even after you've exited your shell or closed your remote connection. You can likely use any approach your comfortable with. Many miners use the `screen` session manager, e.g.:

```sh
screen -dmSL arweave ./bin/start config_file config.json
```

This will start your node in the background, piping console output to a file named `screenlog.0` and keep your node running after you exit your shell.

In order to bring your node to the foreground:

```sh
screen -r
```

You can read more about `screen` [here](https://www.gnu.org/software/screen/manual/screen.html).

# 0.3 Command-line vs. Configuration File

When running your node you can configure it via command-line arguments as well as via a json file. To load configuration from a json file you specify the `config_file YOURFILE.json` command-line argument. You can use both command-line arguments and a config.json but in general we recommend against mixing as it can be confusing if there are conflicts between the two.

# 0.4 Required Options

All node types and operating phases require at least the following options

- `data_dir`: indicates where the node should store indices and metadata. See [Directory Structure](directory-structure.md)
- `peer`: specifies the node's [Trusted Peers](../overview/trusted-peers.md). Your node will use these peers when it initially joins the network so it is important that you trust them to behave honestly.

# 1. Mining

There are 3 main phases when running a miner that apply to Solo Miners, Coordinated Miners, and Pool Miners:

1. Entropy Generation
2. Syncing & Packing
3. Mining

Refer to the [Syncing & Packing](../overview/syncing-and-packing.md) and [How Mining Works](../overview/mining.md) guides for more information on the 3 phases. This guide will focus on the configuration options required for each.

As you complete each phase you'll want to shutdown your node, update its configuration, and restart it.

**Note:** It is possible to run all 3 phasees concurrently (e.g. generate entropy while you sync and pack new data and mine any packed data). Prior to Arweave 2.9.5 this was discouraged as it reduced performance and often caused out-of-memory issues. However since the release of 2.9.5 many of the memory issues have been addressed so you **may** have more luck running the different phases concurrently. We still recommend generating entropy first as it should allow everything to complete more quickly, but you may be able to mine efficiently while syncing & packing. As with many things, it will likely depend on your specific node, system, and hardware configuration.

## 1.1 Entropy Generation

While it is possible to generate entropy while you sync and pack, the current guidance is that separating the two phases provides better performance. During entropy generation you node will generate and write to disk the entropy needed to pack all of your configured storage modules. 

As noted in the [Syncing & Packing](../overview/syncing-and-packing.md) guide some partitions are smaller than others due to unseeded data. This is **not** the case for entropy: all partitions will generate 3.6TB of entropy. If you've budgeted enough storage capacity to [allow 4TB per partition](directory-structure.md#4-storage-modules) this will generally be fine 0 3.6TB of entropy plus ~10% extra for needed metadata. However some of the earlier partitions (notably partitions 0 and 1) sometimes need more than 400GB of space for their metadata. For those partitions you may find yourself exceeded 4TB during the entropy generation phase. If you have opted for a configuration with larger disks (e.g. 8, 12, 16TB) each containing multiple partitions, you should be fine as most partitions will use less than 4TB providing a buffer.

When the node has finished generating entropy for a partition it will print a message like this

to the console:
`
The storage module storage_module_26_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9 is prepared for 2.9 replication.
`

and in your logs:
`event: storage_module_entropy_preparation_complete, store_id: 6_En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI.replica.2.9`

Entropy generation is complete when you see that message printed for **each** configured storage module. 

**[Example Entropy Generation Configuration](sample-configs/entropy-generation.md)**

## 1.2 Syncing & Packing

Syncing & Packing is often the most expensive and time consuming part of miner setup. We provide a sample configuration file below, but you may want to tweak the options to optimize your performance. For guidance on this refer to [Syncing & Packing](../overview/syncing-and-packing.md).

**[Example Syncing & Packing Configuration](sample-configs/sync-pack.md)**

## 1.3 Mining

Once you have your data packed, you can start mining it. See [How Mining Works](../overview/mining.md) for more information about the mining process.

There are 3 different mining node configurations (described in [Node Types](../overview/node-types.md)):
- Solo Mining
- Coordinated Mining
- Pool Mining

[Coordinated Mining](../overview/coordinated-mining.md) and [Pool Mining](../overview/pool-mining.md) involve some additional setup. For more information please refer to their dedicated guides.

**[Example Solo Mining Configuration](sample-configs/solo-mining.md)**

# 2. Repacking

When first starting out most miners will need to sync their data from peers and pack it. However if you already have some data locally that you want to repack to a new packing address or format (e.g. `unpacked` to `replica.2.9`), there are 2 other options (described below). For more information on the packing and repacking process see [Syncing & Packing](../overview/syncing-and-packing.md)


## 2.1 Cross-module Repack

You can use cross-module repacking if you have a set of data packed to one format or address, and want to **copy** the data while repacking it to a new format or address. In this case your node needs access to both the source and destination storage modules.

**Note:** it's a good idea to first generate entropy for the data you'll be repacking too. See [Entropy Generation](#11-entropy-generation) above.

**[Example Cross-module Repack Configuration](sample-configs/cross-module-repack.md)**

## 2.2 Repack-in-Place

You can use repack-in-place if you have a set of data packed to one format or address, and want to repack it to a new address or format without using any more storage space. In this case the node will replace the source data with the repacked data.

**[Example Repack-in-Place Configuration](sample-configs/repack-in-place.md)**

# 3. VDF Server

VDF Servers are typically run on MacOS hardware and are configured to run without mining and without any storage modules. See [VDF](../overview/vdf.md) for more information.

**[Example VDF Server Configuration](sample-configs/vdf.md)**