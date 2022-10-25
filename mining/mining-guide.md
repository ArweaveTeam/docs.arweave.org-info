---
description: >-
  Want to start mining on Arweave? You've come to the right place! Get set up
  with this quick and easy guide, and join our awesome network of ever-growing
  miners.
---

# Mining Guide

{% hint style="info" %}
**For any questions and support queries regarding mining on Arweave, we strongly recommend that you join our** [**_Discord server_**](https://discord.gg/GHB4fxVv8B) **as this is the hub of our mining and developer communities. Here you will find plenty of community members and Arweave team members available to help you out** 🤖
{% endhint %}

{% hint style="warning" %}
Arweave core developers have been made aware that at least one mining node inside the Chinese mainland has been seized by the government. Node operators should understand that the Arweave network stores and serves a significant amount of material related to the activities of the Chinese government. The Arweave protocol does not require that any miner to store data that they deem inappropriate. You can read more about our content policies [**_here_**](https://www.arweave.org/technology#content-moderation).
{% endhint %}

## Install the Miner

Download the `.tar.gz` archive for your OS from the [**_releases page_**](https://github.com/ArweaveTeam/arweave/releases).

Extract the contents of the archive. It's recommended to unpack it inside a dedicated directory. You can always move this directory around, but the miner may not work if you move only some of the files. The weave data would, by default, be stored in this directory as well, but we recommend to override it using the `data_dir` command-line argument.

If your OS/platform architecture is not in the list, check the source code repository [**_README_**](https://github.com/ArweaveTeam/arweave#building-from-source) for how to build the miner from source.

{% hint style="info" %}
It is also possible to set-up an Arweave mining environment on Windows using the ‘Windows Subsystem for Linux’ or a virtual machine environment.
{% endhint %}

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

## Running the Miner

Now you’re ready to start the mining process by using the following command from the Arweave directory:

{% hint style="info" %}
Note:

In order to protect your machine from material that may be illegal in your country, you should use a content policy when mining Arweave. Content policies can be generated using the [**_Shepherd tool_**](https://github.com/shepherd-media-classifier/shepherd). Shepherd allows you to create your own content policies for the content that you would like to store on your Arweave node, abiding by your moral and legal requirements.

In order to help you get started quickly, @ArweaveTeam provides an NSFW content filter which you can load by adding the following to your Arweave start command:&#x20;

`transaction_blacklist_url http://shepherd-v.com/nsfw.txt`
{% endhint %}

```
./bin/start mine mining_addr YOUR-MINING-ADDRESS peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 139.59.51.59 peer 138.197.232.192
```

{% hint style="warning" %}
Please replace **YOUR-MINING-ADDRESS** with the address of the wallet you would like to credit when you find a block!
{% endhint %}

If you would like to see a log of your miner’s activity, you can run `./bin/logs -f` in the Arweave directory in a different terminal.

The mining console should eventually look like this:

```
[Stage 1/3] Starting to hash
Miner spora rate: 1545 h/s, recall bytes computed/s: 3129, MiB/s read: 386, the round lasted 145 seconds.
[Stage 1/3] Starting to hash
Skipping hashrate report, the round lasted less than 10 seconds.
[Stage 1/3] Starting to hash
Miner spora rate: 1545 h/s, recall bytes computed/s: 3182, MiB/s read: 386, the round lasted 135 seconds.
[Stage 1/3] Starting to hash
Miner spora rate: 1637 h/s, recall bytes computed/s: 3292, MiB/s read: 409, the round lasted 245 seconds.
[Stage 1/3] Starting to hash
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

To stop the miner, run `./bin/stop` or kill the OS process (`kill -sigterm <pid>` or `pkill <name>`). Sending a SIGKILL (`kill -9`) is **not** recommended.

## Tuning the Miner

### Optimizing Miners SPoRA Rate

The three crucial factors determining your miner's efficiency are disk throughput (GiB/s), the amount of synchronized data, and processor power. We recommend that you have 32 GiB of RAM, while the minimum requirement is 8 GiB.

The node reports its hashrate in the console - `Miner spora rate: 1546 h/s`and logs -`miner_sporas_per_second`. Note that it is 0 when you start the miner without data and slowly increases as more data is synchronized. After the number stabilizes, you can input it into the mining calculator generously created by the community member @tiamat [**_here_**](https://chronobot.io/arweave/) to see the expected return.

To estimate the hashrate in advance, you would need to know or measure your CPU's performance, the disk throughput, and the amount of disk space you will allocate for mining.

To benchmark CPU, you can run the packaged `randomx-benchmark` script.`./bin/randomx-benchmark --mine --init 32 --threads 32 --jit --largePages`. Replace 32 with the number of CPU threads. Note that reducing the number of threads might improve the outcome. Do not specify `--largePages` if you have not configured them yet. For the reference, a 32-threads AMD Ryzen 3950x can do about 10000 h/s, a 32-threads AMD EPYC 7502P - 24000 h/s, a 12-threads Intel Xeon E-2276G CPU - 2500 h/s, a 2-threads Intel Xeon CPU E5-2650 machine in the cloud - 600 h/s.

If you do not know the throughput of your disk, run `hdparm -t /dev/sda`. Replace `/dev/sda` with the disk name from `df -h`. To be competitive, consider a fast NVMe SSD capable of several GiB per second and more.

Finally, to see the upper hashrate limit of a setup, run `./bin/hashrate-upper-limit 2500 1 3` where 2500 is a RandomX hashrate, 1 is the number of GiB a disk reads per second, 3 is 1/replicated share of the weave. For example, a 12-core Intel Xeon with a 1 GiB/s SSD with a third of the weave is capped at 540 h/s. In practice, the performance is usually about 0.7 - 0.9 of the upper limit.

### Changing the mining configuration

We made our best effort to choose reasonable defaults; however, changing some of the following parameters may improve the efficiency of your miner: `stage_one_hashing_threads` (between 1 and the number of CPU threads), `stage_two_hashing_threads` , `io_threads`, `randomx_bulk_hashing_iterations`. For example,

```
./bin/start stage_one_hashing_threads 32 stage_two_hashing_threads 32 io_threads 50 randomx_bulk_hashing_iterations 64 data_dir /your/dir mine sync_jobs 80 mining_addr YOUR-MINING-ADDRESS peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 139.59.51.59 peer 138.197.232.192
```

`recall bytes computed/s` should be roughly equal to `Miner spora rate` divided by your share of the weave. If it is not, consider increasing `io_threads` and decreasing`stage_one_hashing_threads`. You can learn the share of the weave the node has synced to date by dividing the size of the `chunk_storage` folder (`du -sh /path/to/data/dir/chunk_storage`) by the [**_total weave size_**](https://viewblock.io/arweave/stats). Increasing `randomx_bulk_hashing_iterations` to 128 or bigger might make a big difference on the powerful machine.

### Syncing the weave

The Arweave miner does not mine without data. For every new block, in order to mine it, numerous random chunks of the past data need to be read and checked. It takes time to download data from the peers, so do not expect mining to be very intensive after the first launch. For example, if you have 10% of the total weave size, you are mining at 10% efficiency of a similar setup with the entire dataset. Note that it is not required to download the complete dataset. If you only have 1 TiB of space for the `chunk_storage` and `rocksdb` folders, the node will fill it up, and your miner may nevertheless be competitive, assuming the disk and the processor are sufficiently performant.

To speed up bootstrapping, use a higher (default is 20) value for the `sync_jobs` configuration parameter like this:

```
./bin/start mine sync_jobs 80 mining_addr YOUR-MINING-ADDRESS peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 139.59.51.59 peer 138.197.232.192
```

You can set the sync\_jobs back to 2 after historical data is synced. Turn the miner off (do not set the `mine` flag) to further speed up syncing.

### Configuring large memory pages

To get an additional performance boost, consider configuring huge memory pages in your OS.

On Ubuntu, to see the current values, execute:`cat /proc/meminfo | grep HugePages`. To set a value, run `sudo sysctl -w vm.nr_hugepages=1000`. To make the configuration survive reboots, create `/etc/sysctl.d/local.conf` and put `vm.nr_hugepages=1000` there.

The output of `cat /proc/meminfo | grep HugePages` should then look like this:\
`AnonHugePages: 0 kB`\
`ShmemHugePages: 0 kB HugePages_Total: 1000 HugePages_Free: 1000 HugePages_Rsvd: 0 HugePages_Surp: 0`

If it does not or if there is a "erl\_drv\_rwlock\_destroy" error on startup, reboot the machine.

Finally, tell the miner it can use large pages by specifying `enable randomx_large_pages`on startup:

```
./bin/start mine enable randomx_large_pages mining_addr YOUR-MINING-ADDRESS peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 139.59.51.59 peer 138.197.232.192
```

### Using Multiple Disks

The simplest approach is to store everything on a single disk. Skip this section if you are fine with that. However, you may store metadata that is not used in mining on a cheaper and slower medium, e.g., an HDD disk.

Mount the fast devices to the `chunk_storage` and `rocksdb` folders:

```
sudo mount /dev/nvme1n1 /your/dir/chunk_storage
sudo mount /dev/nvme1n2 /your/dir/rocksdb
sudo mount /dev/hdd1 /your/dir
```

The output of `df -h` should look like:

`/dev/hdd1 5720650792 344328088 5087947920 7% /your/dir /dev/nvme1n1 104857600 2097152 102760448 2% /your/dir/chunk_storage /dev/nvme1n2 104857600 2097152 102760448 2% /your/dir/rocksdb`

Replace /dev/nvme1n1, /dev/nvme1n2, /dev/hdd1 with the filesystems you have, replace `/your/dir` with the directory you specify on startup:

```
./bin/start data_dir /your/dir mine sync_jobs 80 mining_addr YOUR-MINING-ADDRESS peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 139.59.51.59 peer 138.197.232.192
```

## Troubleshooting

### Make sure your node is accessible on the Internet

An important part of the mining process is discovering blocks mined by other miners. Your node needs to be accessible from anywhere on the Internet so that your peers can connect with you and share their blocks.

To check if your node is publicly accessible, browse to `http://[Your Internet IP]:1984`. You can [**_obtain your public IP here_**](https://ifconfig.me/), or by running `curl ifconfig.me/ip`. If you specified a different port when starting the miner, replace "1984" anywhere in these instructions with your port. If you can not access the node, you need to set up TCP port forwarding for incoming HTTP requests to your Internet IP address on port 1984 to the selected port on your mining machine. For more details on how to set up port forwarding, consult your ISP or cloud provider.

If the node is not accessible on the Internet, the miner functions but is significantly less efficient.

### Copying data to another machine

If you want to bootstrap another miner on a different machine, you can copy the downloaded data over from the first miner to bring it up to speed faster. Please follow these steps:

1. Stop the first Arweave miner, and ensure the second miner is also not running.
2. Copy the entire `data_dir` folder to the new machine. Note that the `chunk_storage` folder contains [**_sparse files_**](https://wiki.archlinux.org/index.php/sparse\_file), so copying them the usual way will take a lot of time and the size of the destination folder will be too large. To copy this folder, use rsync with the `-aS` flags or archive it via `tar -Scf` before copying.
3. Start both miners.

### Run a miner on Windows

We do not recommend using Windows for mining because according to our experience it is less efficient and reliable. Nevertheless, mining on Windows is possible.

You can run an Arweave miner inside Windows Subsystem for Linux (WSL). Note that the default TCP configuration WSL relies on is more restrictive than a typical Linux configuration. The WSL configuration offers about half as many TCP ports for making TCP connections and twice as long socket re-use timeout, what significantly reduces the number of simultaneous requests per second the miner can make to other nodes.

As a result, you may see the following errors in the miner console:

`=ERROR REPORT====...=== Socket connection error: exit badarg, [{gen_tcp,connect,4, [{file,"gen_tcp.erl"},{line,149}]}`

Windows Event Log is expected to have the following warning:

`TCP/IP failed to establish an outgoing connection because the selected local endpoint was recently used to connect to the same remote endpoint. This error typically occurs when outgoing connections are opened and closed at a high rate, causing all available local ports to be used and forcing TCP/IP to reuse a local port for an outgoing connection. To minimize the risk of data corruption, the TCP/IP standard requires a minimum time period to elapse between successive connections from a given local endpoint to a given remote endpoint.`

## Staying up to Date

* Join our [**_Discord_**](https://discord.gg/GHB4fxVv8B) server
* Join our mining [**_mailing list_**](https://mailchi.mp/fa68b561fd82/arweavemining)

Once you are successfully mining on the Arweave, you will need to stay up to date with new releases. [**_Join our mailing list_**](https://mailchi.mp/fa68b561fd82/arweavemining) to receive emails informing you that a new update has been released, along with the steps you need to take to stay up to speed - particularly updates that require you to perform an action within a certain time period in order to stay in sync with the network. Keep an eye out for these messages, and if possible make sure that you add [**_team@arweave.org_**](mailto:team@arweave.org) to your email provider’s trusted senders list!
