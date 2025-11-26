---
title: Node Wallet
---

The node wallet (aka mining key) provides a miner with their:
- **mining address**: where mining rewards are sent
- **packing address**: used to prepare data for mining (same as mining address)
- **signing key**: private key used to sign blocks when a mining solution is found

For more information on how mining works see: [How Mining Works](../overview/mining.md)

{% hint style="warning" %}
If you lose your node wallet you will not be able to access your mining rewards or sign new blocks. We strongly recommend you backup your node wallet.
{% endhint %}

The node wallet is stored in `[data_dir]/wallets` and is required for all [node types](../overview/node-types.md). If one is not present when the node first launches, it will be automatically created. If you're not running a miner it is probably fine to rely on this automatically created wallet. For miners, however, we recommend creating or importing your wallet explicitly.

You can create a wallet with the provided `wallet` tool:

```sh
./bin/arweave wallet create rsa [data_dir]
```

This script will create the wallet and place it in the `[data_dir]/wallets` directory. See [Directory Structure](directory-structure.md) for more information on setting your `data_dir`.

If you want to use an existing wallet, place it in `[data_dir]/wallets`. Imported wallets must in .json format and be named `arweave_keyfile_ADDRESS.json` where `ADDRESS` is the address associated with the wallet.

Note: when using [coordinated mining](coordinated-mining.md), the wallet only needs to be present on the exit node.

{% hint style="warning" %}
Make sure to never share you wallet with anyone.
{% endhint %}
