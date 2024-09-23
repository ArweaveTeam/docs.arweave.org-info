# Coordinated Mining

**Original Author: @Thaseus**

A guide to operating a coordinated mining cluster

## What is coordinated mining?

Coordinated mining involves multiple servers utilizing the same mining address to discover solutions and mine blocks. In previous versions of Arweave, mining operations were typically conducted by a single server per address. However, as the weave has grown significantly, it often necessitates the collaboration of multiple servers. While powerful high-core Epyc processor-based systems may still operate effectively as a single node, most consumer-level hardware requires a coordinated mining (CM) cluster.

A CM cluster consists of multiple mining nodes and a single exit node. The exit node serves as the gateway through which mining solutions are broadcast to the network and ideally functions as a VDF forwarder. Each CM cluster can include as many regular nodes as needed, but it has only one exit node. This exit node may also participate in mining storage modules.

It is important that *only* the exit node broadcast solutions from your CM cluster (also referred to as "publishing blocks"). If the same mining address publishes 2 blocks at the same height, the protocol will ban that mining address and slash its rewards (this is known as "double signing"). Having a single exit node through which all of your cluster's solutions are broadcast avoids this problem. Additionally, as an extra safeguard, we recommend that the exit node be the only node with your wallet file in the `<data_dir>/wallets` directory. As it is the only node that is able to sign and publish blocks, this can avoid having one of the CM miners accidentally publish a block due to a configuration error.

## CM Basics

All nodes in the cluster share the same mining address. Each Miner generates H1 hashes for the partitions they store. Occasionally they will need an H2 for a packed partition they don't store. In this case, they can find another miner in the coordinated mining cluster who does store the required partition packed with the required address, send them the H1 and ask them to calculate the H2. When a valid solution is found (either one- or two-chunk) the solution is sent to the Exit Node. Since the Exit Node is the sole node in the coordinated mining cluster which publishes blocks, there's no risk of "double signing" causing you address to be banned and your pending rewards slashed. Every node in the coordinated mining cluster will still peer with any other nodes on the network as normal.

## VDF Forwarding

When using Coordinated Mining (CM), it is beneficial to keep your VDF steps relatively synchronized. To achieve this, there is an optional VDF forwarder function that can be utilized. On the CM exit node, you should set the flag `vdf_server_trusted_peer IP:Port` to designate the Team Arweave VDF server or your own server.

In addition to this flag, you must specify each peer to which you wish to send VDF steps by using the `vdf_client_peer IP:Port` flag for each client server. While employing this feature is not strictly required, it significantly enhances the stability of your systems.
On the client servers, you would use the `vdf_server_trusted_peer <Exit Node IP>:<port>` flag to specify the IP:Port of your VDF forwarder.

## Coordinated Mining Start Flags

- `coordinated_mining`:  Enables coordinated mining mode
- `local_peer IP:Port`: Registers a node as a local peer which disables rate limiting
  - While this is not specifically a CM command, it corrects an edge case which may cause rate limiting between CM cluster membe. This is useful for all nodes you operate
- `cm_peer IP:Port`:  Registers a node as a CM peer and allow sharing H1 and H2 hashes between them
  - Each peer will have to include this flag for each other node in the cluster
- `cm_api_secret your_secret_12_char_string`: This is the password for your CM cluster, each node must have the same password
- `cm_exit_peer IP:Port`: This flag must be included on all nodes except for the exit peer
  - When this flag is included, it directs all solutions to be sent to this exit node
  - When this flag is not included, that single node will be responsible for publishing blocks
- `cm_out_batch_timeout 10`: This is the only optional cm flag
  - Frequency in ms that a node will send out H1 hashes to the CM peers
  - Default is 20ms
  - A higher value will result in less network usage, but higher hash latency
  - A lower value will result in more network usage, but lower hash latency
