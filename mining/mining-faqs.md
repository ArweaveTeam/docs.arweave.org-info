# Mining FAQs

## Are AR wallets/addresses created automatically for miners, and if so, how do I access them?

Yes, if you do not provide a wallet address on the command line when starting the miner, a new wallet will be created for you and stored in the ‘wallets’ directory. When you run the miner again, you will want to pass the generated wallet address on the command line. Any valid Arweave wallet address will work for mining. For example, you can use a wallet that was generated in the Arweave web extension for mining purposes -- you just need the wallet address. If you want to install the web extension you can do that here: [Chrome](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc), [Firefox](https://addons.mozilla.org/en-US/firefox/addon/arweave/), or [Brave](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc).

## **Do I have to download & store the whole blockweave to begin mining?**

Nope! You don’t have to store the whole weave to mine, there’s no set minimum requirement. However, the more blocks of the blockweave that you store, the more likely you are to receive mining rewards from the network

## **How do I measure my mining performance?**

You can run **./arweave-server** benchmark to calculate your per core hashing rate. By default, the Arweave server will start one less than the number of cores you have in your machine \(in order for it to stay responsive during mining\)

## **How do I see if I've mined a block?**

Luckily for you, we’ve created a neat infographic to show you how the mining process works. You can find that on the 'Mining Reward Factors' page. There are three key phases to mining on the Arweave: First you need to store the recall block. Once you have this, you can begin hashing. The second phase is mining the candidate block. The third and final phase: the mined block will be submitted to the network and the network will then decide whether or not to accept this

## **Can I use multiple hard drives/external auxiliary hard drives to provide more data storage on the network?**

Yes, this is possible. In order to build this kind of setup, you will need to set up a cross-disk file system and mount this in the ‘blocks’ subdirectory of your Arweave installation. You will be able to find tutorials for how to achieve this with your specific OS online

## **Can I mine on Windows/MacOS?**

At the moment we have a Linux client available, but we will be making mining more accessible on other operating systems in the future. Note that for Windows, it is possible to run the miner inside a Windows Subsystem for Linux environment

## **Is there a specific recommendation for Ubuntu version?**

We recommend [Ubuntu version 18.04+ ](http://releases.ubuntu.com/18.04/)

## **I don’t seem to be receiving new blocks from peers - why is this?**

The most likely cause of this issue is that your router is not forwarding messages for port 1984 to your machine. You can address this by configuring port forwarding on your router and ensuring that port 1984 is not blocked by your firewall

## **How do I keep the miner running after closing my terminal window?**

We recommend starting the miner in a screen session, you can then safely disconnect from the screen session and close your terminal with the miner still running

## **Can I mine on the Arweave network with a dynamic IP?**

Though it’s possible to do so with a dynamic IP, this is very inefficient, so we strongly recommend a static IP. However if you are using a dynamic IP, make sure you’re operating in ‘polling mode’

