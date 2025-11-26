---
title: Arweave Directory Structure
---

# Arweave Directory Structure

## 1. Overview

There are 3 main directories to plan for:
- Arweave install directory
- `data_dir`
- Storage modules

## 2. Arweave Install Directory

Most of the information can be found in [Installing Arweave](install.md). Main caveats:
- When upgrading Arweave make sure to extract the new archive to a new location. If you extract a new archive ontop of an existing install Arweave may not launch correctly.
- There should be no overlap between the install directory and your `data_dir`. i.e. `data_dir` should not be within the install directory, nor vice versa.

## 3. `data_dir`

All Arweave [node types](../overview/node-types.md) require a `data_dir` configured at launch - this can be any location on your system. The `data_dir` will store all the indices, data files, and metadata that an Arweave node needs while running.

Most of these files will be created or recreated by Arweave automatically and so are safe to delete. With 2 important exceptions. You should be very careful before deleting:
- `[data_dir]/wallets`: this directory stores your mining key and unless you have it backed up (recommended) if you delete it you will not be able to sign new blocks or access your mining rewards. See [Mining Key](mining-key.md) for more information.
- `[data_dir]/storage_modules`: this directory is the root directory under which all of your packed chunk data is stored. This data drives your mining hashrate and preparing it is often the most expensive and time consuming part of miner setup. You can review the topics in the **Overview** section for information on syncing, packing, and mining. And see below for more information on the `storage_modules` directory.

{% hint style="danger" %}
Be **very** careful before deleting `[data_dir]/wallets` or `[data_dir]/storage_modules`
{% endhint %}

### 3.1 `data_dir` Recommendations:
- At least 200GB of of available space, 500GB is recommended - even more if you want to store the full [blockchain](../overview/blockchain.md).
- Stored on an SSD or NVMe. The data in `data_dir` is frequently read and written by all node services and can become a performance bottleneck if it resides on an HDD. See [Hardware Guide](hardware.md/#311-solid-state-drive-ssd-for-data_dir) for more information.

Note: You will need a lot more than 200GB when mining, but typically your mined data (stored in `storage_modules`) is mounted on separate disks from your `data_dir` and symlinked in. So your `data_dir` disk itself only needs to have 200GB+ available capacity. More about this below.

## 4. Storage Modules

The Arweave dataset is logically partitioned into collections of 3.6 TB "mining partitions". You will store some or all of those mining partitions on your miner in "storage modules". Storage modules can be any size (smaller or larger than the default 3.6TB mining partition size), but many miners opt to align their storage modules with the Arweave partitions.

To setup your storage modules, the first step is to create a folder inside `[data_dir]/storage_modules/` for each of the storage modules that you intend to mine with. Storage module folder names should use the following pattern: `storage_module[_storage_module_size]_[storage_module_index]_[packing]` where `packing` is either `replica.2.9`, or `unpacked`. The default storage module size is 3.6TB - in that case specifying `storage_module_size` is optional.

For any given `storage_module_size`, you should allow for an additional 10% metadata overhead (such as merkle proofs). This is why, for the default 3.6 TB `storage_module_size`, we recommend reserving 4 TB of space. The storage modules are indexed sequentially starting from 0, with 0 being the very first 3.6 TB (or `storage_module_size`) worth of data stored on Arweave, and ranging up to or beyond the current Arweave dataset size (`weave_size`). You can choose which mining partitions you store by indicating their `storage_module_index` in the folder name. 

For example, to set up a storage module with the very first mining partition in the weave with the default 3.6 TB `storage_module_size` (packed with your mining address), create the folder such as `[data_dir]/storage_modules/storage_module_0_[your_mining_address].replica.2.9`. If you were to store 2 TB storage modules, create the folder such as: `[data_dir]/storage_modules/storage_module_2000000000000_0_[your_mining_address].replica.2.9`.

After creating the relevant folders for your chosen partitions, mount your drives onto them. E.g.,
```
sudo mount /dev/sda [data_dir]/storage_modules/storage_module_0_[your_mining_address].replica.2.9
sudo mount /dev/sda [data_dir]/storage_modules/storage_module_2000000000000_0_[your_mining_address].replica.2.9
```

Make sure you replace `/dev/sda` with the name of your drive (`lsblk`), `[data_dir]` - with the absolute path to your data folder, and `[your_mining_address]` - with your mining address.

If you have a drive already mounted elsewhere, you may create a symbolic link instead:

```
ln -s [path/to/disk/mountpoint] [data_dir]/storage_modules/storage_module_0_[your_mining_address].replica.2.9
```

### 4.1 Storage Module Recommendations

- Having two or more storage modules that store the same mining partition (say, the partition at index 0 more than once) with the same mining address does not increase your mining performance. Also, it is more profitable mine a complete replica (all mining partitions) of the weave packed with a single address than mine off an equal amount of data packed with different mining addresses. Currently, we only support one mining address per node.
- If you want to copy the contents of a storage module elsewhere, restart the node without the corresponding `storage_module` command line parameter, copy the data, and restart the node with the `storage_module` parameter again. You can attach the copied data as a storage module to another node. Just make sure to not copy while the node is interacting with this storage module. Do NOT mine on several nodes with the same mining address simultaneously (see the warning below.)
- Make sure the disks with the storage modules have sufficient available space for both the data itself and metadata (10% of the size of the data). Note that `disk_space` command line parameter does NOT apply to the storage modules.
- If you created storage modules with custom `storage_module_size` as mentioned above, make sure to specify the `storage_module_size` in your command line invocation as follows:
  `storage_module [storage_module_index],[storage_module_size],[your_mining_address].replica.2.9`\
  The module will sync data with the weave offsets between `storage_module_index * storage_module_size` (in bytes) and `(storage_module_index + 1) * storage_module_size` at folder `[data_dir]/storage_modules/storage_module[_storage_module_size]_[storage_module_index]_[your_mining_address].replica.2.9`.
- The specified mining partition index does not have to be under the current weave size. This makes it possible to configure storage modules in advance. Once the weave data grows sufficiently large to start filling the mining partition at the specified index, the node will begin placing the new data in the already configured storage module.

{% hint style="danger" %}
It is very dangerous to have two or more nodes mine independently using the same mining address. If they find and publish blocks simultaneously, the network will slash your rewards and revoke the mining permission of the mining address! In order to have multiple nodes use the same mining address they must be configured to use coordinated mining. See the [Coordinated Mining Guide](../overview/coordinated-mining.md) for more information.
{% endhint %}