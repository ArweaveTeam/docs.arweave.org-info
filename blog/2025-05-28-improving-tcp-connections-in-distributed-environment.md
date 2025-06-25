Managing TCP/IP connections in distributed environment is challenging,
even more when most of the nodes are managed by different entities
around the world. In the case of Arweave, these connections can have a
huge impact on the application, and can be when Arweave is being
stopped.

Indeed, probably all Arweave users were stuck in front of their
terminal waiting for the application to end correctly, but sometimes,
one can wait forever. The initial issue was mainly due to a lack of
control over the sockets connected to other peers. Acting as a client
and a server, these connections must be terminated one by one if they
are active.

## Managing Arweave Shutdown

 - http half-duplex protocol
 - soft mode: client first
 - hard mode: server first

Arweave is using `cowboy` as http server and `gun` as http
client. Those two Erlang applications have been configured to have
long living connections to other peers. When the node is being
stopped, those connections are still alive on `cowboy` or `gun`
side.

### Soft Connection Shutdown

In soft mode, arweave will wait for the client to shutdown the
connection on its side. A `FIN` message is sent, and when the client
is ready, the connection is closed.

### Hard Connection Shutdown

In hard mode, arweave will not wait for the client, but will directly
close the connection and give the socket back to the kernel. A `RST`
message is sent, and with the help of `linger` configuration, the
kernel will deal with the remaining data to send/receive.

## High Latency Peers

During the investigation, and even with all the patches or procedures
used, few connections were still active and alive. It seems this issue
was directly linke to a deeper problem: high latency peers. At the
time of writing, around 20 public peers are using a satellite
connection (mostly Starlink/SpaceX), and many more are hosted around
the world with a ping greater than 250ms.

Unfortunately, most of the standard operating systems on the market
are not configured to deal with this kind of networks. A custom
configuration of the TCP/IP stack is then required to avoid unreliable
connections between peers.

### GNU/Linux TCP/IP Stack Optimization

```sh
cat >> /etc/sysctl.d/99-arweave-custom.conf << EOF
# net.ipv4.tcp_tw_reuse=1
#
net.ipv4.tcp_keepalive_time=720
#
net.ipv4.tcp_min_rtt_wlen=120
#
net.ipv4.tcp_syn_retries=3
#
net.ipv4.tcp_synack_retries=3
#
# net.ipv4.tcp_retries1
#
# net.ipv4.tcp_retries2
# net.ipv4.tcp_sack = 0
# net.ipv4.tcp_dsack = 0
# net.ipv4.tcp_fack = 0
# net.ipv4.tcp_slow_start_after_idle = 0 
net.core.default_qdisc = fq_codel
sysctl net.ipv4.tcp_congestion_control=bbr

EOF
sudo sysctl -p /etc/sysctl.d/99-arweave-custom.conf
```

https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html

https://www.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/netperf/tuning-tcp.shtml

https://www.cyberciti.biz/faq/linux-tcp-tuning/

https://cromwell-intl.com/open-source/performance-tuning/tcp.html

https://forums.whirlpool.net.au/archive/116165

https://www.kernel.org/doc/html/latest/admin-guide/sysctl/net.html#default-qdisc

https://www.man7.org/linux/man-pages/man8/tc-fq_codel.8.html

https://www.man7.org/linux/man-pages/man7/tcp.7.html

https://blog.codefarm.me/2023/01/17/tcp-ip-tcp-timeout-and-retransmission/

https://linux.die.net/man/7/tcp

https://linodelinux.com/fix-tcp-connection-overload-in-linux-server/

https://www.cyberciti.biz/cloud-computing/increase-your-linux-server-internet-speed-with-tcp-bbr-congestion-control/

https://netdevconf.org/1.2/slides/oct5/04_Making_Linux_TCP_Fast_netdev_1.2_final.pdf

### MacOS/X TCP/IP Stack Optimization

```sh
```

```
```

https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/sysctl.3.html

https://calomel.org/freebsd_network_tuning.html

https://slaptijack.com/system-administration/mac-os-x-tcp-performance-tuning.html

https://www.nas.nasa.gov/hecc/support/kb/TCP-Performance-Tuning-for-WAN-Transfers_137.html

