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

## Preparation: Linux 

1. **Install an up-to-date version of** [**Erlang**](https://www.erlang.org/downloads) **\(Erlang/OTP 20+\), git and libssl-dev or equivalent**

   \(usually available from your Linux distribution’s package manager\)

2. **Use git to clone the latest stable release using the following command:**

```
git clone https://github.com/ArweaveTeam/arweave.git arweave && \
cd arweave && git -c advice.detachedHead=false checkout stable
```

Alternatively, you can simply run this [script](https://raw.githubusercontent.com/ArweaveTeam/arweave/master/install.sh) on a fresh Ubuntu installation. Because this script installs dependencies for you it will require your root password, so please make sure you are comfortable with the commands that it will run before execution. You can download and execute the script with this command:

```bash
curl https://raw.githubusercontent.com/ArweaveTeam/arweave/stable/install.sh | bash
```

## Preparation: Other Operating Systems

In order to run the Arweave miner on Mac OS X please execute the following steps:

1. **Install** [**Homebrew**](https://brew.sh/)\*\*\*\*
2. **Install Erlang OTP 20: `brew install erlang@20 && brew link --force erlang@20`**
3. **Finally, run the following command:** 

```text
git clone https://github.com/ArweaveTeam/arweave.git arweave && \
cd arweave && git -c advice.detachedHead=false checkout stable
```

{% hint style="info" %}
It is also possible to set-up an Arweave mining environment on Windows using the ‘Windows Subsystem for Linux’ or a virtual machine environment
{% endhint %}

## Running the Miner

Now you’re ready to start the mining process by using the following command from the Arweave directory: 

```text
./arweave-server mine mining_addr YOUR-MINING-ADDRESS peer 206.189.5.91 peer 209.97.142.143 peer 209.97.142.169 peer 204.48.27.17 peer 167.99.98.48 peer 209.97.160.159 peer 138.197.131.159 peer 34.216.88.202
```

{% hint style="warning" %}
Please replace **YOUR-MINING-ADDRESS** with the address of the wallet you would like to credit when you find a block!
{% endhint %}

If you would like to see a log of your miner’s activity, you can run **‘make log’** in the Arweave directory in a different terminal. The miner terminal itself only displays the most important logs to keep it clean so that you can interact with the system using the console.

## Troubleshooting

### Make sure your node is accessible on the Internet

An important part of the mining process is discovering blocks mined by other miners. Your node needs to be accessible from anywhere on the Internet so that your peers can connect with you and share their blocks.

To check if your node is publicly accessible, browse to `http://[Your Internet IP]:1984`. If you specified a different port when starting the miner, replace "1984" anywhere in these instructions with your port. If you can not access the node, you need to set up TCP port forwarding for incoming HTTP requests to your Internet IP address on port 1984 to port 1984 on your mining machine. For more details on how to set up port forwarding, consult your ISP or cloud provider.

Missing port forwarding is a common reason for the warning which begins with:  
  
`"WARNING: No foreign blocks received from the network.`

Alternatively, you can run the miner in the polling mode. In this mode, your node does not have to be publicly accessible. It would check with other peers for updates at regular intervals. To run in the polling mode, specify "polling" in the command line:

```text
./arweave-server polling mine mining_addr YOUR-MINING-ADDRESS peer 206.189.5.91 peer 209.97.142.143 peer 209.97.142.169 peer 204.48.27.17 peer 167.99.98.48 peer 209.97.160.159 peer 138.197.131.159 peer 34.216.88.202
```

Note that the polling mode is significantly less efficient.

### Wait until the blocks are downloaded

The Arweave miner does not mine without data. For every new block in order to mine it, a random block from the past is required. It takes a few days to download all the blocks from the peers so do not expect the mining to be very intensive after the first launch. For example, if you have 10% of the total amount of blocks, you have a 10% chance for being able to participate in mining the next block.

The following log indicates the miner does not have a block required to mine the current block \(the network mines a new block approximately every two minutes\). You do not have to take any action.

`=INFO REPORT==== 13-Mar-2019::11:02:20 === could_not_start_mining stored_recall_block_for_foreign_verification`

### Bootstrap the second miner faster

If you want to bootstrap another miner on a different machine, you can copy the downloaded data over from the first miner to bring it up to speed faster. Please follow these steps:

1. Stop the first Arweave miner \(also, do not run the new miner just yet\).
2. Copy the following folders to the new machine: `blocks`, `txs`, `wallet_lists`, `data`.
3. Start the miners.

## Staying up to Date

* Join our [Discord](https://discord.gg/3UTNZky) server
* Join our mining [mailing list](https://mailchi.mp/fa68b561fd82/arweavemining)

Once you are successfully mining on the Arweave, you will need to stay up to date with new releases. [Join our mailing list](https://mailchi.mp/fa68b561fd82/arweavemining) to receive emails informing you that a new update has been released, along with the steps you need to take to stay up to speed. Updates that require you to perform an action within a certain time period in order to stay in sync with the network will be labeled ‘\[ACTION REQUIRED\]’. Keep an eye out for these messages, and if possible make sure that you add team@arweave.org to your email provider’s trusted senders list!





