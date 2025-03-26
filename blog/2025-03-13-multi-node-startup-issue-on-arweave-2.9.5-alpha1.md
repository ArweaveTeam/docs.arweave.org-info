The latest arweave release
([`arweave-2.9.5-alpha1`](https://github.com/ArweaveTeam/arweave/releases/tag/N.2.9.5-alpha1))
includes an important number of fixes and improvements, in particular
when managing Arweave. The main entry-point present in `bin/arweave`
has been updated to reflect the latest version of the script usually
provided by [`rebar3`](https://www.rebar3.org/) (the official
[Erlang/OTP](https://www.erlang.org/) project manager).

During this process, some features have been temporarily removed or
disabled, one of them is the way to start more than one Arweave node
on a system. Most of the users/miners were simply modifying the file
`bin/arweave.env` to start a different nodes. This file has been
removed to offer only one entry-point and to use more "best practices".

## TL;DR

The easiest way to fix this problem is to modify the file
[`releases/2.9.5-alpha1/vm.args.src`](https://github.com/ArweaveTeam/arweave/blob/N.2.9.5-alpha1/config/vm.args.src)
by replacing `-name` ([line
15](https://github.com/ArweaveTeam/arweave/blob/N.2.9.5-alpha1/config/vm.args.src#L15))
and `-setcookie` ([line
18](https://github.com/ArweaveTeam/arweave/blob/N.2.9.5-alpha1/config/vm.args.src#L18))
parameters:

```sh
## Name of the node
-name ${NAME:-arweave@127.0.0.1}

## Cookie for distributed erlang
-setcookie ${COOKIE:-arweave}
```

Then, more than one node can be started by configuring `NAME` and/or
`COOKIE` environment variable using `export`:

```sh
export NAME=mynode@127.0.0.1
export COOKIE=mycookie
./bin/start ${arweave_parameters}
```

Or by directly configuring these variables in front of the command:

```sh
NAME=mynode@127.0.0.1 COOKIE=mycookie ./bin/start ${arweave_parameters}
```

## Full Procedure

Here a full procedure to extract and configure more than one node with
this new release, including a patch. Let prepare the environment first
by creating a new directory in `/opt/t` and download the last release
using `wget`.

```sh
# prepare and fetch the release
mkdir /opt/t
cd /opt/t
wget https://github.com/ArweaveTeam/arweave/releases/download/N.2.9.5-alpha1/arweave-2.9.5-alpha1.linux-x86_64.tar.gz
tar zxvf arweave-2.9.5-alpha1.linux-x86_64.tar.gz
```

the file `releases/2.9.5-alpha1/vm.args.src` must be patched to allow dynamic variable
configuration from environment. The patch function is used here, and should be applied
only on a fresh installation. This snippet will simply update these two lines:

  - `-name ${NAME:-arweave@127.0.0.1}`
  - `-setcookie ${COOKIE:-arweave}`

```sh
# patch the file
cat | patch -u releases/2.9.5-alpha1/vm.args.src - << 'EOF'
--- vm.args.src 2025-03-13 16:47:22.982251812 +0000
+++ vm.args.src2        2025-03-13 16:47:09.566189432 +0000
@@ -12,10 +12,10 @@
 ## schedulers that will be used, to do that: +S 16:16
 ######################################################################
 ## Name of the node
--name arweave@127.0.0.1
+-name ${NAME:-arweave@127.0.0.1}
 
 ## Cookie for distributed erlang
--setcookie arweave
+-setcookie ${COOKIE:-arweave}
 
 ## This is now the default as of OTP-26
 ## Multi-time warp mode in combination with time correction is the
EOF
```

A first node is started, it will use `TCP/1984` and 
`/opt/arweave_data1`.

```sh
# first node:
touch config1.json
NAME=a@127.0.0.1 ./bin/arweave console config1.json
```

A second node is started. this time, it will use
`TCP/1985` and `/opt/arweave_data2`.

```sh
# second node:
touch config2.json
NAME=b@127.0.0.1 ./bin/arweave console config2.json
```

To be sure both of these nodes are correctly running, one can use
`curl` and check the returned value.

```sh
$ curl localhost:1984
{
  "version": 5,
  "release": 81,
  "queue_length": 0,
  "peers": 598,
  "node_state_latency": 1,
  "network": "arweave.N.1",
  "height": 1628135,
  "current": "X6j1_GgRPK4DZhrt2wXt-EI4E4LCJ2capBpmysJZ9dyIv1Ov6E4x07i9cZETHAyt",
  "blocks": 8434
}

$ curl localhost:1985
{
  "version": 5,
  "release": 81,
  "queue_length": 0,
  "peers": 316,
  "node_state_latency": 1,
  "network": "arweave.N.1",
  "height": 1628135,
  "current": "X6j1_GgRPK4DZhrt2wXt-EI4E4LCJ2capBpmysJZ9dyIv1Ov6E4x07i9cZETHAyt",
  "blocks": 933437
}
```

Another way to check if both nodes are up and running is to use the
new entry-point and ping each nodes.

```sh
NAME=a@127.0.0.1 ./bin/arweave ping
# should return pong

NAME=b@127.0.0.1 ./bin/arweave ping
# should return pong
```

In case of errors, here a checklist to debug the previous steps:

 - your nodes are not sharing the same configuration files and/or
   parameters that could collide (ie `data_dir`)
 
 - ensure `data_dir` is different for both nodes (in the previous
   example, one node was using `/opt/arweave_data1` and the second
   `/opt/arweave_data2`)
 
 - ensure `port` is different for both nodes (in the previous example,
   one node was listening on `TCP/1984` and the other on `TCP/1985`)
 
 - ensure `NAME` and `COOKIE` variables are correctly configured
 
 - ensure `epmd` has been correctly started and is correctly
   configured in doubt: `pkill epmd`
 
 - ensure the variables have been correctly configuration (ie
   `${NAME:-default_value}`)


## Conclusion

The new entry-point is offering lot of new features, and the
interfaces to manage arweave are basically the same. One can have
access to the full documentation by using: `./bin/arweave` command.

```
Usage: arweave [COMMAND] [ARGS]

Arweave Commands:

  benchmark               Run Arweave Benchmarks
  check                   Check system parameters for Arweave
  console                 Start Arweave with an interactive Erlang shell
  console_clean           Start an interactive Erlang shell without the Arweave release's applications
  daemon                  Start Arweave in the background with run_erl (named pipes)
  daemon_attach           Connect to Arweave node started as daemon with to_erl (named pipes)
  doctor                  Start Arweave Data Analyzer tool
  escript                 Run an escript in the same environment as the Arweave release
  eval [Exprs]            Run Erlang expressions on Arweave node
  foreground              Start Arweave with output to stdout
  foreground_clean        Start Arweave VM without any entry-point as arguments
  pid                     Print the PID of the Arweave OS process
  ping                    Print pong if the Arweave node is alive
  reboot                  Reboot the entire Arweave VM
  reload                  Restart only Arweave application in the VM
  remote_console          Connect remote shell to the Arweave node
  restart                 Restart the running applications but not the Arweave VM
  rpc [Mod [Fun [Args]]]] Run apply(Mod, Fun, Args) on the Arweave node
  status                  Verify if the Arweave node is running and then run status hook scripts
  stop                    Stop the Arweave node
  version                 Print the Arweave version
  wallet                  Manage Arweave wallets
```

