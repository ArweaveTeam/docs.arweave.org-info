---
description: How to setup your node's directory structure
---

# Directory Structure

## 1. Overview

There are 3 main directories to plan for:

* Arweave install directory
* `data_dir`
* Storage modules

## 2. Arweave Install Directory

Most of the information can be found in [Installing Arweave](install.md). Main caveats:

* When upgrading Arweave make sure to extract the new archive to a new location. If you extract a new archive ontop of an existing install Arweave may not launch correctly.
* There should be no overlap between the install directory and your `data_dir`. i.e. `data_dir` should not be within the install directory, nor vice versa.

## 3. `data_dir`

All Arweave [node types](../overview/node-types.md) require a `data_dir` configured at launch - this can be any location on your system. The `data_dir` will store all the indices, data files, and metadata that an Arweave node needs while running.

Most of these files will be created or recreated by Arweave automatically and so are safe to delete. With 2 important exceptions. You should be very careful before deleting:

* `[data_dir]/wallets`: this directory stores your mining key and unless you have it backed up (recommended) if you delete it you will not be able to sign new blocks or access your mining rewards. See [Mining Key](https://github.com/ArweaveTeam/docs.arweave.org-info/blob/master/mining/setup/mining-key.md) for more information.
* `[data_dir]/storage_modules`: this directory is the root directory under which all of your packed chunk data is stored. This data drives your mining hashrate and preparing it is often the most expensive and time consuming part of miner setup. You can review the topics in the **Overview** section for information on syncing, packing, and mining. And see below for more information on the `storage_modules` directory.

{% hint style="danger" %}
Be **very** careful before deleting `[data_dir]/wallets` or `[data_dir]/storage_modules`
{% endhint %}

### 3.1 `data_dir` Recommendations:

* At least 200GB of of available space, 500GB is recommended - even more if you want to store the full blockchain.
* Stored on an SSD or NVMe. The data in `data_dir` is frequently read and written by all node services and can become a performance bottleneck if it resides on an HDD. See [Hardware Guide](hardware.md#311-solid-state-drive-ssd-for-data_dir) for more information.

Note: You will need a lot more than 200GB when mining, but typically your mined data (stored in `storage_modules`) is mounted on separate disks from your `data_dir` and symlinked in. So your `data_dir` disk itself only needs to have 200GB+ available capacity. More about this below.

## 4. Storage Modules

The Arweave dataset is logically partitioned into collections of 3.6 TB "mining partitions". You will store some or all of those mining partitions on your miner in "storage modules". A storage module covers an arbitrary byte range of the weave - it can be any size, and does not need to line up with the 3.6 TB partitions - but many miners opt to align their storage modules with the Arweave partitions.

To setup your storage modules, the first step is to create a folder inside `[data_dir]/storage_modules/` for each of the storage modules that you intend to mine with. The folder name depends on how the module's range is configured, where `packing` is either `replica.2.9` or `unpacked`:

* **One whole mining partition** (`partition` in your config): `storage_module_[partition_number]_[packing]`
* **Any other range**: `storage_module_[range_start]_[range_end]_[packing]` with both offsets in bytes.

{% hint style="info" %}
Storage modules covering arbitrary byte ranges (`range_start` / `range_end`) are new in Arweave 2.9.6. Earlier versions declare storage modules using a bucket size and index notation. If you are running an earlier version, run `./bin/start help` for info on the bucket size and index format.
{% endhint %}

Nodes running a [legacy configuration](legacy-configuration.md) keep using the legacy directory names: custom bucket sizes map to `storage_module_[bucket_size]_[bucket_index]_[packing]`, exactly as before. When you migrate a custom-bucket-size config to the current format, rename those directories to the range form above (`bucket_index * bucket_size` → `range_start`, `(bucket_index + 1) * bucket_size` → `range_end`); whole-partition directories keep their names and need no change.

For any storage module, you should allow for an additional 10% metadata overhead (such as merkle proofs). This is why, for the default 3.6 TB partition-sized module, we recommend reserving 4 TB of space. Mining partitions are indexed sequentially starting from 0, with 0 being the very first 3.6 TB of data stored on Arweave, and ranging up to or beyond the current Arweave dataset size (`weave_size`).

For example, to set up a storage module with the very first mining partition in the weave (packed with your mining address), create the folder `[data_dir]/storage_modules/storage_module_0_[your_mining_address].replica.2.9`. For a module covering the range 3 TB to 5 TB, create `[data_dir]/storage_modules/storage_module_3000000000000_5000000000000_[your_mining_address].replica.2.9`.

After creating the relevant folders for your chosen partitions, mount your drives onto them. E.g.,

```
sudo mount /dev/sda [data_dir]/storage_modules/storage_module_0_[your_mining_address].replica.2.9
sudo mount /dev/sdb [data_dir]/storage_modules/storage_module_3000000000000_5000000000000_[your_mining_address].replica.2.9
```

Make sure you replace `/dev/sda` with the name of your drive (`lsblk`), `[data_dir]` - with the absolute path to your data folder, and `[your_mining_address]` - with your mining address.

If you have a drive already mounted elsewhere, you may create a symbolic link instead:

```
ln -s [path/to/disk/mountpoint] [data_dir]/storage_modules/storage_module_0_[your_mining_address].replica.2.9
```

### 4.1 Storage Module Recommendations

* Having two or more storage modules that store the same mining partition (say, the partition at index 0 more than once) with the same mining address does not increase your mining performance. Also, it is more profitable mine a complete replica (all mining partitions) of the weave packed with a single address than mine off an equal amount of data packed with different mining addresses. Currently, we only support one mining address per node.
* If you want to copy the contents of a storage module elsewhere, restart the node without the corresponding `storage_modules` entry in your configuration, copy the data, and restart the node with the entry again. You can attach the copied data as a storage module to another node. Just make sure to not copy while the node is interacting with this storage module. Do NOT mine on several nodes with the same mining address simultaneously (see the warning below.)
* Make sure the disks with the storage modules have sufficient available space for both the data itself and metadata (10% of the size of the data). Note that `disk_space` command line parameter does NOT apply to the storage modules.
* For any storage module that doesn't cover exactly one whole mining partition, configure the module with an explicit byte range: set `range_start` and `range_end` in its `storage_modules` entry instead of `partition`. Any range with `range_end > range_start` is valid - this is useful when your drives are different sizes and no single module size tiles the weave without gaps or overlap. The module will sync the weave data between those byte offsets, in the folder named as described above.
* The specified mining partition index does not have to be under the current weave size. This makes it possible to configure storage modules in advance. Once the weave data grows sufficiently large to start filling the mining partition at the specified index, the node will begin placing the new data in the already configured storage module.

{% hint style="danger" %}
It is very dangerous to have two or more nodes mine independently using the same mining address. If they find and publish blocks simultaneously, the network will slash your rewards and revoke the mining permission of the mining address! In order to have multiple nodes use the same mining address they must be configured to use coordinated mining. See the [Coordinated Mining Guide](../overview/coordinated-mining.md) for more information.
{% endhint %}

## 5. Additional Directories and Files

### 5.1 Logs

You can find your node's log files in the `[Install Dir]/logs` directory. You will always have `info` logs, and if you've run your node with the `debug` option you'll also have `debug` logs. The file name format is:

Info logs:

```
arweave-arweave@127.0.0.1-info.log
arweave-arweave@127.0.0.1-info.log.0
arweave-arweave@127.0.0.1-info.log.1
...
arweave-arweave@127.0.0.1-info.log.9
```

Debug logs

```
arweave-arweave@127.0.0.1-debug.log
arweave-arweave@127.0.0.1-debug.log.0
arweave-arweave@127.0.0.1-debug.log.1
...
arweave-arweave@127.0.0.1-debug.log.19
```

Higher numbers are older, and the log files rotate.
