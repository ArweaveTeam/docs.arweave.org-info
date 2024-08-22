# Running Multiple Nodes on a Single Server

**Original Author: @Thaseus**

A guide to running more than one Arweave node on the same server

## Why would you need to run more than one node?

When using Arweave for a single function such as packing or mining, the setup is straightforward: a single node performs a single function with the available resources. However, what if you have additional capacity on your server and wish to perform more tasks? For instance, you may want to mine storage modules while also syncing/packing the tip partition that isn't yet minable. Another use is to have your exit node/VDF forwarder separate from your miner node on the same server. While this setup is not mandatory, it provides the flexibility to segregate your miner node from your exit node on the same server if desired.

## Things to know about running more than one node

The primary consideration when running more than one node on a single server is the finite nature of your resources. For instance, if you are mining 16 partitions and have 50% CPU capacity remaining, you can allocate resources to pack the tip partition or other partitions that are not yet packed. However, it is crucial to adjust the packing speed to ensure that your CPU does not reach peak capacity, which could negatively impact your mining performance. 

## How to run more than one node per server

1. Give each node a unique Erlang Node Name
    1. For each node copy the `./arweave/bin/arweave.env` file
    2. Change `export NODE_NAME='arweave@127.0.0.1'` to a unique name, for example `export NODE_NAME='arweave2@127.0.0.1'`
2. Have each node load its own `arweave.env` file
    1. For each node copy the `./arweave/bin/start` and `./arweave/bin/stop` files
    2. Have each script source the appropriate `arweave.env` file, for example `source $SCRIPT_DIR/arweave2.env`
3. Update your start command flags as necessary (e.g. to have each node use a different port)

