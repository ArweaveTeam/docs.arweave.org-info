# Requirements

For any questions not answered in these documents please visit our [Github Discussions](https://github.com/ArweaveTeam/arweave/discussions)

## Linux Dependencies
- Ubuntu 22 or 24 is recommended
- OpenSSL development headers
- GCC or Clang (GCC 8+ recommended)
- Erlang OTP v26, with OpenSSL support
- GNU Make
- CMake (CMake version > 3.10.0)
- SQLite3 header
- GNU MP

Erlang R26 is now required. Unfortunately, Ubuntu 22.04 does not natively support Erlang R26 and a PPA repository is required. The RabbitMQ Team is maintaining this release for all Ubuntu version:

  ```sh
  # add rabbitmq ppa repository
  sudo add-apt-repository ppa:rabbitmq/rabbitmq-erlang-26
  sudo apt update

  # install required packages
  sudo apt install erlang libssl-dev libgmp-dev libsqlite3-dev make cmake gcc g++
  ```

  On some systems you might need to install `libncurses-dev`.

## MacOS Dependencies

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


## Clone the repo

```sh
$ git clone --recursive https://github.com/ArweaveTeam/arweave.git
$ cd arweave
```

## Configure your system

- [Linux miner](/mining/mining-guide.md#preparation)
- [MacOS VDF server](/mining/vdf.md)

## Run the automated tests

- [Automated tests](automated-tests.md)

## Run your node

- [Linux miner](/mining/mining-quickstart.md)
- [MacOS VDF server](/mining/vdf.md)
