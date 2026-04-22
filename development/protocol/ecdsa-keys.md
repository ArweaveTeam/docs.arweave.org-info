# ECDSA Accounts

Arweave supports ECDSA secp256k1 signing keys for blocks and transactions.

ECDSA support was activated at [the 2.9 hard fork](https://github.com/ArweaveTeam/arweave/releases/tag/N.2.9.1).

The key differences between RSA and ECDSA transactions are:

* An ECDSA account can only sign a format=2 transaction.
* The `owner` field must be empty for ECDSA txs.
* The signature preimage is constructed slightly differently - the `owner` is omitted from the recursively hashed list.
* The signature must be a 65-byte **compact recoverable signature** (64 bytes of `r || s` followed by a 1-byte recovery id). The protocol recovers the public key from the signature before validating it.

{% hint style="warning" %}
**Arweave ECDSA addresses are not compatible with Ethereum addresses.**
Although Ethereum uses secp256k1 too, its public-key-to-address scheme is
different (Keccak-256 of the uncompressed public key, truncated to 20
bytes). Arweave uses the same encoding for RSA and ECDSA accounts: every
address is the SHA-256 hash of the public key.

**If you transfer AR to an Ethereum address on Arweave, you will lose the funds.**
{% endhint %}

ECDSA transactions can be used for transferring tokens and uploading data, just like RSA txs.

There is no account delegation mechanism in Arweave.

## Signing and verifying with arweave-js

Native ECDSA support is currently available in `arweave-js` in [a dedicated branch](https://github.com/ArweaveTeam/arweave-js/tree/master-ec).

It is published under the `ec` npm tag:

```bash
npm install arweave@ec
```

You can see how to create and use ECDSA wallets [in the library docs](https://github.com/ArweaveTeam/arweave-js/tree/master-ec#create-wallets-200).

## Mining with ECDSA

Miners can use either RSA or ECDSA keys. ECDSA reward keys produce 65-byte block signatures, much shorter than RSA's 512-byte signatures.

To create a new ECDSA mining wallet, use the `wallet create` subcommand of the Arweave node:

```bash
./bin/arweave wallet create ecdsa [data-dir]
```

Use `rsa` instead of `ecdsa` to create an RSA wallet.

The new keyfile is written to the `wallets/` subdirectory of the node's data directory (`data_dir`), as a standard JWK JSON file named after the resulting Arweave address. On startup, the node automatically picks up keyfiles from `wallets/` and detects the key type from the JWK; no extra configuration is needed to mine with ECDSA.
