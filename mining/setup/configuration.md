---
description: >-
  A guide to configuring and running your node for different purposes
---

# 0. Overview

Arweave provides a number of configuration options to control, customize, and tune its operation. This guide will describe the main operating phases for different [node types](../overview/node-types.md) and provide example configurations you can adapt as needed.

# 0.1 Run-script

We recommend using the `./bin/start` wrapper script to run your node. This script wraps the core [Arweave entrypoint](../operations/entrypoint.md) with naive auto-restart functionality. If your node crashes, `./bin/start` will wait 15 seconds and then restart it with the same configuration.

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