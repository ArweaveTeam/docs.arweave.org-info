# Mining FAQs

## Are AR wallets/addresses created automatically for miners, and if so, how do I access them?

Yes, if you do not provide a wallet address on the command line when starting the miner, a new wallet will be created for you and stored in the ‘wallets’ directory. When you run the miner again, you will want to pass the generated wallet address on the command line. Any valid Arweave wallet address will work for mining. For example, you can use a wallet that was generated in the Arweave web extension for mining purposes -- you just need the wallet address. If you want to install the web extension you can do that here: [Chrome](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc), [Firefox](https://addons.mozilla.org/en-US/firefox/addon/arweave/), or [Brave](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc).

## Is my mining address a private key?

Your mining address is **not** a private key - it is a public address. But it is paired with a private key (stored in your `wallets` directory with a name like `arweave_keyfile_MININGADDRESS.json`) which you will need to sign any blocks you mine. When mining, only nodes that will sign blocks need to have a private key / wallet.json stored locally

## Do I have to download & store the whole blockweave to begin mining?

Nope! You don’t have to store the whole weave to mine, there’s no set minimum requirement. However, the more data you store, the more likely you are to receive mining rewards from the network

## How do I see my mining performance?

When you run your miner it will periodically pring a Mining Performance Report to the console. You can read more about the Mining Performance Report [here](https://github.com/ArweaveTeam/arweave/releases/tag/N.2.7.2). If your node is syncing the weave it will display 0 h/s but will go up over time.

You can also use Prometheus and Grafana as described in the [Metrics Guide](metrics.md).

## Can I use multiple hard drives/external auxiliary hard drives to provide more data storage on the network?

Yes, this is possible. In order to build this kind of setup, you will need to set up a cross-disk file system and mount your Arweave directory. You will be able to find tutorials for how to achieve this with your specific OS online

## Can I mine on Windows/MacOS?

At the moment we have a Linux client available, but we will be making mining more accessible on other operating systems in the future. Note that for Windows, it is possible to run the miner inside a Windows Subsystem for Linux environment.

We have not validated mining or packing on MacOS, but as of May, 2024 the M2 provides the fastest known VDF implementation and so makes a good candidate for VDF Servers. See here for instructions on setting up a VDF Server.

## Is there a specific recommendation for Ubuntu version?

We recommend [Ubuntu version 22.04+ ](http://releases.ubuntu.com/22.04/)

## I don’t seem to be receiving new blocks from peers - why is this?

The most likely cause of this issue is that your router is not forwarding messages for port 1984 to your machine. You can address this by configuring port forwarding on your router and ensuring that port 1984 is not blocked by your firewall

## How do I keep the miner running after closing my terminal window?

We recommend starting the miner in a screen session, you can then safely disconnect from the `screen` session and close your terminal with the miner still running

## Can I mine on the Arweave network with a dynamic IP?

Yes - but there are some caveats:

Miners benefit by getting the latest set of blocks and transactions as fast as possible to
limit the time wasted mining against a stale chain tip. Miners can get blocks 2 ways:
  1. By polling their peers for new blocks and transactions
  2. By being notified of new blocks and transactions by other miners

If you have a dynamic IP you may not get notified by your peers as quickly as a miner with
a static IP. However your miner will continue to poll, so the lag will be minimal.

A slightly bigger issue is your "peer reputation". All peers in the network maintain a rating
for all other peers based on past activity. It basically boils down to the amount of valid
data exchanged. As your node sends valid data to peers, your reputation increases. Reputation
is currently tracked by IP:PORT, so whenever your IP changes, your repuation will be reset.

Reputation primarily comes into play when you mine a solution, Peers will process the solutions
of higher reputation peers first. So if you have a low reputation and mine a block at about
the same time as a miner with a higher reputation, there's a greater chance that your block
will be processed later and potentially orphaned.
