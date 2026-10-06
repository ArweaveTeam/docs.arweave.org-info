---
description: >-
  A guide to update Erlang.
---

# 1. Ubuntu

If you followed our guide to install Erlang on Ubuntu, you've ended up using the RabbitMQ team's repository.
This repository has Erlang without versioning. Different repositories contain different versions of Erlang.
So, you need to remove this repository, then uninstall and purge Erlang.
Then, add the next version, and install Erlang again.

```
sudo -E add-apt-repository --remove  ppa:rabbitmq/rabbitmq-erlang-26
sudo -E apt remove --purge 'erlang*'
sudo -E add-apt-repository -y ppa:rabbitmq/rabbitmq-erlang-27
sudo -E apt-get update -qq
sudo -E apt install erlang -y
```

# 2. Mac 

If you followed our guide, you've installed Erlang on OS X with `brew`. You can use brew to uninstall the 
previous version, and install the new.

```
brew uninstall erlang@26
brew install erlang@27
```
