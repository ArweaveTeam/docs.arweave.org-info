---
description: >-
  A guide to running more than one Arweave node on the same server
---

**Adapted from a guide originally written by @Thaseus**

# 1. Why would you need to run more than one node on a server?

In most cases miners will run a single node per server. However it is possible, and sometimes beneficial, to run multiple nodes on a single server. Some examples:
- mine storage modules while also syncing/packing the tip partition that isn't yet minable
- run both your exit node and a miner on the same server
- use both CPUs in a dual-CPU server without getting hit by [known performance issues](../setup/hardware.md#344-dual-cpu-motherboards) 

# 2. How to run more than one node on n server

Each node on a server needs a unique:
- `data_dir`
- `port`
- [Erlang node name](https://www.erlang.org/doc/system/distributed.html#nodes)
  - Can be set via the `ARNODE` environment variable
- [Erlang cookie](https://www.erlang.org/doc/system/distributed.html#security)
  - Can be set via the `ARCOOKIE` environment

You can set the environment variables for the session, but easiest is probably set them just for each node invocation. Here is an example launching 2 nodes (each one running in the background):

```sh
ARNODE=node1@127.0.0.1 \
ARCOOKIE=node1 \
./bin/start port 1984 data_dir /opt/data/node1 &

ARNODE=node2@127.0.0.1 \
ARCOOKIE=node2 \
./bin/start port 1985 data_dir /opt/data/node2 &
```

{% hint style="info" %}
In practice you will need to provide more launch options if you want the node to do something useful. See [Running Your Node](../setup/configuration.md) for more information.
{% endhint %}

{% hint style="info" %}
Running a node in the background using the linux `&` isn't recommended (and just shown here for simplicity). [We recommend](../setup/configuration.md#02-keeping-the-miner-running) using `screen` or some other more sophisticated process manager.
{% endhint %}

# 3. Pinning your node to certain cores

When running multiple nodes on single server we recommend pinning each node to a distinct set of CPU cores. This is useful for working around the dual-CPU performance issue mentioned above, but is also useful in single-CPU systems to keep the node workloads separate and avoid bottlenecking.

You can use any pinning utility you're comfortable with (e.g. `taskset`, `numactl`, etc...).

An example extending the above example to use `screen` and `numactl`, to both run the nodes in the background and pin them to a different set of cores (0-31 vs. 32-63 on a 64-core CPU):

```sh
ARNODE=node1@127.0.0.1 \
ARCOOKIE=node1 \
screen -dmSL arweave.node1 -Logfile ./screenlog.node1 \
    numactl --physcpubind=0-31 \
    ./bin/start port 1984 data_dir /opt/data/node1;
ARNODE=node2@127.0.0.1 \
ARCOOKIE=node2 \
creen -dmSL arweave.node2 -Logfile ./screenlog.node2 \
    numactl --physcpubind=32-63 \
    ./bin/start port 1985 data_dir /opt/data/node2;
```