---
description: >-
  Reading and changing node configuration at runtime with arweave config
  get and set
---

# Dynamic Configuration

{% hint style="info" %}
Dynamic configuration is only available from Arweave 2.9.6 onward.
{% endhint %}

A running node's configuration can be inspected - and, for many options, changed - without a restart, using the `config get` and `config set` subcommands of the [Arweave entrypoint](../operations/entrypoint.md).

# 1. Prerequisites

`config get` and `config set` talk to a **running node** over the Erlang distribution protocol. Run them from the same Arweave install directory as the node, as the same user. If the node is not running the commands print `Node is not running!` and exit.

If you launched the node with a custom Erlang node name or cookie (the `ARNODE` / `ARCOOKIE` environment variables, e.g. when [running multiple nodes on one server](../operations/multiple-nodes.md)), set the same values when invoking `config get` / `config set` so the command can reach the right node:

```sh
ARNODE=node1@127.0.0.1 ARCOOKIE=node1 ./bin/arweave config get port
```

# 2. Reading Values

`config get` accepts any option key in dotted form and prints its current value:

```sh
$ ./bin/arweave config get mining.enabled
true

$ ./bin/arweave config get sync.jobs
100

$ ./bin/arweave config get debug
false
```

Any option can be read, whether it was set explicitly or is at its default.

# 3. Changing Values

`config set` takes a key and a new value:

```sh
$ ./bin/arweave config set debug true
ok

$ ./bin/arweave config set mining.cache_size 8192
ok
```

The value is parsed and type-checked exactly as it would be at startup. On success the command prints `ok` and the change takes effect immediately.

## 3.1 List Options

List-valued options (peer lists, URL lists, etc...) take their new
value as a **JSON array**, quoted so the shell passes it as a single
argument:

```sh
$ ./bin/arweave config set peers.local '["10.0.0.5:1984", "peer.example.com:1984"]'
ok

$ ./bin/arweave config get peers.local
["10.0.0.5:1984","203.0.113.7:1984"]
```

Hostnames in the array are resolved to IP addresses when the `set` is
applied, just as they would be at startup - `config get` shows the
resolved set. List values print as a JSON array, which is exactly the
form `config set` accepts: a `get` result can be edited and passed
straight back to `set`. The same JSON form also works at startup, as
a [command-line flag](configuration.md#3-command-line-flags) value or
an [environment variable](environment-variables.md).

Two things to keep in mind:

* **A `set` replaces the whole list.** There is no append: to add one
  entry, `config get` the current value first and pass the complete
  new list including the addition. Passing a single bare value
  (`config set peers.local 10.0.0.5:1984`) is valid but sets a
  *one-element* list - it does not add to the existing entries.
* **Always wrap the JSON array in single quotes.** Unquoted, the
  shell strips the inner double quotes before the value reaches the
  node (`["a","b"]` arrives as `[a,b]`), which is rejected as
  malformed. When pasting a `config get` result back into
  `config set`, add the surrounding single quotes.

## 3.2 Runtime-writable Options

Not every option can be changed while the node is running. Options are marked either runtime-writable or startup-only; a `config set` on a startup-only option is rejected with an error, and the running configuration is left unchanged.

To find out whether an option is runtime-writable, look for the `*` marker next to it in the top-level listing (`./bin/arweave config help`), or check the `runtime:` line in the group help:

```sh
$ ./bin/arweave config help mining
=== mining ===
Control mining behavior and reward attribution.

  mining.cache_size
    Total cache size in MiB allocated to store unprocessed chunks while mining.
    ...
    default: undefined
    runtime: true
    legacy: mining_cache_size_mb
  ...
```

`runtime: true` means the option accepts `config set` on a live node; `runtime: false` means it can only be set at startup.

## 3.3 Validation and Rollback

Every `config set` is validated before it sticks. If the new value is malformed, of the wrong type, or would leave the node with an invalid overall configuration, the command returns an error and the previous value is restored - a failed `set` never leaves the node in a partially-applied state.

```sh
$ ./bin/arweave config set sync.jobs not_a_number
{error, ...}
```

## 3.4 Changes Are Not Persisted

`config set` changes the running node only. It does not write to your config file - after a restart the node boots from the config file, environment, and flags as usual. To make a change permanent, also update your configuration file.