- `mining_addr <your_mining_address>`: All nodes in the CM cluster must have the same mining address
- `vdf_server_trusted_peer IP:Port`: This flag can be used in two ways
  - On the exit node to connect to an external VDF server, such as the Arweave team VDF servers
  - On the CM client nodes to connect to either the VDF forwarder, or a dedicated internal VDF server
  - This flag is used to connect to external VDF servers to receive their VDF steps
- `vdf_client_peer IP:Port`: 
  - This flag must only be included on the exit node or a designated internal VDF server
  - This flag tells the exit node / VDF forwarder to send the VDF steps that it received (or generated) to the clients listed by IP:Port

## Example CM Cluster

- `10.0.0.100:1984`: CM Exit Node / VDF Forwarder
- `10.0.0.101:1985`: CM Miner 1
- `10.0.0.102:1986`: CM Miner 2

### CM Miner 1
```
mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
coordinated_mining \
local_peer 10.0.0.100:1984 \
local_peer 10.0.0.102:1986 \
cm_peer 10.0.0.100:1984 \
cm_peer 10.0.0.102:1986 \
cm_api_secret arweave_is_great_right \
cm_exit_peer 10.0.0.100:1984  \
vdf_server_trusted_peer 10.0.0.100:1984
```

### CM Miner 2
```
mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
coordinated_mining \
local_peer 10.0.0.100:1984 \
local_peer 10.0.0.101:1985 \
cm_peer 10.0.0.100:1984 \
cm_peer 10.0.0.101:1985 \
cm_api_secret arweave_is_great_right \
cm_exit_peer 10.0.0.100:1984  \
vdf_server_trusted_peer 10.0.0.100:1984
```

### CM Exit Node
```
mining_addr En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI \
coordinated_mining \
local_peer 10.0.0.100:1984 \
local_peer 10.0.0.101:1985 \
cm_peer 10.0.0.100:1984 \
cm_peer 10.0.0.101:1985 \
cm_api_secret arweave_is_great_right \
vdf_server_trusted_peer vdf-server-3.arweave.xyz \
vdf_server_trusted_peer vdf-server-4.arweave.xyz \
vdf_client_peer 10.0.0.101:1985
vdf_client_peer 10.0.0.102:1986
```

## Troubleshooting

Coordinated mining operates effectively when all suggested flags above are used. This ensures your nodes remain synchronized and operational. Typically, the only reported errors are connectivity issues and discrepancies in the "Hash (Ideal)" values on the mining screens.

The output screen below displays your CM statistics. The values will scale with the number of partitions each node is mining. If you observe zeros in any column (other than H2 in/out), it indicates an improper connection between your nodes. This could be due to a network issue or a misconfiguration in the start command.

Ensure that you use a single source for your network connection, either WiFi or wired. Using both may result in receiving data on a different IP than configured, leading to communication errors. Ensure that all ports are forwarded as required to ensure external arweave nodes can connect to your cluster nodes.

```
Coordinated mining cluster stats:
+-----------------+--------------+--------------+--------------+-------------+--------+-------+
|      Peer       | H1 Out (Cur) | H1 Out (Avg) |  H1 In (Cur) | H1 In (Avg) | H2 Out | H2 In | 
+-----------------+--------------+--------------+--------------+-------------+--------+-------+
|             All | 	3714 h/s | 	   3733 h/s |	  3419 h/s |    3390 h/s |      0 |  	0 |
| 10.0.0.100:1984 |      602 h/s |  	611 h/s | 	   559 h/s |     489 h/s |      0 |  	0 |
| 10.0.0.102:1986 | 	1736 h/s | 	   1606 h/s |	  1523 h/s |    1503 h/s |      0 |  	0 |
+-----------------+--------------+--------------+--------------+-------------+--------+-------+
```


For more information see:

- [Arweave 2.7.2 Coordinated Mining Details](https://github.com/ArweaveTeam/arweave/releases/tag/N.2.7.2)
- [Arweave 2.7.3 Coordinated Mining Details](https://github.com/ArweaveTeam/arweave/releases/tag/N.2.7.3)


