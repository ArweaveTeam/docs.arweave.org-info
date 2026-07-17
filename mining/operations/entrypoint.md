---
description: >-
  How to use the Arweave entrypoint script
---

# 0. `./bin/start` vs. `./bin/arweave`

This guide covers the core Arweave entrypoint: `./bin/arweave`. That entrypoint provides a lot of useful functionality. However when launching your node it is recommended that you use `./bin/start`.

`./bin/start` wraps `./bin/arweave foreground` and includes a naive auto-restart functionality. If your node crashes, `./bin/start` will wait 15 seconds and then start it again.

# 1. Arweave Entrypoint

The Arweave entry-point located in `bin/arweave` integrates all required
subcommands in one place. To print the help page, execute the script:

```sh
./bin/arweave
```

It is also possible to have a more detailed help of one particular
	subcommand by passing it after the `help` one.

```sh
./bin/arweave help ${subcommand}
```

# 2. Start Arweave

Arweave can be started in many different ways depending of the needs
and all these methods can be used with `./bin/arweave`
entry-point. Most of the users are using `./bin/start` to start an
arweave node, this script is equivalent to:

```sh
./bin/arweave foreground ${parameters}
```

The parameters are the node's configuration: `--long` flags named
after dotted option keys, usually combined with a `--config_file`
pointing at a JSON or YAML config file. Options can also be set with
`AR_*` environment variables. For example:

```sh
./bin/arweave foreground --config_file /opt/arweave/config.yaml

./bin/arweave foreground --data_dir /opt/data --mining.enabled \
    --mining.address En2eqsVJARnTVOSh723PBXAKGmKgrGSjQ2YIGwE_ZRI

AR_CONFIG_FILE=/opt/arweave/config.yaml AR_PORT=1985 ./bin/arweave foreground
```

See [Configuring Your Node](../setup/configuration.md) for the config
file syntax and precedence rules, and
[Environment Variables](../setup/environment-variables.md) for the
`AR_*` naming convention.

To have access to Arweave output directly from the terminal (without
the Erlang console) the following command can be used. It could be
used with any process manager like `systemd`, because the VM will not
fork.

```sh
./bin/arweave foreground ${parameters}
```

To have access to Arweave output directly from the terminal with an
Erlang console:

```sh
./bin/arweave console ${parameters}
```

Arweave can also be started as an Unix daemon (in background) by
executing the following command:

```sh
./bin/arweave daemon ${parameters}
```

To reattach a daemon (and having access to the Erlang console), one
can execute the subcommand `daemon_attach`.

```sh
./bin/arweave daemon_attach
```

# 3. Arweave Status

To ensure a node is correctly running, one can ping it using
`./bin/arweave` entry-point. The script will return the string `pong`
if the node is up.

```sh
./bin/arweave ping
```

The same information can be available by using the subcommand
`status`, except nothing will be printed. The command will return `0`
if the node is up and `1` if the node is down. Useful for monitoring
scripts.

```sh
./bin/arweave status
```

Finally, to see if the node is reachable, it is also possible to use
external software like `curl`:

```sh
curl http://localhost:1984/
```

# 4. Remote Console

An Erlang shell can be invoked to control the Erlang VM where Arweave
is running. The `./bin/console` script can be used and it is
equivalent to execute this command:

```sh
./bin/arweave remote_console
```

The shell can be ended by pressing `Ctrl` + `C`.

# 5. Stop Arweave

An Arweave node can be stopped by using the script `./bin/stop` or by
executing the following command:

```
./bin/arweave stop
```

It can take some time for the node to shutdown. If you can, it is best to wait for the node to complete its shutdown process. However if you can't wait, you can kill the `arweave` and `beam.smp` processes using `kill -1`.

{% hint style="warning" %}
Sending a SIGKILL (`kill -9`) is **not** recommended as it can cause data corruption.
{% endhint %}

# 6. Manage Configuration

The `config` subcommand groups the configuration tools.

To print the built-in option reference - the canonical list of every
option, its default, and whether it can be changed at runtime:

```sh
./bin/arweave config help
./bin/arweave config help mining
```

To read or change configuration values on a **running** node:

```sh
./bin/arweave config get sync.jobs
./bin/arweave config set sync.jobs 50
```

`config get` and `config set` connect to the local node, so run them
from the node's install directory as the node's user (and with the
same `ARNODE` / `ARCOOKIE` values, if you set them). Only
runtime-writable options accept `set` on a live node - these are
marked with a `*` in the top-level `config help` listing and with
`runtime: true` in the group help. See
[Dynamic Configuration](../setup/dynamic-configuration.md) for
details.

# 7. Convert a Legacy Config File

`convert_config` converts a legacy (pre-2.9.6) `config.json` into the
current JSON or YAML configuration format:

```sh
./bin/arweave convert_config <json|yaml> <InputFile> <OutputFile>

# For example:
./bin/arweave convert_config yaml config.json config.yaml
```

See [Migrating Your Configuration](../setup/migrating-config.md) for
a worked example and migration gotchas.

# 8. Custom Erlang VM Arguments

The first - and easiest - method is to pass the new argument directly
from the command line, all arguments before `--` will be used to
overwrite the default VM parameters of the Erlang VM. All arguments
after `--` will be used for Arweave.

Example:
```sh
./bin/start +MMscs 131072 +S 16:16 -- --config_file config.yaml
```

The second method is to modify the
`rel/arweave/releases/${arweave_release}/vm.args.src` file. This file
contains all default parameters used by Arweave with some links to the
official documentation to help anyone wanting to optimize the Erlang
VM.

