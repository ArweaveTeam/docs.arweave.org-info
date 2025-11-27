---
description: >-
  How to configure your operating system to run Arweave
---

In order to run an Arweave miner efficiently, several operating system defaults should be updated.

## 0. Recommonded OS: Ubuntu Linux

We recommend running Arweave on Ubuntu Linux 22.04 or 24.04. 

## 1. File Descriptors Limit

The number of available file descriptors affects the rate at which your node can process data. Most operating systems default to assigning a low limit for user processes, we recommend increasing it.

{% hint style="info" %} 
These File Descriptors Limit instructions apply to Linux. When running a VDF Server on MacOS, please refer to the VDF guide.
{% endhint %}

You can check the current limit by executing `ulimit -n`.

On Linux, to set a bigger global limit, open `/etc/sysctl.conf` and add the following line:

```
fs.file-max=10000000
```

Execute `sysctl -p` to make the changes take effect.

You may also need to set a proper limit for the particular user. To set a user-level limit, open `/etc/security/limits.conf` and add the following line:

```
<your OS user>         soft    nofile  1000000
```

Open a new terminal session. To make sure the changes took effect, and the limit was increased, type `ulimit -n`. You can also change the limit for the current session via `ulimit -n 10000000`

If the above does not work, set

```
DefaultLimitNOFILE=1000000
```

in both `/etc/systemd/user.conf`and `/etc/systemd/system.conf`

## 2. Configuring Large Memory Pages

Mining involves computing 1 RandomX hash and several SHA2 hashes every second for every 3.6 TB mining partition. It is not a lot, but your CPU may nevertheless become a bottleneck when you configure a lot of mining partitions. To maximize your hashing performance, consider configuring huge memory pages in your OS.

On Ubuntu, to see the current values, execute:`cat /proc/meminfo | grep HugePages`. To set a value, run `sudo sysctl -w vm.nr_hugepages=5000`. To make the configuration survive reboots, create `/etc/sysctl.d/local.conf` and put `vm.nr_hugepages=5000` there.

The output of `cat /proc/meminfo | grep HugePages` should then look like this:\
`AnonHugePages: 0 kB`\
`ShmemHugePages: 0 kB HugePages_Total: 5000 HugePages_Free: 5000 HugePages_Rsvd: 0 HugePages_Surp: 0`

If it does not or if there is a "erl_drv_rwlock_destroy" error on startup, reboot the machine.

Finally, tell the miner it can use large pages by specifying `enable randomx_large_pages` on startup (you can find a complete startup example further in the guide).
