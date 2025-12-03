# Arweave Protocol Components

This document outlines the core architectural components of the Arweave protocol. It is intended for developers and engineers seeking a high-level understanding of how Arweave achieves permanent, decentralized data storage.

## 1. Protocol Design

Arweave is a global network of computers that collectively store multiple copies of all data uploaded to the system. The protocol is designed around two core principles: minimalism (using well-tested cryptographic primitives) and optimization through incentives (incentivizing participants to achieve desirable outcomes rather than prescribing behavior).

The system uses a decentralized consensus mechanism inspired by Proof of Work but adapted for permanent storage. Nodes periodically reach consensus on new data to be added to the network's globally distributed repository. This process involves "mining" (confirming) blocks, which serve the dual purpose of accepting new data and validating the storage of previously uploaded data.

## 2. Cryptographic Proofs of Storage

Arweave uses a succinct cryptographic proof system to verify the even replication and accessibility of data. This system is known as **Succinct Proofs of Random Access (SPoRA)**.

To mine a block, a node must prove it has access to a random chunk of historical data (the "Recall Chunk") that was confirmed as part of an earlier block. The miner hashes the Recall Chunk along with some other cryptographic data and compares the hash against the network difficulty. If the hash is greater than the network difficulty the solution is considered valid. See [Understanding Mining](/mining/overview/mining.md) for more information about the mining process.

Crucially, SPoRA is designed to work in conjunction with the **Verifiable Delay Function (VDF)**. The VDF is a form of cryptographic "speed limit" that limits the number of Recall Chunks tha can be hashed per second. This limit ensures that mining is bottlenecked by the VDF computation time rather than pure data retrieval speed. This shift removes the incentive for expensive, high-speed storage (e.g. NVMe SSDs), allowing miners to use cost-effective commodity hard drives while still mining efficiently.

## 3. Replica Uniqueness

To ensure the network is resilient against data loss, Arweave incentivizes the creation of distinct physical copies of data. This is achieved through **Replica Uniqueness**.

When a miner stores a "partition" (a segment of the weave), the data is packed using the miner's unique mining address as a seed. This packing process creates a unique representation of the data for that specific miner. Because the consensus mechanism requires proving access to this *unique* replica, miners cannot share a single storage volume. If two miners attempt to share a disk, they cannot both efficiently mine on it because the data must be packed specifically for the winning address. This enforces the physical replication of the dataset across the network.

## 4. Verifiable Delay Function (VDF)

The **Verifiable Delay Function (VDF)** helps stabilize the network's block production and mitigate the dominance of raw compute power.

The mining process involves two steps:
1.  **Memory-Hard Search**: Miners search their stored data chunks for a candidate that meets the difficulty criteria.
2.  **VDF Computation**: Once a candidate is found, the miner must compute a VDF.

The VDF enforces a cryptographic "speed limit" that takes a verifiable amount of wall-clock time to compute and cannot be parallelized. This ensures that mining is primarily bound by storage bandwidth (finding the chunk) rather than raw CPU/ASIC hashing speed, allowing commodity hardware to compete effectively.

## 5. The Storage Endowment

Arweave guarantees permanent storage through an economic mechanism known as the **Storage Endowment**.

When a user pays to store a file, the transaction fee is split:
- A portion goes to the miner who accepts the transaction.
- The majority is deposited into the Storage Endowment.

The Endowment is a decentralized pool of tokens designed to cover the cost of storage in perpetuity. It relies on the deflationary nature of storage costs (bytes per dollar increasing over time). The protocol calculates the cost to store data for 200 years at current prices. As storage costs drop, the purchasing power of the endowment covers the maintenance of the data indefinitely. Miners are paid from this endowment when the block reward is insufficient to cover their storage costs.

## 6. Pricing

Transaction pricing in Arweave is dynamic and algorithmic, designed to ensure the endowment is always sufficient. The cost to write data is composed of:
1.  **Perpetual Storage Cost**: Calculated based on the current price of storage space and the required endowment contribution.
2.  **Network Congestion**: A dynamic fee that scales with the demand for block space.

The pricing mechanism is conservative, assuming storage costs will decline at a rate far below the historical average (e.g., 0.5% per year vs. historical ~30%). This surplus creates a significant safety margin for the Endowment. Users pay a one-time, up-front fee that effectively pre-pays for centuries of storage.

## 7. Decentralised Content Policies

The Arweave protocol includes mechanisms that allow the network to support diverse content policies without centralization. **Decentralised Content Policies** empower node operators to choose which data they are willing to store and propagate.

When a transaction is broadcast to the network, nodes scan the data against their local policies (e.g., blacklists of illicit material). If the content violates a node's policy, the node rejects the transaction and will not include it in its memory pool or blocks. If a node receives a block containing a transaction it has rejected, it will ignore that block. This creates a democratic content moderation system where the network collectively "votes" on content through storage behavior. As long as a transaction is accepted by a sufficient portion of the network (the "adaptive interacting majority"), it will be permanently stored, preventing censorship while respecting the legal and ethical boundaries of individual operators.
