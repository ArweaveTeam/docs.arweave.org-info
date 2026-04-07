# Arweave Protocol Components

This document outlines the core architectural components of the Arweave protocol. It is intended for developers and engineers seeking a high-level understanding of how Arweave achieves permanent, decentralized data storage.

## 1. Protocol Design

Arweave is a global network of computers that collectively store multiple copies of all data uploaded to the system.

One of the core tasks of the protocol is to define incentives for storage providers (miners) such that the emergent network behavior meets the following objectives:

- miners allocate the majority of their budget to storage mediums with read throughput of about 5 MB/s and reasonable latency; beyond that, the price should matter more than the drive specs. This also implies it is not beneficial to exchange some of that storage for extra computation;
- miners fill up their allocated drive space with Arweave data evenly (contrasted with replicating the same subset over and over again);
- miners do not accept new data into the Arweave dataset unless the fees cover storage of a sufficient number of replicas so that incidental data loss is extremely improbable over time.

The protocol is designed around two core principles: minimalism (using well-tested cryptographic primitives) and optimization through incentives (incentivizing participants to achieve desirable outcomes rather than prescribing behavior).

To achieve that, the system uses a decentralized consensus mechanism inspired by Proof of Work but adapted for permanent storage. Nodes periodically reach consensus on new data to be added to the ever-growing Arweave dataset (or simply, weave).

Arweave is a blockchain - every state transition is defined by a block (often called a confirmation). Every block serves the dual purpose of accepting new data (in addition to account updates, like in any other cryptocurrency) and validating the storage of previously uploaded data.

## 2. Cryptographic Proofs of Storage

Arweave uses a succinct cryptographic proof system to verify the even replication and accessibility of data. This system is known as Succinct Proofs of Random Access (SPoRA).

To mine a block, a node must prove it has access to historical data. A naive approach would be to require every miner to include all of their data in the block and distribute it across the network to prove it to everyone they actually store this data. The obvious downside of this naive approach is the requirement for huge communication bandwidth.

To address this, we rely on a certain generation-verification asymmetry where we require every block to include only one or two 256 KiB chunks (called "Recall Chunks"). These, however, are picked up randomly (pseudorandomly, to be precise, as the protocol has to be deterministic) from all historical data (every miner always works with whatever data they have synced, but benefits from replicating as much data as possible, evenly).

The miner iterates over the Recall Chunks picked out by the protocol, combines them with some metadata, computes the cryptographic hash of the combined data, and compares the hash with the current network difficulty. If the hash is greater than the network difficulty, the solution is considered valid. See [Understanding Mining](/mining/overview/mining.md) for more information about the mining process.

## 3. Verifiable Delay Function

Crucially, SPoRA is designed to work in conjunction with the Verifiable Delay Function (VDF). The VDF is a form of cryptographic "speed limit" that limits the number of Recall Chunks that can be considered per second. This limit ensures that mining is bottlenecked by storage volumes rather than pure data retrieval speed. This shift removes the incentive for expensive, high-speed storage (e.g., NVMe SSDs), allowing miners to use cost-effective commodity hard drives while still mining efficiently.

## 4. Replica Uniqueness

To ensure the network is resilient against data loss, Arweave incentivizes the creation of distinct physical copies of data. 

The weave is broken down into 3.6 TB segments called "partitions." Every partition is packed using the miner's unique mining address as a seed. This packing process creates a unique representation of the data for that specific miner, and only that specific miner receives a reward from mining with recall chunks from this packed partition.

## 5. The Storage Endowment

Arweave's incentive model requires uploaders of data to pay a small transaction placement fee and provide an upfront contribution, denominated in AR, to the network's storage endowment. This endowment serves as a faucet through which miners are paid out over time, as they collectively provide proofs of replication of the dataset. The necessary payout from the endowment to maintain a piece of data decreases as the cost of storage declines.

## 6. Pricing

The Arweave protocol determines the minimum required fee every transaction should pay at any given time.

Even if a transaction does not upload data (i.e., it only transfers tokens), it is considered a small burden to the network and has to pay a small fee to cover that.

When a transfer is made to an account that does not yet exist in the state, a "new account fee" is charged, as every new account increases the block processing overhead.

If a transaction does upload data, the required upload fee scales with the uploaded volume.

A part of the fee goes directly to the miner including this transaction into a block. Its purpose is to incentivize miners to enlarge the Arweave dataset.

The rest of the fee goes to the endowment.

The Arweave network's endowment removes tokens from circulation every time data is uploaded, creating a reserve to
pay for data storage over time. The storage purchasing power of the endowment is elastic, changing with the volume of data committed, the cost of data storage, and token value over time. One of the main drivers of change in the value of the endowment is that a decreasing cost of storage creates a corresponding proportional increase in storage purchasing power, leading to fewer tokens needing to be released from the endowment in the future. We call the rate of decline in overall costs for storing a unit of data for a fixed period of time the Kryder+ rate. This rate incorporates the change in price of hardware, electricity, and operational costs surrounding data storage.

Users pay for 200 years' worth of replicated storage at present prices, such that only a 0.5% Kryder+ rate is sufficient to sustain the endowment for an indefinite term, in the absence of token price changes. Under these conditions, the storage purchasing power of the endowment at the end of each year would be equal to that at the beginning. The actual declining cost of storage over the last 50 years has been, on average, ≈38.5% per year.

To determine how much a single byte costs in AR at any given time, the protocol uses the current network difficulty (as an oracle of the total amount of mining resources currently maintaining the network) and the recent history of operations.

## 7. Decentralized Content Policies

By not enforcing individual miners to store specific data, the Arweave protocol allows the network to support diverse content policies without centralization.

The Arweave network thus employs a disintermediated, layered system of content policies without centralized points of control or moderation. The underlying principle of this system is voluntarism: every participant is able to choose what data they would like to store and serve, without any mandates from the protocol. This system allows each participant in the network to create and operate their own content policy without requiring consensus from others.

The Arweave node software provides a blacklisting system. Each node accepts an optional blacklist containing the identifiers of transactions with unwanted data. The node operator may either maintain a list themselves or subscribe to a service where the node will periodically fetch updates from remote servers.
