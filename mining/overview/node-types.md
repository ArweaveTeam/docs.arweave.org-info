---
description: >-
  Understanding the different Arweave node types
---

This pages describes the different roles your node can play. Each role can be launched from the same `arweave` application found on the main [github repository](https://github.com/ArweaveTeam/arweave). 

See the [Hardware Guide]](../setup/hardware.md) for guidance on the hardware requirements for each node type, and [Getting Started](../setup/getting-started.md) for next steps in getting your miner setup.

# 1. Solo Miner

A solo miner is a single node that stores and mines all the data associated with a single mining address. It is in contrast to a [Coordinated Miner](#2-coordinated-miner) which involves multiple nodes coordinating to mine all the data associated with a single mining address.

## When it’s a good fit
- You are able to direct attach all your minable storage to a single server
- Your server has enough hardware resources to mine all the data itself
- You want full control over keys and payouts (no pool/coordinator in the middle) (see [Pool Miner](#23-pool-miner) for more information)
- You can run or rent access to a VDF server (see [VDF Server](#24-vdf-server) for more information)

# 2. Coordinated Miner

A coordinated miner is collection of 2 or more nodes that coordinate to mine all the data associated with a single mining address. Every coordinated mining cluster has one exit node and then 1 or more mining nodes. All mining nodes share the same mining address and are configured to mine non-overlapping storage modules.

## When it’s a good fit
- You don't have a single server that is capable of mining all of your data itself
- You do have a collection of servers that altogether are capable of mining all of your data
- You are comfortable with the increased complexity of configuring, operating, and optimizing a cluster of servers (in contrast to running a single Solo Miner)
- You want full control over keys and payouts (no pool/coordinator in the middle) (see [Pool Miner](#23-pool-miner) for more information)
- You can run or rent access to a VDF server (see [VDF Server](#24-vdf-server) for more information)

For more information see [Coordinated Mining](../overview/coordinated-mining.md).

# 3. Pool Miner

A pool miner can either be a solo miner or a coordinated miner. They mine some or all of the data associated with a mining address, and delegate reward accounting, VDF, coordination, and support to a third‑party pool. 

## When it’s a good fit
- You are still comfortable running your own Solo Miner or Coordinated miner
- You want the extra setup and operations support provided by the pool operator
- You don't have enough storage to mine the full weave and want the pool to help you coordinated with another miner to cover the full weave
- You can't run and don't want to rent access to a VDF server and would like to use the one provided by the pool
- You’re happy to share rewards according to pool rules in exchange for smoother payouts
- You’re happy to delegate control of the mining keys to pool operator
  
For more information see [=Pool Mining](../overview/pool-mining.md).

# 4. VDF Server

VDF servers are specialized nodes that focus on computing and distributing VDF steps. They typically do not store data or mine.

## When it's a good fit
- You are also planning to run a miner and want to maximize your mining hashrate without joining a pool or renting access to a 3rd party VDF server
- You have access to a Mac running on Apple Silicon (e.g. an M4) - to date the fastest VDF calculations observed are on Apple processors

For more information see [VDF](../overview/vdf.md).

## 5. Validator

Validators validate and share blocks and transactions with other nodes in the network. They may also, but do not have to, share unpacked data. They typically do not not mine or may mine only incidentally. All Arweave nodes are also validators so if you are running a miner or VDF server you do not also need to run a dedicated validator.

## When it's a good fit
- You want to interact with the Arweave network without relying on a 3rd-party gateway (e.g. to support your own applications)
- You're not already running a miner or VDF servers


