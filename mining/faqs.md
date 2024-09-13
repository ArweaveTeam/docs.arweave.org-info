# Mining Troubleshooting and FAQs

**Significantly updated by @Thaseus in August 2024**

## Intro

This document includes some of the common issues mentioned in the Arweave Miners discord server. This will be a living document, and as new issues can arise, it may be updated. The ultimate goal of this document is to set you on the right direction in solving your issue, even if your exact issue is not listed. Please note, profitability is left out intentionally as it is very dynamic.


## FAQs

### Are AR wallets/addresses created automatically for miners, and if so, how do I access them?

Yes, if you do not provide a wallet address on the command line when starting the miner, a new wallet will be created for you and stored in the ‘wallets’ directory. When you run the miner again, you will want to pass the generated wallet address on the command line. Any valid Arweave wallet address will work for mining. For example, you can use a wallet that was generated in the Arweave web extension for mining purposes -- you just need the wallet address. If you want to install the web extension you can do that here: [Chrome](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc), [Firefox](https://addons.mozilla.org/en-US/firefox/addon/arweave/), or [Brave](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc).

### Is my mining address a private key?

Your mining address is **not** a private key - it is a public address. But it is paired with a private key (stored in your `wallets` directory with a name like `arweave_keyfile_MININGADDRESS.json`) which you will need to sign any blocks you mine. When mining, only nodes that will sign blocks need to have a private key / wallet.json stored locally

### Do I have to download & store the whole blockweave to begin mining?

Yes, and no. It is certainly best, as the more data you store, the higher your hashrate. The increase in hashrate is not linear, and rises faster with the more data you have stored. For more information on this, see the [Hashrate Guide](hashrate.md).

However, if you choose to not store a full weave, I would suggest using [Vird’s Pool](https://ar.virdpool.com/) ([Discord](https://discord.gg/hTCmhGWPEp)). It is the only Arweave pool which uses the standard client at this time and will help you earn AR faster than solo mining.

### How do I see my mining performance?

When you run your miner it will periodically pring a Mining Performance Report to the console. You can read more about the Mining Performance Report [here](mining-quickstart.md#mining-screen-metrics). If your node is syncing the weave it will display 0 h/s but will go up over time.

You can also use Prometheus and Grafana as described in the [Metrics Guide](metrics.md).

### Can I mine on Windows/MacOS?

At the moment we have a Linux client available, but we will be making mining more accessible on other operating systems in the future. Windows WSL may be possible but is not recommended.

We have not validated mining or packing on MacOS, but as of May, 2024 the M2 provides the fastest known VDF implementation and so makes a good candidate for VDF Servers. See the [VDF Guide](vdf.md) for instructions on setting up a VDF Server.

### Is there a specific recommendation for Ubuntu version?

We recommend [Ubuntu version 22.04+ ](http://releases.ubuntu.com/22.04/)

### Which filesystem should I use?

`ext4` with the `noatime` option enabled on mounted drives is recommended.

### Can I use RAID?

Yes, but it will add a lot of complexity and overhead for potentially small gains. 

### How do I speed up the packing process?

You will need to utilize more servers and/or higher core counts and faster CPU’s to pack the weave faster. See the [Syncing and Packing Guide](syncing-packing.md#performance-tips) for more information.

### What is the optimal way to pack storage modules

The best way is to sync as many modules from the network at the same time as you can. Many miners max out bandwidth or CPU capacity packing at least three modules at a time. See the [Syncing and Packing Guide](syncing-packing.md#performance-tips) for more information.

### How do I keep the miner running after closing my terminal window?

We recommend starting the miner in a screen session, you can then safely disconnect from the `screen` session and close your terminal with the miner still running

### Can I mine on the Arweave network with a dynamic IP?

Yes - but there are some caveats:

Miners benefit by getting the latest set of blocks and transactions as fast as possible to
limit the time wasted mining against a stale chain tip. Miners can get blocks 2 ways:
  1. By polling their peers for new blocks and transactions
  2. By being notified of new blocks and transactions by other miners

If you have a dynamic IP you may not get notified by your peers as quickly as a miner with
a static IP. However your miner will continue to poll, so the lag will be minimal.

A slightly bigger issue is your "peer reputation". All peers in the network maintain a rating
for all other peers based on past activity. It basically boils down to the amount of valid
data exchanged. As your node sends valid data to peers, your reputation increases. Reputation
is currently tracked by IP:PORT, so whenever your IP changes, your repuation will be reset.

Reputation primarily comes into play when you mine a solution, Peers will process the solutions
of higher reputation peers first. So if you have a low reputation and mine a block at about
the same time as a miner with a higher reputation, there's a greater chance that your block
will be processed later and potentially orphaned.

### Can I run a single server which can mine the entire weave?

Yes, and no. Currently, consumer level hardware makes this very difficult due to PCIe bandwidth and overall processing power. However, higher core Threadrippers and Epyc processors are capable of this, depending on your processor version, due to their increased PCIe bandwidth and computational power.

### Can I use a graphics card with Arweave?

No, Arweave uses Randomx for packing and mining. RandomX is an ASIC and GPU resistant algorithm.

### What’s the best hard drive to use?

Any enterprise level hard drive that reads at least an average of 200 MiB/s is sufficient, but do not use an SSD as it will not be cost effective.

See the [Hardware Guide](hardware.md) and the [Quickstart Guide](mining-quickstart.md) for more information.

### What size of drive should I use?

Your drive should have at least 4TB in size, but you can use a larger drive if you wish. This may be done to increase your read speed, but please note, you currently may not have more than one storage module mining from a single hard drive due to read performance requirements.

### Is one storage module worth more than another?

Not at this time, but some contain more data than others, so if you have a limited amount of hard drives available, pack the fullest storage modules first. For more information on storage module sizes, see the [Syncing and Packing Guide](syncing-packing.md)

### How much space should I allocate to my `data_dir`?

Ideally you want the bare minimum to be 200GB, however it is far better to have at least 500GB.

### Can I operate Arweave over a NAS?

You could certainly pack over a NAS, but the bandwidth required to mine over a NAS would be very cost prohibitive and difficult to achieve

### Can / should I mine while I am packing my storage modules?

No, it is inefficient to mine while packing, and will take far longer to pack than if you simply devote all of your processing power to packing.

### Is there metrics or a graphical interface I can see in order to understand my performance

Yes, you can read your metrics manually by going to localhost:port/metrics

You can also (and should), set up Grafana and Prometheus to give you a very nice interface. See the [Metrics Guide](metrics.md) for more information.

### What should my VDF speed be?

It should be as low as possible. The network targets an average VDF speed of 1 second and you wnat to be as close to that as possible (or lower).

See the [VDF Guide](vdf.md) for more information.

### Can I kill the arweave process if it's taking too long to shutdown?

No. Avoid killing the arweave process if at all possible. I.e. **don't** do `kill -9 arweave` or `kill -9 beam` or `kill -9 erl`. To stop the arweave process, use `./bin/stop` and then wait for as long as you can for the node to shutdown gracefully. Sometimes if can take a while for the node to shutdown, which we realize is frustrating, but if you kill the node abruptly it can cause `rocksdb` corruption that can be difficult to recover from. In the worst case you may need to resync and repack a partition.

## Troubleshooting

### I don’t seem to be receiving new blocks from peers - why is this?

The most likely cause of this issue is that your router is not forwarding messages for port 1984 to your machine. You can address this by configuring port forwarding on your router and ensuring that port 1984 is not blocked by your firewall

### Storage modules have stopped syncing for hours, and they do not seem as full as others

The storage module is likely full. Some partitions can never be filled - especially modules below 10, and in the early 30’s. See the [Syncing and Packing Guide](syncing-packing.md#partition-sizes) for more information.

### My VDF speed fluctuates often

Assuming you are using the Team’s VDF server, it is normal. VDF servers can only compute VDF, anything else running on the server will slow down the compute and increase your VDF time (and slow down your hashrate).

If your VDF changes often, and also shows Undefined frequently, you may have a network congestion issue.

### I won a block, and received a reward, why can I not use my AR?

They are held for 30 days in reserve. After 30 days they are unlocked to your account. You can check the amount of reserved rewards on one of your nodes by going to…
 localhost:PORT/wallet/\[your-wallet-address\]/reserved_rewards_total

### I am using a SAS expander and am having performance bottlenecks

SAS expanders will likely reach bandwidth capacity with 12 drives attached, you may require more expanders,

See the [Hardware Guide](hardware.md#sas-version) for more information.

### I am receiving this error `event: failed_to_update_block_index`

Stop your node, navigate to your `data_dir` folder and rename the following folder `rocksdb/block_index_db`

It will rebuild the folder during the next restart

