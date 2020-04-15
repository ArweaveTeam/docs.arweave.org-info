---
description: >-
  Want to start mining on Arweave? You've come to the right place! Get set up
  with this quick and easy guide, and join our awesome network of ever-growing
  miners.
---

# Mining Guide

{% hint style="warning" %}
**For any questions and support queries regarding mining on Arweave, we strongly recommend that you join our** [**Discord server**](https://discord.gg/DjAFMJc) **as this is the hub of our mining and developer communities. Here you will find plenty of community members and Arweave team members available to help you out** 🤖 
{% endhint %}

## Install the Miner

Download the `.tar.gz` archive for your OS from the [releases page](https://github.com/ArweaveTeam/arweave/releases).

Extract the contents of the archive. It's recommended to unpack it inside a dedicated directory. You can always move this directory around, but the miner may not work if you move only some of the files. The weave data would, by default, be stored in this directory as well, but it can be overridden using the `data_dir` command-line argument.

If your OS/platform architecture is not in the list, check the source code repository [README](https://github.com/ArweaveTeam/arweave#building-from-source) for how to build the miner from source.

{% hint style="info" %}
It is also possible to set-up an Arweave mining environment on Windows using the ‘Windows Subsystem for Linux’ or a virtual machine environment.
{% endhint %}

## Preparation: File Descriptors Limit <a id="preparation-file-descriptors-limit"></a>

The number of available file descriptors affects the rate at which your node can process data. As the default limit assigned to user processes on most operating systems is usually low, we recommend increasing it.

You can check the current limit by executing `ulimit -n`.

On Linux, to set a bigger global limit, open `/etc/sysctl.conf` and add the following line:

```text
fs.file-max=10000
```

Execute `sysctl -p` to make the changes take effect.

You may also need to set a proper limit for the particular user. To set a user-level limit, open `/etc/security/limit.conf` and add the following line:

```text
<your OS user>         soft    nofile  10000
```

Open a new terminal session. To make sure the changes took effect, and the limit was increased, type `ulimit -n`. You can also change the limit for the current session via `ulimit -n 10000`

## Running the Miner

Now you’re ready to start the mining process by using the following command from the Arweave directory: 

```text
./bin/start mine mining_addr YOUR-MINING-ADDRESS peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 159.203.158.108 peer 139.59.51.59 peer 138.197.232.192
```

{% hint style="warning" %}
Please replace **YOUR-MINING-ADDRESS** with the address of the wallet you would like to credit when you find a block!
{% endhint %}

If you would like to see a log of your miner’s activity, you can run **‘./bin/logs -f’** in the Arweave directory in a different terminal.

## Tuning the Miner

To get an additional performance boost, consider configuring huge memory pages in your OS.  
  
On Ubuntu, to see the current values, execute:`cat /proc/meminfo | grep HugePages`. To set a value, run `sudo sysctl -w vm.nr_hugepages=2000`. Here, "2000" corresponds to two thousand pages of 2 MiB each. Do not set a value bigger than the amount of available memory \(the "total" column from `"free -m"`\) minus 6 GiB. If the displayed value is lower than what you have set, reboot the machine and try again.

You can benchmark your machine's performance with different settings by running `./bin/start benchmark randomx enable randomx_large_pages`. Note that you have to stop the miner before running the benchmark.

It is recommended to reboot the machine after configuring huge pages and before running the miner, especially if the machine had a significant uptime before to the change. To make the configuration survive reboots, create `/etc/sysctl.d/local.conf` and put `vm.nr_hugepages=[YOUR NUMBER]` there.

## Troubleshooting

### Make sure your node is accessible on the Internet

An important part of the mining process is discovering blocks mined by other miners. Your node needs to be accessible from anywhere on the Internet so that your peers can connect with you and share their blocks.

To check if your node is publicly accessible, browse to `http://[Your Internet IP]:1984`. You can [obtain your public IP here](https://ifconfig.me/), or by running `curl ifconfig.me/ip`. If you specified a different port when starting the miner, replace "1984" anywhere in these instructions with your port. If you can not access the node, you need to set up TCP port forwarding for incoming HTTP requests to your Internet IP address on port 1984 to the selected port on your mining machine. For more details on how to set up port forwarding, consult your ISP or cloud provider.

Missing port forwarding is a common reason for the warning which begins with:  
  
`WARNING: No foreign blocks received from the network or found by trusted peers.`

Alternatively, you can run the miner in the polling mode. In this mode, your node does not have to be publicly accessible. It would check with other peers for updates at regular intervals. To run in the polling mode, specify "polling" in the command line:

```text
./bin/start polling mine mining_addr YOUR-MINING-ADDRESS peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 159.203.158.108 peer 139.59.51.59 peer 138.197.232.192
```

Note that the polling mode is significantly less efficient and is not recommended.  
  
Also note that if your node does not receive any blocks for a minute, even when the polling mode is not enabled, the node will ask its trusted peers for new blocks. This is a safety measure to avoid stalling.

### Wait until the blocks are downloaded

The Arweave miner does not mine without data. For every new block in order to mine it, a random chunk of data from the past is required. It takes time to download data from the peers, so do not expect the mining to be very intensive after the first launch. For example, if you have 10% of the total weave size, you have a 10% chance of being able to participate in mining the next block at the current network difficulty. The miner will still attempt to mine using the data it has, but the difficulty increases exponentially with every missing chunk taken from the deterministic sequence of chunks seeded by the current block hash.

The following log indicates the miner gave up looking for data required to mine the current block \(the network mines a new block approximately every two minutes\). You do not have to take any action.

`=INFO REPORT==== 13-Mar-2019::11:02:20 ===  
event: could_not_start_mining  
reason: data_unavailable_to_generate_poa`

### Bootstrapping a second miner faster

If you want to bootstrap another miner on a different machine, you can copy the downloaded data over from the first miner to bring it up to speed faster. Please follow these steps:

1. Stop the first Arweave miner, and ensure the second miner is also not running.
2. Copy the following folders to the new machine: `blocks`, `txs`, `wallet_lists`, `data`.
3. Start both miners.

### Removing old wallet lists to clean up some space

Run the following script while the miner is running:

```text
./bin/remove-old-wallet-lists
```

If you are building the miner from source, the script is `./bin/remove-old-wallet-lists-dev`.

### Run a miner on Windows

We do not recommend using Windows for mining because according to our experience it is less efficient and reliable. Nevertheless, mining on Windows is possible.

You can run an Arweave miner inside Windows Subsystem for Linux \(WSL\). Note that the default TCP configuration WSL relies on is more restrictive than a typical Linux configuration. The WSL configuration offers about half as many TCP ports for making TCP connections and twice as long socket re-use timeout, what significantly reduces the number of simultaneous requests per second the miner can make to other nodes.

As a result, you may see the following errors in the miner console:  
  
  
`=ERROR REPORT====...=== Socket connection error: exit badarg, [{gen_tcp,connect,4, [{file,"gen_tcp.erl"},{line,149}]}`

  
Windows Event Log is expected to have the following warning:  
  
`TCP/IP failed to establish an outgoing connection because the selected local endpoint was recently used to connect to the same remote endpoint. This error typically occurs when outgoing connections are opened and closed at a high rate, causing all available local ports to be used and forcing TCP/IP to reuse a local port for an outgoing connection. To minimize the risk of data corruption, the TCP/IP standard requires a minimum time period to elapse between successive connections from a given local endpoint to a given remote endpoint.`

## Staying up to Date

* Join our [Discord](https://discord.gg/3UTNZky) server
* Join our mining [mailing list](https://mailchi.mp/fa68b561fd82/arweavemining)

Once you are successfully mining on the Arweave, you will need to stay up to date with new releases. [Join our mailing list](https://mailchi.mp/fa68b561fd82/arweavemining) to receive emails informing you that a new update has been released, along with the steps you need to take to stay up to speed - particularly updates that require you to perform an action within a certain time period in order to stay in sync with the network. Keep an eye out for these messages, and if possible make sure that you add [team@arweave.org](mailto:team@arweave.org) to your email provider’s trusted senders list!





