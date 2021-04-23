# Mining FAQs

## Are AR wallets/addresses created automatically for miners, and if so, how do I access them?

Yes, if you do not provide a wallet address on the command line when starting the miner, a new wallet will be created for you and stored in the ‘wallets’ directory. When you run the miner again, you will want to pass the generated wallet address on the command line. Any valid Arweave wallet address will work for mining. For example, you can use a wallet that was generated in the Arweave web extension for mining purposes -- you just need the wallet address. If you want to install the web extension you can do that here: [Chrome](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc), [Firefox](https://addons.mozilla.org/en-US/firefox/addon/arweave/), or [Brave](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc).

## **Do I have to download & store the whole blockweave to begin mining?**

Nope! You don’t have to store the whole weave to mine, there’s no set minimum requirement. However, the more data you store, the more likely you are to receive mining rewards from the network

## **How do I see my mining performance?**

When you run **./bin/start**  you will see your miners **H/S** in the logs as you running your node. If your node is syncing the weave it will display 0 h/s but will go up over time.  



## What do \[Stage X/3\] in the logs mean?“ 

There are three key phases to mining on the Arweave:

First stage is the node started the mining process to produce a block. Once the miner produced the candidate block, it goes into the second phase and sends the block out to the network . The third and final phase: the mined block will be submitted to the network, and the network will then decide whether or not to accept this.

```text
# Log output example  

2021-03-19T [info] [Stage 1/3] Starting to hash
2021-03-19T [info] [Stage 2/3] Produced candidate block <hash> and dispatched to network.
2021-03-19T [info] [Stage 3/3] Your block <hash> was accepted by the network!
```

 



## **Can I use multiple hard drives/external auxiliary hard drives to provide more data storage on the network?**

Yes, this is possible. In order to build this kind of setup, you will need to set up a cross-disk file system and mount your Arweave directory. You will be able to find tutorials for how to achieve this with your specific OS online

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

