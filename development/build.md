---
title: Building Arwaeave
---

# Building Arweave

## 1. Clone the Repo

```sh
git clone --recursive https://github.com/ArweaveTeam/arweave.git
cd arweave
```

## 2. Install Dependencies

### 2.1 Linux Dependencies
- Ubuntu 22 or 24 is recommended
- OpenSSL development headers
- GCC or Clang (GCC 8+ recommended)
- Erlang OTP v26, with OpenSSL support
- GNU Make
- CMake (CMake version > 3.10.0)
- SQLite3 header
- GNU MP
- On some systems you might need to install `libncurses-dev`.


Erlang R26 is now required. Unfortunately, Ubuntu 22.04 and 24.04 do not natively support Erlang R26 and a PPA repository is required. The RabbitMQ Team is maintaining this release for all Ubuntu version:

  ```sh
  # add rabbitmq ppa repository
  sudo add-apt-repository ppa:rabbitmq/rabbitmq-erlang-26
  sudo apt update

  # install required packages
  sudo apt install erlang libssl-dev libgmp-dev libsqlite3-dev make cmake gcc g++
  ```
  

### 2.2 MacOS Dependencies

{% hint style="warning" %}
Syncing, packing, and mining is not supported on MacOS. MacOS has only been validated to run a VDF Server. Refer to the [mining VDF guide](/mining/vdf.md)
for more information on running your own VDF server.
{% endhint %}

  1. Install [Homebrew](https://brew.sh/)
  2. Install dependencies
  ```sh
  brew install gmp erlang@26 cmake pkg-config
  ```
  3. Homebrew may ask you to update your `LDFLAGS` for erlang: don't. You should however
  update your `PATH` as requested.

## 2. Build

The Arweave repo supports several build types, each configured for a different used case. The build types are defined in the [rebar.config](https://github.com/ArweaveTeam/arweave/blob/master/rebar.config)

- `default` / `prod`: configured to run against mainnet. This is the normal build type. `default` and `prod` are aliases for each other.
- `testnet`: configured to run against a separate testnet. Search for `testenet` in the [rebar.config](https://github.com/ArweaveTeam/arweave/blob/master/rebar.config) for more instructions.
- `test`: configured for automated tests. See [Automated Tests](automated-tests.md) for more information.
- `e2e`: configured for the end-to-end tests. See [Automated Tests](automated-tests.md) for more information.
- `localnet`: configurd to launch a new chain from genesis. See [Localnet](localnet.md) for more information.

To build a runnable Arweave binary for given build type:

```sh
./ar-rebar3 BUILDTYPE release
```

e.g.

```sh
./ar-rebar3 default release
./ar-rebar3 prod release
./ar-rebar3 testnet release
```

## 3. Run

For instructions on running arweave see [Running Arweave](/mining/setup/getting-started.md).

## 4. Developer Mode

If you set the environment variable `ARWEAVE_DEV` to any value then Arweave will be automatically recompiled whenever you launch. The built type is `release` and only changed artifacts will be rebuilt. You will get the same behavior if you launch Arweave via `./bin/arweave-dev`.