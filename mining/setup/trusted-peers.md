---
description: >-
  Understanding Trusted Peers
---

When your node first connects to the network it does so through a set of "trusted peers". These are nodes that you specify using the `peer` flag. Your node queries its trusted peers for the recent blockchain data. It's important to only specify nodes you trust, but since your node will validate the data it receives from these peers the potential for abuse is minimal.

If you operate multiple nodes yourself you can have your own nodes specify each other as trusted peers. Although it's important to also include some external nodes as well in case all of your nodes go offline at once.

The Digital History Association operates a set of nodes that can be used as trusted peers:

| **type** |             **region** |                              **hostname** | **notes** |
| -------- | ---------------------- | ----------------------------------------- | --------- |
| dns pool |              worldwide |                       `peers.arweave.xyz` | global dns pool containing all trusted peers
| dns pool |                   asia |                  `asia.peers.arweave.xyz` | -
| dns pool |                 europe |                `europe.peers.arweave.xyz` | -
| dns pool |                  india |                 `india.peers.arweave.xyz` | -
| dns pool |          north-america |         `north-america.peers.arweave.xyz` | -
| dns pool |                oceania |               `oceania.peers.arweave.xyz` | -
| hostname |   europe (netherlands) |             `ams-1.nl.europe.arweave.xyz` | -
| hostname |    north-america (usa) |      `bhs-1.ca.north-america.arweave.xyz` | -
| hostname |    north-america (usa) | `dal-1.east.us.north-america.arweave.xyz` | -
| hostname |    north-america (usa) | `den-1.west.us.north-america.arweave.xyz` | -
| hostname |            europe (uk) |             `eri-1.uk.europe.arweave.xyz` | aka `ams-1.eu-central-1.arweave.xyz`
| hostname |       europe (germany) |             `fsn-1.de.europe.arweave.xyz` | aka `fsn-1.de.europe.arweave.xyz`
| hostname |    north-america (usa) | `hil-1.west.us.north-america.arweave.xyz` | aka `sfo-1.na-west-1.arweave.xyz`
| hostname |       europe (germany) |             `lim-1.de.europe.arweave.xyz` | -
| hostname |         europe (spain) |             `mad-1.es.europe.arweave.xyz` | -
| hostname |          india (india) |              `mum-1.in.india.arweave.xyz` | aka `blr-1.ap-central-1.arweave.xyz`
| hostname |          india (india) |              `mum-2.in.india.arweave.xyz` | -
| hostname |    north-america (usa) | `pho-1.east.us.north-america.arweave.xyz` | -
| hostname |       asia (singapore) |               `sin-1.sg.asia.arweave.xyz` | -
| hostname |       asia (singapore) |               `sin-2.sg.asia.arweave.xyz` | aka `sgp-1.ap-central-2.arweave.xyz`
| hostname |       asia (singapore) |               `sin-3.sg.asia.arweave.xyz` | -
| hostname |    oceania (australia) |            `syd-1.au.oceania.arweave.xyz` | -
| hostname |    oceania (australia) |            `syd-2.au.oceania.arweave.xyz` | -
| hostname | north-america (canada) |      `van-1.ca.north-america.arweave.xyz` | -
| hostname |    north-america (usa) | `vin-1.east.us.north-america.arweave.xyz` | -
| hostname |   europe (switzerland) |             `zur-1.ch.europe.arweave.xyz` | -

Status of dns pools and individual peers can be checked at [status.arweave.xyz](https://status.arweave.xyz/).