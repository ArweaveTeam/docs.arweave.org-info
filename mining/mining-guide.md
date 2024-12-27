---
description: >-
  Want to start mining on Arweave? You've come to the right place! Get set up
  with this quick and easy guide, and join our awesome network of ever-growing
  miners.
---

# Mining Guide

{% hint style="info" %}
**For any questions and support queries regarding mining on Arweave, we strongly recommend that you join our** [**Discord server**](https://discord.gg/GHB4fxVv8B) **as this is the hub of our mining and developer communities. Here you will find plenty of community members and Arweave team members available to help you out** 🤖
{% endhint %}

{% hint style="warning" %}
Miners are responsible for their own compliance with data protection laws (such as GDPR) and other applicable laws in their jurisdiction. Data storage laws vary country to country. Failure to adhere to these laws may entail substantial legal risks for the miner. Please only participate in mining Arweave data if you have understood the legal implications of doing so and consider seeking legal advice.&#x20;
{% endhint %}

## Install the Miner

Download the `.tar.gz` archive for your OS from the [releases page](https://github.com/ArweaveTeam/arweave/releases). Extract the contents of the archive - `tar -xzf [release_file]`.

If your OS/platform architecture is not in the list, check the source code repository [README](https://github.com/ArweaveTeam/arweave#building-from-source) for how to build the miner from source.

## Preparation

### Preparation: File Descriptors Limit

The number of available file descriptors affects the rate at which your node can process data. Most operating systems default to assigning a low limit for user processes, we recommend increasing it.

{% hint style="info" %} 
These File Descriptors Limit instructions apply to Linux. When running a VDF Server on MacOS, please refer to the VDF guide.
{% endhint %}

You can check the current limit by executing `ulimit -n`.

On Linux, to set a bigger global limit, open `/etc/sysctl.conf` and add the following line:

```
fs.file-max=10000000
```

Execute `sysctl -p` to make the changes take effect.

You may also need to set a proper limit for the particular user. To set a user-level limit, open `/etc/security/limits.conf` and add the following line:

```
<your OS user>         soft    nofile  1000000
```

Open a new terminal session. To make sure the changes took effect, and the limit was increased, type `ulimit -n`. You can also change the limit for the current session via `ulimit -n 10000000`

If the above does not work, set

```
DefaultLimitNOFILE=1000000
```

in both `/etc/systemd/user.conf`and `/etc/systemd/system.conf`

### Preparation: Configuring Large Memory Pages

Mining involves computing 1 RandomX hash and several SHA2 hashes every second for every 3.6 TB mining partition. It is not a lot, but your CPU may nevertheless become a bottleneck when you configure a lot of mining partitions. To maximize your hashing performance, consider configuring huge memory pages in your OS.

On Ubuntu, to see the current values, execute:`cat /proc/meminfo | grep HugePages`. To set a value, run `sudo sysctl -w vm.nr_hugepages=3500`. To make the configuration survive reboots, create `/etc/sysctl.d/local.conf` and put `vm.nr_hugepages=3500` there.

The output of `cat /proc/meminfo | grep HugePages` should then look like this:\
`AnonHugePages: 0 kB`\
`ShmemHugePages: 0 kB HugePages_Total: 3500 HugePages_Free: 3500 HugePages_Rsvd: 0 HugePages_Surp: 0`

If it does not or if there is a "erl_drv_rwlock_destroy" error on startup, reboot the machine.

Finally, tell the miner it can use large pages by specifying `enable randomx_large_pages`on startup (you can find a complete startup example further in the guide).

### Preparation: Data Directory

Create a directory somewhere in your system. We will refer to it as `[data_dir]` throughout this guide. We recommend having at least 200 GB available on the corresponding disk, although it is possible to configure the node for less space. For mining, you obviously need a lot more space, but the mining data should be stored on separate drives mounted in or symlinked to the folders inside `[data_dir].`More about it later in this guide.

### Preparation: Mining Key

In order to produce and sign a block your mining key needs to be present on your machine. If you want to create a new wallet, run `./bin/create-wallet.` The file is then created in `[data_dir]/wallets/.` Make sure you never share it with anyone! If you want to use an existing wallet, place it under the aforementioned path. Note: when using [coordinated mining](coordinated-mining.md), the wallet only needs to be present on the exit node.

### Preparation: Packing Format

Before you can configure your storage you'll have to decide on a packing format. The legacy packing format, `spora_2_6`, is still supported, but for new packs we recommend using the new `composite` format. The `composite` format includes a packing difficulty option that allows miners to spend more time while packing data in returns for lower disk read rates while mining. When you see `composite.1` that's short-hand for "composite packing format with a packing difficulty of 1". This table summarizes the differences:

| Packing Format | Time to pack (benchmarked to spora_2_6) | Disk read rate per partition when mining against a full replica |
|----------------|-----------------------------------------|--------------------------------------------------------|
| `spora_2_6`    | 1x                                      | 200 MiB/s                                              |
| `composite.1`  | 1x                                      | 50 MiB/s                                               |
| `composite.2`  | 2x                                      | 25 MiB/s                                               |
| `composite.3`  | 3x                                      | 16.6667 MiB/s                                          |
| `composite.4`  | 4x                                      | 12.5 MiB/s                                             |
| ...            | ...                                     | ...                                                    |
| `composite.32` | 32x                                     | 1.5625 MiB/s                                           |

If we assume that a good quality enterprised hard disk drive can sustain 200 MiB/s read rate, then with `spora_2_6` you could only store a single 4TB partition per 4TB HDD. However with `composite.1` you could conceivably store and mine 4x 4TB partitions on a single 16TB HDD. Or, if you find that your configuration can't sustain a 200 MiB/s read rate for each drive, you could pack to a higher difficulty level to lower the required read rate.

Note: The effective hashrate for a full replica packed to any of the supported packing formats is the same. A miner who has packed a full replica to `spora_2_6` or `composite.1` or `composite.32` can expect to find the same number of blocks on average, but with the higher difficulty miner reading fewer chunks from their storage per second. This allows the miner to use larger hard drives in their setup, without increasing the necessary bandwidth between disk and CPU.

Also note: When mining, all storage modules within the same replica must be packed to the same packing format and difficulty level. For example, a single miner will not be able to build a solution involving chunks from `storage_module_1_addr.1` and `storage_module_2_addr.2` even if the packing address is the same.

The packing format you select will influence what hardware configuration provides the best return. For more information on mining hardware see the [Mining Hardware Guide](hardware.md).

### Preparation: Storage Setup

The Arweave dataset is logically partitioned into collections of 3.6 TB "mining partitions". You will store some or all of those mining partitions on your miner in "storage modules". Storage modules can be any size (smaller or larger than the default 3.6TB mining partition size), but many miners opt to align their storage modules with the Arweave partitions.

To setup your storage modules, the first step is to create a folder inside `[data_dir]/storage_modules/` for each of the storage modules that you intend to mine with. Storage module folder names should use the following pattern: `storage_module[_storage_module_size]_[storage_module_index]_[packing]` where `packing` is either `{mining address}.{packing difficulty}` (where `packing difficulty` is an integer), or `unpacked`. The default storage module size is 3.6TB - in that case specifying `storage_module_size` is optional.

For any given `storage_module_size`, you should allow for an additional 10% metadata overhead (such as merkle proofs). This is why, for the default 3.6 TB `storage_module_size`, we recommend reserving 4 TB of space. The storage modules are indexed sequentially starting from 0, with 0 being the very first 3.6 TB (or `storage_module_size`) worth of data stored on Arweave, and ranging up to or beyond the current Arweave dataset size (`weave_size`). You can choose which mining partitions you store by indicating their `storage_module_index` in the folder name. 

For example, to set up a storage module with the very first mining partition in the weave with the default 3.6 TB `storage_module_size` (packed with your mining address), create the folder such as `[data_dir]/storage_modules/storage_module_0_[your_mining_address].1`. If you were to store 2 TB storage modules, create the folder such as: `[data_dir]/storage_modules/storage_module_2000000000000_0_[your_mining_address].1`.

After creating the relevant folders for your chosen partitions, mount your drives onto them. E.g.,
```
sudo mount /dev/sda [data_dir]/storage_modules/storage_module_0_[your_mining_address].1
sudo mount /dev/sda [data_dir]/storage_modules/storage_module_2000000000000_0_[your_mining_address].1
```

Make sure you replace `/dev/sda` with the name of your drive (`lsblk`), `[data_dir]` - with the absolute path to your data folder, and `[your_mining_address]` - with your mining address.

If you have a drive already mounted elsewhere, you may create a symbolic link instead:

```
ln -s [path/to/disk/mountpoint] [data_dir]/storage_modules/storage_module_0_[your_mining_address].1
```

If you have a RAID setup with a lot of space, you can create a symlink link from the `[data_dir]/storage_modules` folder.

A few important notes about the storage modules:

- Having two or more storage modules that store the same mining partition (say, the partition at index 0 more than once) with the same mining address does not increase your mining performance. Also, it is more profitable mine a complete replica (all mining partitions) of the weave packed with a single address than mine off an equal amount of data packed with different mining addresses. Currently, we only support one mining address per node.
- If you want to copy the contents of a storage module elsewhere, restart the node without the corresponding `storage_module` command line parameter, copy the data, and restart the node with the `storage_module` parameter again. You can attach the copied data as a storage module to another node. Just make sure to not copy while the node is interacting with this storage module. Do NOT mine on several nodes with the same mining address simultaneously (see the warning below.)
- Make sure the disks with the storage modules have sufficient available space for both the data itself and metadata (10% of the size of the data). Note that `disk_space` command line parameter does NOT apply to the storage modules.
- If you created storage modules with custom `storage_module_size` as mentioned above, make sure to specify the `storage_module_size` in your command line invocation as follows:
  `storage_module [storage_module_index],[storage_module_size],[your_mining_address].1`\
  The module will sync data with the weave offsets between `storage_module_index * storage_module_size` (in bytes) and `(storage_module_index + 1) * storage_module_size` at folder `[data_dir]/storage_modules/storage_module[_storage_module_size]_[storage_module_index]_[your_mining_address].1`.
- The specified mining partition index does not have to be under the current weave size. This makes it possible to configure storage modules in advance. Once the weave data grows sufficiently large to start filling the mining partition at the specified index, the node will begin placing the new data in the already configured storage module.

{% hint style="danger" %}
It is very dangerous to have two or more nodes mine independently using the same mining address. If they find and publish blocks simultaneously, the network will slash your rewards and revoke the mining permission of the mining address! In order to have multiple nodes use the same mining address they must be configured to use coordinated mining. See the [Coordinated Mining Guide](coordinated-mining.md) for more information.
{% endhint %}

#### Copying Data Across Storage Modules

When a node starts, it copies (and packs, if required) the data from one storage module to another, in the case when there are two or more intersecting storage modules. For example, if you specify `storage_module 11,unpacked storage_module 11,[mining_address].1` and there is some data in the "unpacked" module that is absent from the "mining address" module, the data will be packed with this mining address and stored in `11,[mining_address].1`.

If you want to repack a storage module, do not rename the existing one - renaming will not cause repacking, create a new storage module instead.

#### Unpacked Storage Modules

If you want to sync many replicas of the weave, it makes sense to first create an "unpacked" replica. Then, packing for each mining address will be two times faster compared to repacking a replica packed with another mining address. To configure a storage module for storing unpacked data, specify "unpacked" instead of the mining address.

For example, to sync an unpacked partition 12, specify `storage_module 12,unpacked` on startup. As with the other storage modules, make sure the `[data_dir]/storage_modules/storage_module_12_unpacked` folder resides on the desired disk (if you do not create the directory in advance, the node will create it for you so the data will end up on the disk `[data_dir]/storage_modules`is mounted to.) After the replica is synced, you can copy it to the other machines where its contents would be copied and packed for the storage modules you configure there.

### Preparation: RAM

- **Minimum**: 8 GB + 1 GB per mining partition
- **Recommended**: 8 GB + 2 GB per mining partition

The node determines the amount of chunks to read in memory while mining automatically. If your node runs out of memory anyway, try setting the `mining_server_chunk_cache_size_limit` option in the command line (specify the number of 256 KiB to cache).

### Preparation: CPU

We can broadly outline three tasks computing units solve in Arweave:

1. Packing and unpacking data
2. Executing the VDF
3. Calculating storage proofs

{% hint style="info" %}
For more information on what hardware to use for your miner, please see the [Mining Hardware Guide](hardware.md).
{% endhint %}


#### 1. Packing

Packing mostly consists of executing RandomX instructions so the [faster your CPU computes RandomX hashes](https://xmrig.com/benchmark), the faster you can pack. Note that packing a single 256 KiB chunk using the `spora_2_6` or `composite.1` format takes about 30 times longer than computing one RandomX hash. Once you have packed a dataset, you do not necessarily have to keep the powerful process around. You can control the maximum allowed packing rate with the `packing_rate` start command parameter. 

#### 2. VDF

The VDF controls the speed of mining with new mining "seeds" available at 1 second intervals. To keep up with the network your CPU must be able to maintain this 1 second cadence while calculating the VDF. For that the CPU needs to support [hardware SHA2 acceleration](https://en.wikipedia.org/wiki/Intel_SHA_extensions). Additional cores will not improve VDF performance as VDF hash calculations are sequential and therefore limited to a single thread on a single core.

For more information on VDF, including connecting to a VDF server or running your own VDF server, see [Mining VDF](vdf.md).

## Running the Miner

Now you’re ready to start the mining process by running the following command from the Arweave directory. An example with one storage module (covering partition 0):

```
./bin/start data_dir YOUR-DATA-DIR mining_addr YOUR-MINING-ADDRESS enable randomx_large_pages peer ams-1.eu-central-1.arweave.xyz peer fra-1.eu-central-2.arweave.xyz peer sgp-1.ap-central-2.arweave.xyz peer blr-1.ap-central-1.arweave.xyz peer sfo-1.na-west-1.arweave.xyz peer vin-1.east.us.north-america.arweave.xyz peer sin-1.sg.asia.arweave.xyz peer hil-1.west.us.north-america.arweave.xyz peer lim-1.de.europe.arweave.xyz peer fsn-1.de.europe.arweave.xyz debug mine storage_module 0,YOUR-MINING-ADDRESS.1
```

### Trusted peers

When your node first connects to the network it does so through a set of "trusted peers". These are nodes that you specify using the `peer` flag. Your node queries its trusted peers for the recent blockchain data. It's important to only specify nodes you trust, but since your node will validate the data it receives from these peers the potential for abuse is minimal.

If you operate multiple nodes yourself you can have your own nodes specify each other as trusted peers. Although it's important to also include some external nodes as well in case all of your nodes go offline at once.

The Digital History Association operates a set of nodes that can be used as trusted peers:
- `ams-1.eu-central-1.arweave.xyz`
- `blr-1.ap-central-1.arweave.xyz`
- `fra-1.eu-central-2.arweave.xyz`
- `sfo-1.na-west-1.arweave.xyz`
- `sgp-1.ap-central-2.arweave.xyz`
- `vin-1.east.us.north-america.arweave.xyz`
- `sin-1.sg.asia.arweave.xyz`
- `hil-1.west.us.north-america.arweave.xyz`
- `lim-1.de.europe.arweave.xyz`
- `fsn-1.de.europe.arweave.xyz`

{% hint style="warning" %}
Replace **YOUR-MINING-ADDRESS** with the address of the wallet you would like to credit when you find a block!
{% endhint %}

{% hint style="warning" %}
**Tip:** Avoid killing the arweave process if at all possible. I.e. **don't** do `kill -9 arweave` or `kill -9 beam` or `kill -9 erl`. To stop the arweave process, use `./bin/stop` and then wait for as long as you can for the node to shutdown gracefully. Sometimes if can take a while for the node to shutdown, which we realize is frustrating, but if you kill the node abruptly it can cause `rocksdb` corruption that can be difficult to recover from. In the worst case you may need to resync and repack a partition.
{% endhint %}

An example with several storage modules (covering partitions 21, 22, 23):

```
./bin/start data_dir YOUR-DATA-DIR mining_addr YOUR-MINING-ADDRESS enable randomx_large_pages peer ams-1.eu-central-1.arweave.xyz peer fra-1.eu-central-2.arweave.xyz peer sgp-1.ap-central-2.arweave.xyz peer blr-1.ap-central-1.arweave.xyz peer sfo-1.na-west-1.arweave.xyz peer vin-1.east.us.north-america.arweave.xyz peer sin-1.sg.asia.arweave.xyz peer hil-1.west.us.north-america.arweave.xyz peer lim-1.de.europe.arweave.xyz peer fsn-1.de.europe.arweave.xyz debug mine storage_module 21,YOUR-MINING-ADDRESS.1 storage_module 22,YOUR-MINING-ADDRESS.1 storage_module 23,YOUR-MINING-ADDRESS.1
```

For more examples see: [Mining Examples](examples.md)

{% hint style="info" %}
In order to protect your machine from material that may be illegal in your country, you should use a content policy when mining Arweave. Content policies can be generated using the [Shepherd tool](https://github.com/shepherd-media-classifier/shepherd). Shepherd allows you to create your own content policies for the content that you would like to store on your Arweave node, abiding by your moral and legal requirements.

In order to help you get started quickly, @ArweaveTeam provides an NSFW content filter which you can load by adding the following to your Arweave start command:

`transaction_blacklist_url http://shepherd-v.com/nsfw.txt`
{% endhint %}

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

#### Stopping the Miner

To stop the node, run `./bin/stop` or kill the OS process (`kill -sigterm <pid>` or `pkill <name>`). Sending a SIGKILL (`kill -9`) is **not** recommended.

#### Defragmenting Storage

Due to Arweave node specifics (storing data in the sparse files), the read throughput during mining after the initial sync might be suboptimal on some disks. In the performance reports printed in the console you can see the estimated optimal performance in MiB/s, per configured storage module. The first number estimates the optimum on a small dataset, the second - on the dataset close in size to the weave size. If the actual performance of a storage module is noticeably lower, consider running a defragmentation procedure to improve your mining performance on this module. (Re)start the miner with the following parameters (in this example, the storage module storing the partition 8 will be defragmented):

```
./bin/start run_defragmentation defragment_module 8,YOUR-MINING-ADDRESS.1 defragmentation_trigger_threshold 500000000 ...
```

The defragmentation is performed before startup. Only chunk files larger than `defragmentation_trigger_threshold` bytes and those which have grown by more than 10% since the last defragmentation of this module will be updated. Note the defragmentation may take a lot of time.

## Troubleshooting

### Make sure your node is accessible on the Internet

An important part of the mining process is discovering blocks mined by other miners. Your node needs to be accessible from anywhere on the Internet so that your peers can connect with you and share their blocks.

To check if your node is publicly accessible, browse to `http://[Your Internet IP]:1984`. You can [obtain your public IP here](https://ifconfig.me/), or by running `curl ifconfig.me/ip`. If you specified a different port when starting the miner, replace "1984" anywhere in these instructions with your port. If you can not access the node, you need to set up TCP port forwarding for incoming HTTP requests to your Internet IP address on port 1984 to the selected port on your mining machine. For more details on how to set up port forwarding, consult your ISP or cloud provider.

If the node is not accessible on the Internet, the miner functions but is significantly less efficient.

## Staying up to Date

- Join our [Discord](https://discord.gg/GHB4fxVv8B) server

Once you are successfully mining on the Arweave, you will need to stay up to date with new releases. Check the #announcements channel on the Arweave Miners discord server to learn about new releases. We will announce any steps you need to take to stay up to speed - particularly updates that require you to perform an action within a certain time period in order to stay in sync with the network.