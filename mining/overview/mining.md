---
description: >-
  Understanding Arweave mining
---

# 0. Overview

After you have finished [syncing and packing](syncing-and-packing.md) your data, the basic mining process is:

1. Join the network
2. Hash your data
3. Find a solution
4. Build a block
5. Share the block
6. Receive mining rewards

# 1. Join the Network

The first thing your node will do on startup is to join the Arweave network:

1. Node reaches out to its [Trusted Peers](trusted-peers.md) to request the latest blockchain data
2. Validate that data
3. Join and participate in the network by validating the blockchain

Once your node joins the network it will print a message like the following:

{% code overflow="wrap" %}
```
Joined the Arweave network successfully at the block 9oLuJnrq7SwAlodPE1WoZyhCgdqPTL-6AJBKfA7LQeIuDwaE5Z2QMCFmS8Kn-XnO, height 1804183.
```
{% endcode %}

## 1.1 Participating in the Network

All [node types](node-types.md) participate in the network whether they are mining or not. Participating nodes:

1. Receive new blocks, transactions, and chunks from peers and users
2. Validate and either accept or reject those blocks, transactions, and chunks
3. Share valid blocks, transactions, and chunks with peers
4. If there is a fork in the chain, select and advertise the "heaviest" fork

You can read more about the nuances of the Arweave blockchain in [Understanding the Blockchain](blockchain.md).

The most important step for miners is #1 as you always want to be mining ontop of the latest block. If your node falls behind its peers and is unaware of the latest valid blocks, your miner runs the risk of mining valid solutions that don't make it into the main blockchain. These solutions are called "orphans" and they will not provide you with any mining rewards.

## 1.2 Receiving Blocks, Transactions, and Chunks

Your node can receive new blocks and transactions from peers in two ways:

1. Gossip - where a peer pushes a block or transaction to your node
2. Polling - where your node requests the latest blocks, transactions, or chunks from peers

To ensure your node learns about new blocks as soon as possible it is important that both methods are working correctly. 

Note: chunk data is generally only shared via polling.

## 1.2.1 Block and Transaction Gossip

Gossip is a form of communication used in peer-to-peer networks (like Arweave and many blockchains). It works by having each node randomly share information (e.g. blocks and transactions) with a small group of its peers, who then pass it on to their peers. 

In order for your node to participate it needs to be accessible to the internet so that peers can connect with your node and share their blocks.

To check if your node is publicly accessible, browse to `http://[Your Internet IP]:1984`. You can [obtain your public IP here](https://ifconfig.me/), or by running `curl ifconfig.me/ip`. If you specified a different port when starting the miner, replace "1984" anywhere in these instructions with your port. If you can not access the node, you need to set up TCP port forwarding for incoming HTTP requests to your Internet IP address on port 1984 to the selected port on your mining machine. For more details on how to set up port forwarding, consult your ISP or cloud provider.

If the node is not accessible on the Internet, the miner functions but is significantly less efficient.

## 1.2.2 Block and Transaction Polling

As a fallback and to increase the chance that your node receives new blocks and transactions as soon as possible, all nodes will also poll (i.e. make an outbound HTTP request) a random subset of their peers to ask for new blocks.

## 1.2.3 Falling Behind

If you see the following warnings in your console it indicates that your node may have fallen behind and may not have received or validated the latest blocks:

{% code overflow="wrap" %}
```
WARNING: Peer 138.197.232.192 is 5 or more blocks ahead of us. Please, double-check if you are in sync with the network and make sure your CPU computes VDF fast enough or you are connected to a VDF server.
```
{% endcode %}

If you see them shortly after joining the network, see if they disappear in a few minutes - everything might be fine then. Otherwise, it is possible that either your processor can't keep up with node validation or there are network connection issues. Confirm that your network is healthy, that you have a properly configured VDF Server, and that you have spare CPU capacity. Sometimes the issue is short lived and a node restart can help.

# 2. Hash Your Data

Once your miner joins the network it will begin hashing any of its packed data looking for a solution. The Arweave network data (referred to as "the weave") is divided into 3.6TB partitions. 

Note: "storage modules" and "partitions" are often used interchangeably but they are slightly different. Please see [Directory Structure](../setup/directory-structure.md) for the distinction.

The mining loop:

1. Compute a VDF step or receive one from a VDF server
2. Use that VDF step to compute an `H0` value for full or partial partition being mined
3. For each partition, use the `H0` to compute a random byte offset within that partition (i.e. an offset from 0 to 3.6TB)
4. Read the 2.5 MiB of data at each partition's offset to compute a series of `H1` hashes (32 hashes per 256KiB chunk of data read)
5. For each partition, use the `H0` to compute a random byte offset across the entire weave (e.g. an offset from 0 to 373TB as off November 28, 2025)
6. Read the 2.5 MiB of data at each weave offset and use it as well as the corresponding `H1` hashes to compute a series of `H2` hashes (32 hashes per 256KiB chunk of data read)

Each `H1` and `H2` hash is compared against the network difficulty to determine whether it is a "solution". The `H1` and `H2` hashes are weighted differently and most metrics and logs will report an "effective hashrate" that accounts for this weighting rather than simply reporting the number of SHA256 hashes computed. Please see the [Hashrate Guide](hashrate.md) for more information.

Of note, the `H1` and `H2` hashes computed are all SHA256 and therefore are not compute intensive. The `H0` hashes use RandomX and are more compute intensive, but since there is only one `H0` per partition, generally the load is minimal.

# 3. Find a Solution

# 4. Build a Block

# 5. Share the Block

# 6. Receive Mining Rewards

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