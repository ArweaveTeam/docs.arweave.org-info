---
title: Arweave Node Directory Structure
---

# Arweave Node Directory Structure

### Preparation: Data Directory

Create a directory somewhere in your system. We will refer to it as `[data_dir]` throughout this guide. We recommend having at least 200 GB available on the corresponding disk, although it is possible to configure the node for less space. For mining, you obviously need a lot more space, but the mining data should be stored on separate drives mounted in or symlinked to the folders inside `[data_dir].`More about it later in this guide.

### Preparation: Mining Key

In order to produce and sign a block your mining key needs to be present on your machine. If you want to create a new wallet, run `./bin/create-wallet.` The file is then created in `[data_dir]/wallets/.` Make sure you never share it with anyone! If you want to use an existing wallet, place it under the aforementioned path. Note: when using [coordinated mining](coordinated-mining.md), the wallet only needs to be present on the exit node.

### Preparation: Packing Format

Before you can configure your storage you'll have to decide on a packing format. The legacy packing format, `spora_2_6`, is still supported, but for new packs we recommend using the new `replica_2_9` format. The `replica_2_9` can be packed more quickly and with lower CPU requirements. Additonally while mining data packed to `replica_2_9` your optimal read rate is just 5 MiB/s per partition vs. 200 MiB/s for `spora_2_6`. This table summarizes the differences:

| Packing Format | Time to pack (benchmarked to spora_2_6) | Disk read rate per partition when mining against a full replica |
|----------------|-----------------------------------------|--------------------------------------------------------|
| `spora_2_6`    | 1x                                      | 200 MiB/s                                              |
| `replica_2_9`  | TBD (but more quickly)                  | 5 MiB/s                                                |

If we assume that a good quality enterprise hard disk drive can sustain 200 MiB/s read rate, then with `spora_2_6` you could only store a single 4TB partition per 4TB HDD. However with `replica_2_9` you could conceivably store and mine 40x 4TB partitions (or 160 TB) on a single  HDD - well beyond the capacity of today's HDDs. 

Note: The effective hashrate for a full replica packed to any of the supported packing formats is the same. A miner who has packed a full replica to `spora_2_6` or `replica_2_9` can expect to find the same number of blocks on average, but with the `replica_2_9` miner reading fewer chunks from their storage per second. This allows the miner to use larger hard drives in their setup, without increasing the necessary bandwidth between disk and CPU.

Also note: When mining, all storage modules within the same replica must be packed to the same packing format. For example, a single miner will not be able to build a solution involving chunks from `storage_module_1_addr` and `storage_module_2_addr.replica.2.9` even if the packing address is the same.

For guidance on how to pack your data see the example configurations in the [Examples](examples.md) guide.

The packing format you select will influence what hardware configuration provides the best return. For more information on mining hardware see the [Hardware Guide](setup/hardware.md).

### Preparation: Storage Setup

The Arweave dataset is logically partitioned into collections of 3.6 TB "mining partitions". You will store some or all of those mining partitions on your miner in "storage modules". Storage modules can be any size (smaller or larger than the default 3.6TB mining partition size), but many miners opt to align their storage modules with the Arweave partitions.

To setup your storage modules, the first step is to create a folder inside `[data_dir]/storage_modules/` for each of the storage modules that you intend to mine with. Storage module folder names should use the following pattern: `storage_module[_storage_module_size]_[storage_module_index]_[packing]` where `packing` is either `{mining address}.{packing difficulty}` (where `packing difficulty` is an integer), or `unpacked`. The default storage module size is 3.6TB - in that case specifying `storage_module_size` is optional.

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

If you have a RAID setup with a lot of space, you can create a symlink link from the `[data_dir]/storage_modules` folder.

A few important notes about the storage modules:

- Having two or more storage modules that store the same mining partition (say, the partition at index 0 more than once) with the same mining address does not increase your mining performance. Also, it is more profitable mine a complete replica (all mining partitions) of the weave packed with a single address than mine off an equal amount of data packed with different mining addresses. Currently, we only support one mining address per node.
- If you want to copy the contents of a storage module elsewhere, restart the node without the corresponding `storage_module` command line parameter, copy the data, and restart the node with the `storage_module` parameter again. You can attach the copied data as a storage module to another node. Just make sure to not copy while the node is interacting with this storage module. Do NOT mine on several nodes with the same mining address simultaneously (see the warning below.)
- Make sure the disks with the storage modules have sufficient available space for both the data itself and metadata (10% of the size of the data). Note that `disk_space` command line parameter does NOT apply to the storage modules.
- If you created storage modules with custom `storage_module_size` as mentioned above, make sure to specify the `storage_module_size` in your command line invocation as follows:
  `storage_module [storage_module_index],[storage_module_size],[your_mining_address].replica.2.9`\
  The module will sync data with the weave offsets between `storage_module_index * storage_module_size` (in bytes) and `(storage_module_index + 1) * storage_module_size` at folder `[data_dir]/storage_modules/storage_module[_storage_module_size]_[storage_module_index]_[your_mining_address].replica.2.9`.
- The specified mining partition index does not have to be under the current weave size. This makes it possible to configure storage modules in advance. Once the weave data grows sufficiently large to start filling the mining partition at the specified index, the node will begin placing the new data in the already configured storage module.

{% hint style="danger" %}
It is very dangerous to have two or more nodes mine independently using the same mining address. If they find and publish blocks simultaneously, the network will slash your rewards and revoke the mining permission of the mining address! In order to have multiple nodes use the same mining address they must be configured to use coordinated mining. See the [Coordinated Mining Guide](coordinated-mining.md) for more information.
{% endhint %}