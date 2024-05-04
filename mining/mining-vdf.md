---
description: >-
  A guide to running a VDF Server.
---

# What is VDF?

The VDF (Verifiable Delay Function) controls the speed of mining with new mining "seeds" available at roughly 1 second intervals. To keep up with the network your CPU must be able to maintain this 1 second cadence while calculating the VDF. For that the CPU needs to support [hardware SHA2 acceleration](https://en.wikipedia.org/wiki/Intel_SHA_extensions). Additional cores will not improve VDF performance as VDF hash calculations are sequential and therefore limited to a single thread on a single core.

The node will report its VDF performance on startup, warning you if it is too low. You can also run `./bin/benchmark-vdf` to print your system's VDF performance.

{% hint style="info" %}
As of May 2024 the fastest VDF calculations observed are on the Apple M2 processor. Packing and mining are not supported on MacOS, but running a node as a VDF server is possible if you build from source. For instructions on building from source see [Building from source](https://github.com/ArweaveTeam/arweave#building-from-source).
{% endhint %}

## VDF Difficulty

The network VDF difficulty adjusts daily to target an average VDF time of 1 second across all mined blocks. For ease of comparison the VDF performance printed on startup and from the `./bin/benchmark-vdf` assumes a fixed difficulty of `600,000`. You can expect your actual VDF performance when connected to the network to be lower than the benchmark.

For context the current VDF difficulty is `685,976` _(May 2024, block height 1417119)_. So with a benchmark VDF of 1 second you can expect a network performance of 1.14 seconds (`1 second * (685,976 / 600,000)`).

# VDF Servers

Since VDF is so important to mining performance you may have another machine compute VDF for you. For instance, you may set up a dedicated VDF node broadcasting VDF outputs to all your mining nodes.

Running a node fetching VDF states from a peer (aka a "VDF client"):

```
./bin/start vdf_server_trusted_peer IP-ADDRESS ...
```

Running a node pushing its VDF outputs to other peers (aka a "VDF server"):

```
./bin/start vdf_client_peer IP-ADDRESS-1 vdf_client_peer IP-ADDRESS-2 ...
```

Make sure to specify \[IP-ADDRESS]:\[PORT] if your node is configured to listen on a TCP port other than 1984.

In all cases `IP-ADDRESS` can also be a resolvable domain name.

For an example invocation see [Mining Examples](https://docs.arweave.org/developers/mining/mining-examples#running-a-vdf-server).

{% hint style="warning" %}
Do not connect to an external peer you do not trust.&#x20;
{% endhint %}

{% hint style="info" %}
Make sure every client node is reachable from its VDF servers - they are in the same network or the node has a public IP and the port (the default is 1984) is forwarded if there are firewalls. If the node is launched with the mine flag and showing no mining performance reports, it is likely no input comes from the VDF server(s).
{% endhint %}

{% hint style="info" %}
Please, reach out to us via team@arweave.org if you would like to use our team's VDF servers.
{% endhint %}