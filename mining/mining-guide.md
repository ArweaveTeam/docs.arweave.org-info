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

If you would like to see a log of your miner’s activity, you can run **‘make log’** in the Arweave directory in a different terminal. The miner terminal itself is left clear so that you can interact with the system using the console. 

## Staying up to Date

* Join our [Discord](https://discord.gg/3UTNZky) server
* Join our mining [mailing list](https://mailchi.mp/fa68b561fd82/arweavemining)

Once you are successfully mining on the Arweave, you will need to stay up to date with new releases. [Join our mailing list](https://mailchi.mp/fa68b561fd82/arweavemining) to receive emails informing you that a new update has been released, along with the steps you need to take to stay up to speed. Updates that require you to perform an action within a certain time period in order to stay in sync with the network will be labeled ‘\[ACTION REQUIRED\]’. Keep an eye out for these messages, and if possible make sure that you add team@arweave.org to your email provider’s trusted senders list!