https://github.com/apple-oss-distributions/xnu/blob/e3723e1f17661b24996789d8afc084c0c3303b26/bsd/netinet/tcp_output.c#L287

## Arweave Network Optimization

Arweave is using an HTTP client (Gun) and an HTTP server
(Cowboy). Those Erlang applications can have different behaviors based
on the quality of the connections.

| Version | Parameters                                | Default Value |
|---------|-------------------------------------------|---------------|
| `2.9.5` | `http_api.http.active_n`                  | `100`
| `2.9.5` | `http_api.http.inactivity_timeout`        | `60000`
| `2.9.5` | `http_api.http.linger_timeout`            | `0`
| `2.9.5` | `http_api.http.linger`                    | `false`
| `2.9.5` | `http_api.http.request_timeout`           | `5000`
| `2.9.5` | `http_api.tcp.backlog`                    | `1024`
| `2.9.5` | `http_api.tcp.delay_send`                 | `false`
| `2.9.5` | `http_api.tcp.idle_timeout_seconds`       | `10`
| `2.9.5` | `http_api.tcp.keepalive`                  | `true`
| `2.9.5` | `http_api.tcp.listener_shutdown`          | `5000`
| `2.9.5` | `http_api.tcp.nodelay`                    | `true`
| `2.9.5` | `http_api.tcp.num_acceptors`              | `10`
| `2.9.5` | `http_api.tcp.send_timeout_close`         | `true`
| `2.9.5` | `http_api.tcp.send_timeout`               | `15000`
| `2.9.5` | `http_client.http.closing_timeout`        | `15000`
| `2.9.5` | `http_client.http.keepalive`              | `60000`
| `2.9.5` | `http_client.tcp.delay_send`              | `false`
| `2.9.5` | `http_client.tcp.keepalive`               | `true`
| `2.9.5` | `http_client.tcp.linger_timeout`          | `0`
| `2.9.5` | `http_client.tcp.linger`                  | `false`
| `2.9.5` | `http_client.tcp.nodelay`                 | `true`
| `2.9.5` | `http_client.tcp.send_timeout_close`      | `true`
| `2.9.5` | `http_client.tcp.send_timeout`            | `15000`
| `2.9.5` | `network.socket.backend`                  | `inet`
| `2.9.5` | `network.tcp.shutdown.connection_timeout` | `30`
| `2.9.5` | `network.tcp.shutdown.mode`               | `shutdown`

### `http_api.http.active_n`

see: https://ninenines.eu/docs/en/cowboy/2.12/manual/cowboy_http/#_options

### `http_api.http.inactivity_timeout`

see: https://ninenines.eu/docs/en/cowboy/2.12/manual/cowboy_http/#_options

### `http_api.http.linger_timeout`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_api.http.linger`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_api.http.request_timeout`

see: https://ninenines.eu/docs/en/cowboy/2.10/manual/cowboy_http/#_options

### `http_api.tcp.backlog`

see: https://ninenines.eu/docs/en/ranch/1.8/manual/ranch_tcp/

### `http_api.tcp.delay_send`

see: https://ninenines.eu/docs/en/ranch/1.8/manual/ranch_tcp/

### `http_api.tcp.idle_timeout_seconds`

see: https://ninenines.eu/docs/en/cowboy/2.12/manual/cowboy_http/

### `http_api.tcp.keepalive`

see: https://ninenines.eu/docs/en/ranch/1.8/manual/ranch_tcp/

### `http_api.tcp.listener_shutdown`

see: https://ninenines.eu/docs/en/cowboy/2.12/manual/cowboy_http/#_options

### `http_api.tcp.nodelay`

see: https://ninenines.eu/docs/en/ranch/1.8/manual/ranch_tcp/

### `http_api.tcp.num_acceptors`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_api.tcp.send_timeout_close`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_api.tcp.send_timeout`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_client.http.closing_timeout`

see: https://ninenines.eu/docs/en/gun/2.2/manual/gun/#_http_opts

### `http_client.http.keepalive`

see: https://ninenines.eu/docs/en/gun/2.2/manual/gun/#_http_opts

