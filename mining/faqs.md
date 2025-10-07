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

When you run your miner it will periodically print a Mining Performance Report to the console. You can read more about the Mining Performance Report [here](mining-quickstart.md#mining-screen-metrics). If your node is syncing the weave it will display 0 h/s but will go up over time.

You can also use Prometheus and Grafana as described in the [Metrics Guide](metrics.md).

### Can I mine on Windows/MacOS?

At the moment we have a Linux client available, but we will be making mining more accessible on other operating systems in the future. Windows WSL may be possible but is not recommended.

We have not validated mining or packing on MacOS, but as of May, 2024 the M2 provides the fastest known VDF implementation and so makes a good candidate for VDF Servers. See the [VDF Guide](vdf.md) for instructions on setting up a VDF Server.

### How to build Arweave on MacOS?

Arweave is using OpenSSL 1.1+ for its SHA2 implementation. This version has been deprecated by the OpenSSL team on [September 7, 2023](https://openssl-library.org/source/old/1.1.1/index.html). On MacOS, the Homebrew team deprecated OpenSSL 1.1.1w on October 24, 2023,  and disabled its full support on [October 24, 2024](https://github.com/Homebrew/homebrew-core/commit/8f4ebbe08bb6ef86601b553012f31296914777ec). This last commit will generate this error when trying to install this OpenSSL version on MacOS:

```sh
% brew install openssl@1.1
```

```
Error: openssl@1.1 has been disabled because it is not supported upstream! It was disabled on 2024-10-24.
```

It is still possible to force the installation:

```sh
brew install -f openssl@1.1
```

Arweave also requires Erlang R24. Homebrew always define by default the latest version of Erlang, not compatible at this time with Arweave. To fix this issue, a version must be pinned:

```sh
brew install erlang@24
```

When installing a custom version, some additional configuration are required:

```
Man pages can be found in:
  /opt/homebrew/opt/erlang@24/lib/erlang/man

Access them with `erl -man`, or add this directory to MANPATH.

erlang@26 is keg-only, which means it was not symlinked into /opt/homebrew,                                                                                                                                        because this is an alternate version of another formula.
If you need to have erlang@24 first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/erlang@26/bin:$PATH"' >> ~/.zshrc

For compilers to find erlang@24 you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/erlang@24/lib"
```

Few directories need to be added into the default path.

```sh
echo 'export PATH="/opt/homebrew/opt/erlang@24/bin:$PATH"' >> ~/.zshrc
```

In some situation, `LDFLAGS`, `CFLAGS` and `CCFLAGS` environment variables need to be modified. This is not a mandatory requirement, but it can help to fix a failing build.

```sh
echo 'export LDFLAGS="-L/opt/homebrew/opt/erlang@24/lib"' >> ~/.zshrc
echo 'export CFLAGS="-H /opt/homebrew/opt/erlang@24/lib/erlang/usr/include"' >> ~/.zshrc
echo 'export CCFLAGS="-H /opt/homebrew/opt/erlang@24/lib/erlang/usr/include"' >> ~/.zshrc
```

Don't forget to `pin` the version on homebrew. 

```sh
brew pin erlang@24
```

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
is currently tracked by IP:PORT, so whenever your IP changes, your reputation will be reset.

Reputation primarily comes into play when you mine a solution, Peers will process the solutions
of higher reputation peers first. So if you have a low reputation and mine a block at about
the same time as a miner with a higher reputation, there's a greater chance that your block
will be processed later and potentially orphaned.

### Can I run a single server which can mine the entire weave?

Yes, and no. Currently, consumer level hardware makes this very difficult due to PCIe bandwidth and overall processing power. However, higher core Threadrippers and Epyc processors are capable of this, depending on your processor version, due to their increased PCIe bandwidth and computational power.

### Can I use a graphics card with Arweave?

No, Arweave uses Randomx for packing and mining. RandomX is an ASIC and GPU resistant algorithm.

### What’s the best hard drive to use?

Any enterprise level hard drive that can sustain the read rates required for your configuration. See [this table](mining-guide.md#Preparation-Packing-Format) for the read speeds required per partition of packed data. Storing more partitions on a single disk will require a higher sustained read rate.In general an SSD will not be cost effective.

See the [Hardware Guide](hardware.md) and the [Quickstart Guide](mining-quickstart.md) for more information.

### Is one storage module worth more than another?

Not at this time, but some contain more data than others, so if you have a limited amount of hard drives available, pack the fullest storage modules first. For more information on storage module sizes, see the [Syncing and Packing Guide](syncing-packing.md)

### I see there are several packing formats available, what are the trade-offs?

As of Arweave 2.9 there are two main packing formats available, `spora_2_6` and `replica_2_9`. See the [Packing Format](mining-guide.md#Preparation-Packing-Format) section of the Mining Guide for more information.

All packing formats provide the same maximum hashrate. A miner who has packed a full replica to `spora_2_6` will have the same hashrate as a miner who has packed a full replica to `replica_2_9` - provided both miners are able to read the packed data and perform all hashes at the required rate.

`spora_2_6` is deprecated and will stop being usable toward the end of 2028. For all new packs we recommend using the `replica_2_9` format. The lower read rates that a `replica_2_9` packing allows will reduce the hardware resources used during mining (larger disks, lower disk read rate, lower CPU and RAM utilization).

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

It should be as low as possible. The network targets an average VDF speed of 1 second and you want to be as close to that as possible (or lower).

See the [VDF Guide](vdf.md) for more information.

### Can I kill the arweave process if it's taking too long to shutdown?

No. Avoid killing the arweave process if at all possible. I.e. **don't** do `kill -9 arweave` or `kill -9 beam` or `kill -9 erl`. To stop the arweave process, use `./bin/stop` and then wait for as long as you can for the node to shutdown gracefully. Sometimes if can take a while for the node to shutdown, which we realize is frustrating, but if you kill the node abruptly it can cause `rocksdb` corruption that can be difficult to recover from. In the worst case you may need to resync and repack a partition.

### How to use the new Arweave entry-point?

The new Arweave entry-point located in `bin/arweave` is an updated
version of the old one, integrating all required functions in one
place. To print the help page, simple execute the script:

```sh
./bin/arweave
```

It is also possible to have a more detailed help of one particular
	subcommand by passing it after the `help` one.

```sh
./bin/arweave help ${subcommand}
```

### How to start Arweave?

Arweave can be started in many different ways depending of the needs
and all these methods can be used with `./bin/arweave`
entry-point. Most of the users are using `./bin/start` to start an
arweave node, this script is equivalent to:

```sh
./bin/arweave start ${parameters}
```

To have access to Arweave output directly from the terminal (without
the Erlang console) the following command can be used. It could be
used with any process manager like `systemd`, because the VM will not
fork.

```sh
./bin/arweave foreground ${parameters}
```

To have access to Arweave output directly from the terminal with an
Erlang console:

```sh
./bin/arweave console ${parameters}
```

Arweave can also be started as an Unix daemon (in background) by
executing the following command:

```sh
./bin/arweave daemon ${parameters}
```

To reattach a daemon (and having access to the Erlang console), one
can execute the subcommand `daemon_attach`.

```sh
./bin/arweave daemon_attach
```

### How to know if my Arweave node is correctly started?

To ensure a node is correctly running, one can ping it using
`./bin/arweave` entry-point. The script will return the string `pong`
if the node is up.

```sh
./bin/arweave ping
```

The same information can be available by using the subcommand
`status`, except nothing will be printed. The command will return `0`
if the node is up and `1` if the node is down. Useful for monitoring
scripts.

```sh
./bin/arweave status
```

Finally, to see if the node is reachable, it is also possible to use
external software like `curl`:

```sh
curl http://localhost:1984/
```

### How to have access to a remote console?

An Erlang shell can be invoked to control the Erlang VM where Arweave
is running. The `./bin/console` script can be used and it is
equivalent to execute this command:

```sh
./bin/arweave remote_console
```

The shell can be ended by pressing `Ctrl` + `C`.

### How to stop an arweave node?

An Arweave node can be stopped by using the script `./bin/stop` or by
executing the following command:

```
./bin/arweave stop
```

### How to run multiple nodes on one machine?

An arweave node is identified by its ip address and a TCP port
(default to 1984). So, more than one node can be started in parallel,
listening to another TCP port. The first step is to create a new
arweave configuratoin with an isolated `data_dir` parameter and set a
new value for `port` parameter. It can be configured from a JSON
configuration file or directly from the command line. Then, two
environment variables need to be set, `ARNODE` defining the Erlang
node name and `ARCOOKIE`, defining the cookie used for this node.

```sh
export ARNODE='my_new_node@127.0.0.1'
export ARCOOKIE='my_cookie'
./bin/start port 1985 data_dir /my/new/data_dir
```

To control the default node, unset `ARNODE` and `ARCOOKIE`.

```sh
unset ARNODE
unset ARCOOKIE
```

### How to pass custom Erlang VM arguments?

The first - and easiest - method is to pass the new argument directly
from the command line, all arguments before `--` will be used to
overwrite the default VM parameters of the Erlang VM. All arguments
after `--` will be used for Arweave.

```sh
./bin/start +MMscs 131072 +S 16:16 -- config_file config.json
```

The second method is to modify
`rel/arweave/releases/${arweave_release}/vm.args.src` file. This file
contains all default parameters used by Arweave with some links to the
official documentation to help anyone wanting to optimize the Erlang
VM.

### How to use developer mode?

The developer mode can be used by setting the environment variable
`ARWEAVE_DEV` to any kind of value or (when using the sources from
git) by executing the script `bin/arweave-dev`. The developer mode
will automatically recompile a release and required file everytime the
script is executed.

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


### My solution fails with this error `step_checkpoints_not_found`

Full error message is something like `ar_mining_server:log_prepare_solution_failure2/5:142 event: failed_to_prepare_block_from_mining_solution, reason: step_checkpoints_not_found`

This is a rare edge case that can happen when your VDF server and VDF client are briefly on different branches of a fork.

More specifically:

1. There's a fork at a block that opens a new VDF session.
2. VDF server applies one block
3. VDF client attempts to mine a block at the same height

Since the VDF server has already applied a block and opened a new session, the miner is unable to get all the VDF steps it needs for its solution and the solution fails.

This is a fairly rare occurrence, and as soon as both your VDF server and client are once again on the same chain (usually happens naturally within a few minutes), the miner should resume mining valid solutions.

To reduce the likelihood of this happening you'll want to:
1. Make sure your VDF server and VDF clients are close to each other (to reduce the chance that server and client land on different branches of a fork)
2. You can try setting the `block_gossip_peer` option on both VDF server and clients (and specify each others' IP:PORT). This will ensure that VDF servers and clients forward any blocks they receive to each other without relying on network gossip. This should limit the likelihood that VDF Server and Peer land on different branches of a fork.

