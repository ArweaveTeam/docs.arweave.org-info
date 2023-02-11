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
Arweave core developers have been made aware that at least one mining node inside the Chinese mainland has been seized by the government. Node operators should understand that the Arweave network stores and serves a significant amount of material related to the activities of the Chinese government. The Arweave protocol does not require that any miner to store data that they deem inappropriate. You can read more about our content policies [here](https://www.arweave.org/technology#content-moderation).
{% endhint %}

## Install the Miner

Download the `.tar.gz` archive for your OS from the [releases page](https://github.com/ArweaveTeam/arweave/releases). Extract the contents of the archive - `tar -xzf [release_file]`.

If your OS/platform architecture is not in the list, check the source code repository [README](https://github.com/ArweaveTeam/arweave#building-from-source) for how to build the miner from source.

## Preparation: File Descriptors Limit <a href="#preparation-file-descriptors-limit" id="preparation-file-descriptors-limit"></a>

The number of available file descriptors affects the rate at which your node can process data. As the default limit assigned to user processes on most operating systems is usually low, we recommend increasing it.

You can check the current limit by executing `ulimit -n`.

On Linux, to set a bigger global limit, open `/etc/sysctl.conf` and add the following line:

```
fs.file-max=100000000
```

Execute `sysctl -p` to make the changes take effect.

You may also need to set a proper limit for the particular user. To set a user-level limit, open `/etc/security/limits.conf` and add the following line:

```
<your OS user>         soft    nofile  10000000
```

Open a new terminal session. To make sure the changes took effect, and the limit was increased, type `ulimit -n`. You can also change the limit for the current session via `ulimit -n 10000000`

If the above does not work, set

```
DefaultLimitNOFILE=10000000
```

in both `/etc/systemd/user.conf`and `/etc/systemd/system.conf`

## Preparation: Data Directory

Create a directory somewhere in your system. We will refer to it as `[data_dir]` throughout this guide. We recommend having at least 200 GB available on the corresponding disk, although it is possible to configure the node for less space. For mining, you obviously need a lot more space, but the mining data should be stored on separate drives mounted in or symlinked to the folders inside `[data_dir].`More about it later in this guide.

## Preparation: Mining Key

In order to mine in 2.6, your mining key needs to be present on your machine. If you want to create a new wallet, run `./bin/create-wallet.` The file is then created in `[data_dir]/wallets/.` Make sure you never share it with anyone! If you want to use an existing wallet, place it under the aforementioned path.

## Preparation: Storage Setup

To maximize your mining efficiency, store data on 4 TB hard drives capable of reading about 200 MiB/s. It is fine to use faster disks, but the extra cost won't be justified.

The first step is to create a folder inside `[data_dir]/storage_modules/` for each of the 4 TB disks you intend to mine with. The Arweave dataset is logically partitioned into a collection of 3.6 TB  "mining partitions". Each 4 TB disk will store and mine one of these mining partitions. The partitions are indexed sequentially starting from 0, with 0 being the very first 3.6 TB worth of data stored on Arweave, and ranging to whatever the current mining partition count is. You can choose which mining partitions you store by indicating their index in the folder name. For example, to set up a storage module with the very first mining partition in the weave (packed with your mining address), create the folder \[data\_dir]/storage\_modules/storage\_module\_0\_\[your\_mining\_address].

Mount your drives in the `[data_dir]/storage_modules` folder. E.g.,

```
sudo mount /dev/sda [data_dir]/storage_modules/storage_module_0_[your_mining_address]
```

Make sure you replace `/dev/sda` with the name of your drive (`lsblk`), `[data_dir]`  - with the absolute path to your data folder, and `[your_mining_address]` - with your mining address.\
\
If you have a drive already mounted elsewhere, you may create a symbolic link instead:

```
ln -s [path/to/disk/folder] [data_dir]/storage_modules/storage_module_0_[your_mining_address]
```

If you have a RAID setup with a lot of space, you can create a symlink link from the `[data_dir]/storage_modules` folder.

A few important notes about the storage modules:

* Having two or more identical partitions (say, the partition 0 repeated) with the same mining address does not increase your mining performance. Also, it is more profitable mine a complete replica (all mining partitions) of the weave packed with a single address than mine off an equal amount of data packed with different mining addresses. Currently, we only support one mining address per node.
* If you want to copy the contents of a storage module elsewhere, restart the node without the corresponding `storage_module` command line parameter,  copy the data, and restart the node with the storage module again. You can attach the copied data as a storage module to another node. Just make sure to not copy while the node is interacting with this storage module.
* The specified mining partition index does not have to be under the current weave size. This makes it possible to configure storage modules in advance. Once the weave data grows sufficiently large to start filling the mining partition at the specified index, the node will begin placing the new data in the already configured storage module.
* If you do not mine off the full weave, the required disk read throughput is, on average, (100 + your weave share \* 100) MiB/s.\


### Upgrading Existing 2.5 Node

Ignore this paragraph if you are running the miner for the first time.\
\
When starting the upgraded node, set `enable legacy_storage_repacking` to start a process that would repack your packed 2.5 data. If you have storage modules configured, every repacked chunk is also written in the corresponding storage module. When the 2.6 fork activates, the node will use repacked data in mining (even if there are no storage modules). Note that your 2.5 mining performance before the fork will drop as more data is being repacked. Also, note that the node will NOT sync new data into the 2.5 storage - if you want to sync more data, configure storage modules.

### Reusing Storage Modules from Testnet 2.6&#x20;

If you have been running some nodes in the 2.6 test network, you can reuse the storage modules synced there with data up to the weave offset `122635245363446` (the block [1072170](https://arweave.net/block/height/1072170)) in the mainnet. You can try to start the miner with all the storage modules you have - if any of them contain data which does not belong to the mainnet, the node will stop and offer you to restart with `enable remove_orphaned_storage_module_data`. If this flag is set, the node will erase the extra data from the corresponding storage modules before launching.

## Preparation: RAM

We recommend you have 8 GB + 400 MB per mining partition (4 TB drive) worth of RAM. The node determines the amount of chunks to read in memory while mining automatically. If your node runs out of memory anyway, try setting the `mining_server_chunk_cache_size_limit` option in the command line (specify the number of 256 KiB to cache).

## Preparation: CPU

We can broadly outline three tasks computing units solve in Arweave:

1. Packing and unpacking data
2. Executing the VDF
3. Calculating storage proofs

### 1. Packing

Packing mostly consists of executing RandomX instructions so the [faster your CPU computes RandomX hashes](https://xmrig.com/benchmark), the faster you can pack. Note that packing a single 256 KiB chunk takes about 30 times longer than computing one RandomX hash. Once you have packed a dataset, you do not necessarily have to keep the powerful process around. You can control the maximum allowed packing rate with the `packing_rate` start command parameter. The default is 50 256 KiB chunks per second.

### 2. VDF

In order to maintain the proper mining performance and keep up with the network, you need to compute VDF steps timely (every step should take about one second). For that the CPU needs to support [hardware SHA2 acceleration](https://en.wikipedia.org/wiki/Intel\_SHA\_extensions). It should be noted that the VDF is executed by a single core.\
The node will report the VDF performance on startup, warning you if it is too low. Some viable options are AMD Ryzen 9 or Intel 12th or 13th generation processors with the clock frequency close to 5 Ghz, ideally connected to DDR5 RAM.

\
You may have another machine compute VDF for you (e.g., you may set up a dedicated VDF node broadcasting VDF outputs to all your mining nodes.)\
\
Running a node fetching VDF states from a peer:

```
./bin/start vdf_server_trusted_peer IP-ADDRESS ...
```

Running a node pushing its VDF outputs to other peers:

```
./bin/start vdf_client_peer IP-ADDRESS-1 vdf_client_peer IP-ADDRESS-2 ...
```

Make sure to specify \[IP-ADDRESS]:\[PORT] if your node is configured to listen on a TCP port other than 1984.

{% hint style="warning" %}
Do not connect to an external peer you do not trust.&#x20;
{% endhint %}

{% hint style="info" %}
Please, reach out to us via team@arweave.org if you would like to use our team's VDF servers.
{% endhint %}

### Configuring Large Memory Pages

Mining involves computing 1 RandomX hash and several SHA2 hashes every second for every 3.6 TB mining partition. It is not a lot, but your CPU may nevertheless become a bottleneck when you configure a lot of mining partitions. To maximize your hashing performance, consider configuring huge memory pages in your OS.

On Ubuntu, to see the current values, execute:`cat /proc/meminfo | grep HugePages`. To set a value, run `sudo sysctl -w vm.nr_hugepages=1000`. To make the configuration survive reboots, create `/etc/sysctl.d/local.conf` and put `vm.nr_hugepages=1000` there.

The output of `cat /proc/meminfo | grep HugePages` should then look like this:\
`AnonHugePages: 0 kB`\
`ShmemHugePages: 0 kB HugePages_Total: 1000 HugePages_Free: 1000 HugePages_Rsvd: 0 HugePages_Surp: 0`

If it does not or if there is a "erl\_drv\_rwlock\_destroy" error on startup, reboot the machine.

Finally, tell the miner it can use large pages by specifying `enable randomx_large_pages`on startup (you can find a complete startup example further in the guide).

## Running the Miner

Now you’re ready to start the mining process by running the following command from the Arweave directory:

```
./bin/start data_dir YOUR-DATA-DIR mining_addr YOUR-MINING-ADDRESS enable legacy_storage_repacking enable randomx_large_pages peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 139.59.51.59 peer 138.197.232.192 debug mine storage_module 0,YOUR-MINING-ADDRESS storage_module 8,YOUR-MINING-ADDRESS storage_module 9,YOUR-MINING-ADDRESS storage_module 10,YOUR-MINING-ADDRESS storage_module 11,YOUR-MINING-ADDRESS
```

{% hint style="warning" %}
Please replace **YOUR-MINING-ADDRESS** with the address of the wallet you would like to credit when you find a block!
{% endhint %}

{% hint style="info" %}
Note:

In order to protect your machine from material that may be illegal in your country, you should use a content policy when mining Arweave. Content policies can be generated using the [Shepherd tool](https://github.com/shepherd-media-classifier/shepherd). Shepherd allows you to create your own content policies for the content that you would like to store on your Arweave node, abiding by your moral and legal requirements.

In order to help you get started quickly, @ArweaveTeam provides an NSFW content filter which you can load by adding the following to your Arweave start command:

`transaction_blacklist_url http://shepherd-v.com/nsfw.txt`
{% endhint %}

If you would like to see a log of your miner’s activity, you can run `./bin/logs -f` in the Arweave directory in a different terminal. Sometimes it is helpful to look at the debug logs which are written if the node is started with the `debug` flag in the command line - `./bin/debug-logs -f`

The mining console should eventually look like this:

```
Mining performance report:
Total avg: 9.97 MiB/s,  39.87 h/s; current: 0.00 MiB/s, 0 h/s.
Partition 1 avg: 0.01 MiB/s, current: 0.00 MiB/s.
Partition 2 avg: 0.03 MiB/s, current: 0.00 MiB/s.
Partition 3 avg: 0.34 MiB/s, current: 0.00 MiB/s.
Partition 4 avg: 0.31 MiB/s, current: 0.00 MiB/s.
```

When you mine a block, the console shows:

```
[Stage 2/3] Produced candidate block ... and dispatched to network.
```

Approximately 20 minutes later, you should see

```
[Stage 3/3] Your block ... was accepted by the network
```

Note that occasionally your block won't be confirmed (the chain chooses a different fork).

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

Due to Arweave node specifics (storing data in the sparse files), the read throughput during mining after the initial sync might be suboptimal on some disks. In the performance reports printed in the console you can see the estimated optimal performance in MiB/s, per configured storage module. The first number estimates the optimum on a small dataset, the second - on the dataset close in size to the weave size.  If the actual performance of a storage module is noticeably lower, consider running a defragmentation procedure to improve your mining performance on this module. (Re)start the miner with the following parameters:

```
./bin/start run_defragmentation defragment_module 8,YOUR-MINING-ADDRESS defragmentation_trigger_threshold 500000000 ...
```

The defragmentation is performed before startup. Only chunk files larger than `defragmentation_trigger_threshold` bytes and those which have grown by more than 10% since the last defragmenation of this module will be updated. Note the defragmentation may take a lot of time.

## Troubleshooting

### Make sure your node is accessible on the Internet

An important part of the mining process is discovering blocks mined by other miners. Your node needs to be accessible from anywhere on the Internet so that your peers can connect with you and share their blocks.

To check if your node is publicly accessible, browse to `http://[Your Internet IP]:1984`. You can [obtain your public IP here](https://ifconfig.me/), or by running `curl ifconfig.me/ip`. If you specified a different port when starting the miner, replace "1984" anywhere in these instructions with your port. If you can not access the node, you need to set up TCP port forwarding for incoming HTTP requests to your Internet IP address on port 1984 to the selected port on your mining machine. For more details on how to set up port forwarding, consult your ISP or cloud provider.

If the node is not accessible on the Internet, the miner functions but is significantly less efficient.

## Staying up to Date

* Join our [Discord](https://discord.gg/GHB4fxVv8B) server
* Join our mining [mailing list](https://mailchi.mp/fa68b561fd82/arweavemining)

Once you are successfully mining on the Arweave, you will need to stay up to date with new releases. [Join the mailing list](https://mailchi.mp/fa68b561fd82/arweavemining) to receive emails informing you that a new update has been released, along with the steps you need to take to stay up to speed - particularly updates that require you to perform an action within a certain time period in order to stay in sync with the network. Keep an eye out for these messages, and if possible make sure that you add [team@arweave.org](mailto:team@arweave.org) to your email provider’s trusted senders list!
