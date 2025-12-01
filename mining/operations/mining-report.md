---
description: >-
  Understanding the Mining performance Report
---

# 1. The Mining Performance Report

Every 10 seconds a miner will print a report like the following to the console:


```
================================================= Mining Performance Report =================================================

VDF Speed:        1.00 s
H1 Solutions:     0
H2 Solutions:     0
Confirmed Blocks: 0

Local mining stats:
+-----------+-----------+----------+---------------+---------------+---------------+------------+------------+--------------+
| Partition | Data Size | % of Max |   Read (Cur)  |   Read (Avg)  |  Read (Ideal) | Hash (Cur) | Hash (Avg) | Hash (Ideal) |
+-----------+-----------+----------+---------------+---------------+---------------+------------+------------+--------------+
|     Total |  21.5 TiB |      6 % |    17.5 MiB/s |    17.7 MiB/s |    17.5 MiB/s |    146 h/s |    200 h/s |      192 h/s |
|        28 |   3.2 TiB |     98 % |     2.2 MiB/s |     2.6 MiB/s |     2.6 MiB/s |      3 h/s |     32 h/s |       28 h/s |
|        29 |   3.2 TiB |     97 % |     2.7 MiB/s |     2.6 MiB/s |     2.6 MiB/s |     43 h/s |     21 h/s |       28 h/s |
|        30 |   1.9 TiB |     58 % |     1.4 MiB/s |     1.7 MiB/s |     1.5 MiB/s |      2 h/s |     17 h/s |       17 h/s |
|        31 |   2.0 TiB |     61 % |     1.3 MiB/s |     1.7 MiB/s |     1.6 MiB/s |      2 h/s |     29 h/s |       18 h/s |
|        32 |   2.1 TiB |     64 % |     2.3 MiB/s |     1.6 MiB/s |     1.7 MiB/s |      3 h/s |     11 h/s |       18 h/s |
|        33 |   2.8 TiB |     84 % |     2.4 MiB/s |     2.2 MiB/s |     2.2 MiB/s |     43 h/s |     21 h/s |       24 h/s |
|        34 |   3.2 TiB |     96 % |     2.7 MiB/s |     2.7 MiB/s |     2.6 MiB/s |     43 h/s |     37 h/s |       28 h/s |
|        35 |   3.2 TiB |     96 % |     2.3 MiB/s |     2.6 MiB/s |     2.6 MiB/s |      3 h/s |     29 h/s |       28 h/s |
+-----------+-----------+----------+---------------+---------------+---------------+------------+------------+--------------+
```

Both [Solo Miners and Coordinated Miners](../overview/node-types.md) print this report, however Coordinated Miners inclues some extra information discussed below.

## 1.1 VDF Speed and Solution Stats

- **VDF Speed**: the averge VDF speed that your miner has realized since the last time the report was generated (i.e. typically 10 seconds).
- **H1 and H2 Solutions**: the number of H1 or H2 solutions your miner has found. Most, but not all, solutions will become blocks. However do to orphan rate and occasional race conditions, many blocks are not confirmed.
- **Confirmed Blocks**: the number of blocks that your miner believes have been accepted by the network. Each confirmed block **should** generate miner rewards for you. However, there are some limitations in the the miner which cause it to miss some orphans. Some tips on how to account for these limitations are discussed in [Understanding Mining](../overview/mining.md)

{% hint style="warning" %} 
**Pool Mining:** When mining against a pool, the H1 and H2 solutions will report **partial** solutions. Pool miners maintain 2 difficulties: the normal network difficulty, and a lower difficulty set by the pool operator. Partial solutions just satisfy the lower difficulty and usually will not result in a valid block. Partial Solutions are used by the pool operator to track how much work each pool client is performing in order to calculate their share of rewards.
{% endhint %}

## 1.2 Local mining stats

The mining performance stats are broken down by partition with the total across all partitions listed at the top.

- **Data Size** and **% of Max**: the amount of data you have packed for a given partition (as well as the total) and what percent that is of the total possible. The amount of data you have packed is the main determinant of your hashrate.
- **Read (xxx)**: the mining read throughput per partition and in aggregate.
- **Hash (xxx)***: mining hashrate per partition and in aggregate.

You can read more about how hashrate is calculated in the [Hashrate](../overview/hashrate.md) guide.

### 1.2.1 `Cur` vs. `Avg` vs. `Ideal`

You'll see 3 values for the `Read` and `Hash` stats.

- **Cur**: The average `Read` or `Hash` rate since the last time the Performance Report was shown. i.e. the average over the last 10 seconds
- **Avg**: The average `Read` or `Hash` rate since the node started.
- **Ideal**: The ideal `Read` or `Hash` rate given the amount of data you have synced and your VDF Speed. This value is also an average over the last 10 seconds.

You can use the `Ideal` values to determine whether you're getting your exepected `Read` or `Hash` rates.

{% hint style="warning" %} 
**Coordinated Mining:** The `Ideal` rates are incorrect and too low for coordinated miners. They currently track the `Ideal` `Read` or `Hash` rate for the miner assuming that it is solo mining and does not have access to any of the partitions mined by a peer. The `Cur` and `Avg` values, however, are correct. The result is that it will seems as if your coordinated miner is mining far better than `Ideal`.
{% endhint %}


# 2. Coordined mining cluster stats

Coordinated miners will have an additional table printed blow the **Local mining stats**:

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

This table tracks the H1 and H2 solutions that each miner in the cluster exchanges with each other.

- **Peer**: Local CM peer IP:Port#
- **H1 Out (Cur)**: **The average H1 hashes per second sent to Peer since the last screen refresh
- **H1 Out (Avg)**: This average H1 hashes per second sent to Peer since the miner was started
- **H1 In (Cur)**: The average H1 hashes per second received from Peer since the last screen refresh
- **H1 In (Cur)**: The average H1 hashes per second received from Peer since the miner was started
- **H2 Out**: When a node in your CM cluster generates a Solution, it is sent out to the cluster and the exit node will submit it to the network in the hopes of mining that block
- **H2 In**: Same as above, except incoming