### `http_client.tcp.delay_send`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_client.tcp.keepalive`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_client.tcp.linger_timeout`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_client.tcp.linger`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_client.tcp.nodelay`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_client.tcp.send_timeout_close`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `http_client.tcp.send_timeout`

see: https://www.erlang.org/docs/24/man/inet#setopts-2

### `network.socket.backend`

Since few releases, Erlang offers two different backend. The
traditional `inet` using an Erlang driver and the `socket` one, using
a `NIF`. Arweave is using `inet` by default to avoid breaking change
between version.

see: https://www.erlang.org/doc/apps/kernel/inet.html#t:inet_backend/0

### `network.tcp.shutdown.connection_timeout`

`network.tcp.shutdown.connection_timeout` is configuring the delay (in
second) when the shutdown procedure must be stopped even if active
connections are still present.

### `network.tcp.shutdown.mode`

`network.tcp.shutdown.mode` configures the way Arweave closes the
connections during shutdown. The best way to close a TCP connection is
to send a `FIN` message to the remote peer, and waiting for an
`FIN-ACK`, then closing the connection. This method is using
`shutdown` interface.

Unfortunately, because HTTP is half-duplex, when a connection is
already active and stuck because of connections issues, the remote
peer can have difficulties to send the acknowledment back to the
sender. In this case, the server can send an `RST` message, and close
the connection without waiting for the `ACK`. This is not the cleanest
solution but it can avoid blocking connection. This method is using
`close` interface.

Arweave is offering those two modes when a connection must be closed
during shutdown, the default used is `shutdown`, but one can set it to
`close`.

see: https://www.erlang.org/doc/apps/kernel/gen_tcp.html#shutdown/2

see: https://www.erlang.org/doc/apps/kernel/gen_tcp.html#close/1

## Next

At this time, most of these parameters are globally applied on all
connections. The best would be to apply and configure different kind
of parameters for one or more peers, depending on the network quality
and the different constraints impacting users and miners.

## References and Resources

https://community.jisc.ac.uk/system/files/86/BrianTierneyNFNN2.pdf

https://datatracker.ietf.org/meeting/112/materials/slides-112-tcpm-tcp-silent-close-for-cases-where-silence-is-golden-00

https://research.cec.sc.edu/files/cyberinfra/files/BBR%20-%20Fundamentals%20and%20Updates%202023-08-29.pdf

https://www.net.in.tum.de/fileadmin/bibtex/publications/papers/IFIP-Networking-2018-TCP-BBR.pdf

https://linuxreviews.org/Type_of_Service_(ToS)_and_DSCP_Values

https://datatracker.ietf.org/meeting/122/materials/slides-122-tcpm-close-00

https://blog.netherlabs.nl/articles/2009/01/18/the-ultimate-so_linger-page-or-why-is-my-tcp-not-reliable

https://www.icir.org/mallman/pubs/AHKO97/AHKO97.pdf

http://www.emmelmann.org/Library/Papers_Reports/docs/tcp_enhancements_sat_net.pdf

https://arxiv.org/pdf/2007.15373

https://etd.ohiolink.edu/acprod/odb_etd/ws/send_file/send?accession=ohiou1177615641&disposition=inline

http://emmelmann.org/Library/Papers_Reports/docs/tcp_routing_satellite.pdf

https://arxiv.org/pdf/2408.07460

https://www.diva-portal.org/smash/get/diva2:1901818/FULLTEXT02

https://www.researchgate.net/profile/Catherine-Rosenberg-3/publication/3971486_Performance_improvement_of_TCP-based_applications_in_a_multi-access_satellite_system/links/56197c5308ae6d173086f020/Performance-improvement-of-TCP-based-applications-in-a-multi-access-satellite-system.pdf

https://ieeexplore.ieee.org/abstract/document/7897319/

https://netdevconf.info/0x15/papers/32/paper-final.pdf

https://cs.ucr.edu/~ztan/courses/CS204/f23/lec6_cubic_bbr.pdf

https://www.rbftpnetworks.com/blog/bbr-congestion-control-for-improved-transfer-throughput-complete-guide/

## ANNEXE A - Linux/MacOS Network Stack Summary Table

