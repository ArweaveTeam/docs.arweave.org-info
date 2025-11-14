# The Vision

Imagine a world where information cannot be lost, censored, or controlled by any single entity. Where creators truly own their content, developers build on a shared data commons, and human knowledge is preserved for generations to come. This is the mission of Arweave — permanent, decentralized data storage that can serve as the foundation for an open internet.

The Arweave promise: pay once, store forever, own it permanently.

# The Ecosystem

The Arweave ecosystem is broader than the base network — it includes gateways (that offer indexing, search, seeding, caching), bundlers (scale uploads), and compute layers like [AO](https://ao.arweave.net/). The Arweave node is a fundamental building block that provides permanence and consensus, while adjacent services provide distribution, discovery, and higher-level UX.

Responsibilities of an Arweave node:

- Cold storage of the ever-growing dataset: persist the blockweave data and indexes; verify and prove access to data over time; prioritize durability and verifiability over raw throughput.
- Estimation of fair upload prices, mining rewards, and endowment contributions: compute a price per GiB-minute, quote upload fees via the HTTP API, split fees between miners and the endowment, and account for storage burden relative to base rewards.
- Accepting and distributing transactions: validate, gossip, and include transactions that transfer tokens and/or upload data; maintain a mempool and participate in block production.
- Optional content policies: operators may subscribe to policy lists or enforce local rules to filter what their node serves in order to meet local regulations. These choices affect serving behavior but do not alter global permanence or consensus.

Responsibilities the Arweave node does **not** take on:

- Data sharing at CDN scale: miners are rewarded for storage, not bandwidth. High-bandwidth distribution is provided by gateways and third-party services.
- Data seeding: the initial spreading of newly uploaded data is the client/uploader’s responsibility. Clients may choose to use a gateway or seed to multiple miners until they believe data is durably replicated.
- Bundling large volumes of data together: packaging many small items into shared on-chain transactions to amortize base costs is performed by external bundling services/tooling, not by the core node.