| Linux | MacOS | Comment |
|-------|-------|---------|
| `net.ipv4.tcp_abort_on_overflow` | -
| `net.ipv4.tcp_adv_win_scale` |
| `net.ipv4.tcp_allowed_congestion_control` |
| `net.ipv4.tcp_app_win` |
| `net.ipv4.tcp_autocorking` |
| `net.ipv4.tcp_available_congestion_control` |
| `net.ipv4.tcp_available_ulp` |
| `net.ipv4.tcp_base_mss` |
| `net.ipv4.tcp_challenge_ack_limit` |
| `net.ipv4.tcp_comp_sack_delay_ns` |
| `net.ipv4.tcp_comp_sack_nr` |
| `net.ipv4.tcp_comp_sack_slack_ns` |
| `net.ipv4.tcp_congestion_control` |
| `net.ipv4.tcp_dsack` |
| `net.ipv4.tcp_early_demux` |
| `net.ipv4.tcp_early_retrans` |
| `net.ipv4.tcp_ecn` |
| `net.ipv4.tcp_ecn_fallback` |
| `net.ipv4.tcp_fack` |
| `net.ipv4.tcp_fastopen` |
| `net.ipv4.tcp_fastopen_blackhole_timeout_sec` |
| `net.ipv4.tcp_fastopen_key` |
| `net.ipv4.tcp_fin_timeout` |
| `net.ipv4.tcp_frto` |
| `net.ipv4.tcp_fwmark_accept` |
| `net.ipv4.tcp_invalid_ratelimit` |
| `net.ipv4.tcp_keepalive_intvl` |
| `net.ipv4.tcp_keepalive_probes` |
| `net.ipv4.tcp_keepalive_time` |
| `net.ipv4.tcp_l3mdev_accept` |
| `net.ipv4.tcp_limit_output_bytes` |
| `net.ipv4.tcp_low_latency` |
| `net.ipv4.tcp_max_orphans` |
| `net.ipv4.tcp_max_reordering` |
| `net.ipv4.tcp_max_syn_backlog` |
| `net.ipv4.tcp_max_tw_buckets` |
| `net.ipv4.tcp_mem` |
| `net.ipv4.tcp_migrate_req` |
| `net.ipv4.tcp_min_rtt_wlen` |
| `net.ipv4.tcp_min_snd_mss` |
| `net.ipv4.tcp_min_tso_segs` |
| `net.ipv4.tcp_moderate_rcvbuf` |
| `net.ipv4.tcp_mtu_probe_floor` |
| `net.ipv4.tcp_mtu_probing` |
| `net.ipv4.tcp_no_metrics_save` |
| `net.ipv4.tcp_no_ssthresh_metrics_save` |
| `net.ipv4.tcp_notsent_lowat` |
| `net.ipv4.tcp_orphan_retries` |
| `net.ipv4.tcp_pacing_ca_ratio` |
| `net.ipv4.tcp_pacing_ss_ratio` |
| `net.ipv4.tcp_probe_interval` |
| `net.ipv4.tcp_probe_threshold` |
| `net.ipv4.tcp_recovery` |
| `net.ipv4.tcp_reflect_tos` |
| `net.ipv4.tcp_reordering` |
| `net.ipv4.tcp_retrans_collapse` |
| `net.ipv4.tcp_retries1` |
| `net.ipv4.tcp_retries2` |
| `net.ipv4.tcp_rfc1337` |
| `net.ipv4.tcp_rmem` |
| `net.ipv4.tcp_rx_skb_cache` |
| `net.ipv4.tcp_sack` | `net.inet.tcp.sack` |
| `net.ipv4.tcp_slow_start_after_idle` |
| `net.ipv4.tcp_stdurg` |
| `net.ipv4.tcp_syn_retries` |
| `net.ipv4.tcp_synack_retries` |
| `net.ipv4.tcp_syncookies` |
| `net.ipv4.tcp_thin_linear_timeouts` |
| `net.ipv4.tcp_timestamps` |
| `net.ipv4.tcp_tso_win_divisor` |
| `net.ipv4.tcp_tw_reuse` |
| `net.ipv4.tcp_tx_skb_cache` |
| `net.ipv4.tcp_window_scaling` |
| `net.ipv4.tcp_wmem` |
| `net.ipv4.tcp_workaround_signed_windows` |
