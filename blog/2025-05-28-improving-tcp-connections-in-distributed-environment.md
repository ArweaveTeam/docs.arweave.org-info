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

| Parameter | Default | High Latency Network | Comment |
|-----------|---------|----------------------|---------|
| `net.ipv4.tcp_abort_on_overflow` | 0 | - | should not be modified
| `net.ipv4.tcp_adv_win_scale` | 1 | - |
| `net.ipv4.tcp_app_win` | 31 | - |
| `net.ipv4.tcp_autocorking` | 1 | - |
| `net.ipv4.tcp_base_mss` | 1024 | - |
| `net.ipv4.tcp_challenge_ack_limit` | 1000 | - |
| `net.ipv4.tcp_comp_sack_delay_ns` | 1000000 | - |
| `net.ipv4.tcp_comp_sack_nr` | 44 | - |
| `net.ipv4.tcp_comp_sack_slack_ns` | 100000 | - |
| `net.ipv4.tcp_congestion_control` | `cubic` | `bbr`
| `net.ipv4.tcp_dsack` | 1 | - |
| `net.ipv4.tcp_early_demux` | 1 | - |
| `net.ipv4.tcp_early_retrans` | 3 | - |
| `net.ipv4.tcp_ecn` | 2 | - |
| `net.ipv4.tcp_ecn_fallback` | 1 | - |
| `net.ipv4.tcp_fack` | 0 | - |
| `net.ipv4.tcp_fastopen` | 1 | - |
| `net.ipv4.tcp_fastopen_blackhole_timeout_sec` | 0
| `net.ipv4.tcp_fastopen_key` | - | - |
| `net.ipv4.tcp_fin_timeout` | 60 | - |
| `net.ipv4.tcp_frto` | 2 | - |
| `net.ipv4.tcp_fwmark_accept` | 0 | - |
| `net.ipv4.tcp_invalid_ratelimit` | 500 | - |
| `net.ipv4.tcp_keepalive_intvl` | 75 | - |
| `net.ipv4.tcp_keepalive_probes` | 9 | - |
| `net.ipv4.tcp_keepalive_time` | 7200 | - |
| `net.ipv4.tcp_l3mdev_accept` | 0 | - |
| `net.ipv4.tcp_limit_output_bytes` | 1048576 | - |
| `net.ipv4.tcp_low_latency` | 0 | - |
| `net.ipv4.tcp_max_orphans` | 131072 | - |
| `net.ipv4.tcp_max_reordering` | 300 | - |
| `net.ipv4.tcp_max_syn_backlog` | 2048 | - |
| `net.ipv4.tcp_max_tw_buckets` | 131072 | - |
| `net.ipv4.tcp_mem` | `373137 497517 746274` | - |
| `net.ipv4.tcp_migrate_req` | 0 | - |
| `net.ipv4.tcp_min_rtt_wlen` | 300 | - |
| `net.ipv4.tcp_min_snd_mss` | 48 | - |
| `net.ipv4.tcp_min_tso_segs` | 2 | - |
| `net.ipv4.tcp_moderate_rcvbuf` | 1 | - |
| `net.ipv4.tcp_mtu_probe_floor` | 48 | - |
| `net.ipv4.tcp_mtu_probing` | 0 | - |
| `net.ipv4.tcp_no_metrics_save` | 0 | - |
| `net.ipv4.tcp_no_ssthresh_metrics_save` | 1 | - |
| `net.ipv4.tcp_notsent_lowat` | 4294967295 | - |
| `net.ipv4.tcp_orphan_retries` | 0 | - |
| `net.ipv4.tcp_pacing_ca_ratio` | 120 | - |
| `net.ipv4.tcp_pacing_ss_ratio` | 200 | - |
| `net.ipv4.tcp_probe_interval` | 600 | - |
| `net.ipv4.tcp_probe_threshold` | 8 | - |
| `net.ipv4.tcp_recovery` | 1 | - |
| `net.ipv4.tcp_reflect_tos` | 0 | - |
| `net.ipv4.tcp_reordering` | 3 | - |
| `net.ipv4.tcp_retrans_collapse` | 1 | - |
| `net.ipv4.tcp_retries1` | 3 | - |
| `net.ipv4.tcp_retries2` | 15 | - |
| `net.ipv4.tcp_rfc1337` | 0 | - |
| `net.ipv4.tcp_rmem` | `4096 131072  6291456` | - |
| `net.ipv4.tcp_rx_skb_cache` | 0 | - |
| `net.ipv4.tcp_sack` | 1 | - |
| `net.ipv4.tcp_slow_start_after_idle` | 1 | - |
| `net.ipv4.tcp_stdurg` | 0 | - |
| `net.ipv4.tcp_syn_retries` | 6 | - |
| `net.ipv4.tcp_synack_retries` | 5 | 6 |
| `net.ipv4.tcp_syncookies` | 1 | - |
| `net.ipv4.tcp_thin_linear_timeouts` | 0 | - |
| `net.ipv4.tcp_timestamps` | 1 | - |
| `net.ipv4.tcp_tso_win_divisor` | 3 | - |
| `net.ipv4.tcp_tw_reuse` | 2 | - |
| `net.ipv4.tcp_tx_skb_cache` | 0 | - |
| `net.ipv4.tcp_window_scaling` | 1 | - |
| `net.ipv4.tcp_wmem` | `4096 16384 4194304` | - |
| `net.ipv4.tcp_workaround_signed_windows` | 0 | - |


https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
	
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

| Parameter | Default | High Latency Network | Comment |
|-----------|---------|----------------------|---------|
| `net.inet.tcp.acc_iaj_react_limit` | 200 |
| `net.inet.tcp.accurate_ecn` | 0 |
| `net.inet.tcp.ack_compression_rate` | 5 |
| `net.inet.tcp.ack_strategy` | 1 |
| `net.inet.tcp.aggressive_rcvwnd_inc` | 1 |
| `net.inet.tcp.always_keepalive` | 0 |
| `net.inet.tcp.autorcvbufmax` | 4194304 |
| `net.inet.tcp.autosndbufinc` | 8192 |
| `net.inet.tcp.autosndbufmax` | 4194304 |
| `net.inet.tcp.autotunereorder` | 1 |
| `net.inet.tcp.awdl_rtobase` | 100 |
| `net.inet.tcp.background_sockets` | 0 |
| `net.inet.tcp.backoff_maximum` | 65536 |
| `net.inet.tcp.bg_allowed_increase` | 8 |
| `net.inet.tcp.bg_ss_fltsz` | 2 |
| `net.inet.tcp.bg_target_qdelay` | 40 |
| `net.inet.tcp.bg_tether_shift` | 1 |
| `net.inet.tcp.blackhole` | 0 |
| `net.inet.tcp.broken_peer_syn_rexmit_thres` | 10 |
| `net.inet.tcp.cc_debug` | 0 |
| `net.inet.tcp.challengeack_limit` | 10 |
| `net.inet.tcp.clear_tfocache` | 0 |
| `net.inet.tcp.cubic_fast_convergence` | 0 |
| `net.inet.tcp.cubic_minor_fixes` | 1 |
| `net.inet.tcp.cubic_rfc_compliant` | 1 |
| `net.inet.tcp.cubic_sockets` | 643 |
| `net.inet.tcp.cubic_tcp_friendliness` | 0 |
| `net.inet.tcp.cubic_use_minrtt` | 0 |
| `net.inet.tcp.delayed_ack` | 3 |
| `net.inet.tcp.disable_access_to_stats` | 1 |
| `net.inet.tcp.disable_tcp_heuristics` | 0 |
| `net.inet.tcp.do_ack_compression` | 1 |
| `net.inet.tcp.do_better_lr` | 1 |
| `net.inet.tcp.do_rfc5961` | 1 |
| `net.inet.tcp.doautorcvbuf` | 1 |
| `net.inet.tcp.drop_synfin` | 1 |
| `net.inet.tcp.ecn_initiate_out` | 2 |
| `net.inet.tcp.ecn_negotiate_in` | 2 |
| `net.inet.tcp.ecn_setup_percentage` | 100 |
| `net.inet.tcp.ecn_timeout` | 60 |
| `net.inet.tcp.enable_tlp` | 1 |
| `net.inet.tcp.fastopen_backlog` | 10 |
| `net.inet.tcp.fastopen_key` |  |
| `net.inet.tcp.fastopen` | 3 |
| `net.inet.tcp.fin_timeout` | 60000 |
| `net.inet.tcp.flow_control_response` | 1 |
| `net.inet.tcp.icmp_may_rst` | 1 |
| `net.inet.tcp.init_rtt_from_cache` | 1 |
| `net.inet.tcp.keepcnt` | 8 |
| `net.inet.tcp.keepidle` | 7200000 |
| `net.inet.tcp.keepinit` | 75000 |
| `net.inet.tcp.keepintvl` | 75000 |
| `net.inet.tcp.l4s_developer` | 0 |
| `net.inet.tcp.l4s` | 0 |
| `net.inet.tcp.ledbat_plus_plus` | 1 |
| `net.inet.tcp.link_heuristics_flags` | 63 |
| `net.inet.tcp.link_heuristics_rto_min` | 3000 |
| `net.inet.tcp.local_slowstart_flightsize` | 8 |
| `net.inet.tcp.log_in_vain` | 0 |
| `net.inet.tcp.log.enable` | 0 |
| `net.inet.tcp.log.rate_current` | 0 |
| `net.inet.tcp.log.rate_duration` | 60 |
| `net.inet.tcp.log.rate_exceeded_total` | 0 |
| `net.inet.tcp.log.rate_limit` | 1000 |
| `net.inet.tcp.log.rate_max` | 0 |
| `net.inet.tcp.log.rtt_port` | 0 |
| `net.inet.tcp.log.thflags_if_family` | 0 |
| `net.inet.tcp.max_persist_timeout` | 0 |
| `net.inet.tcp.maxseg_unacked` | 8 |
| `net.inet.tcp.microuptime_init` | 4268444 |
| `net.inet.tcp.min_iaj_win` | 16 |
| `net.inet.tcp.minmss` | 216 |
| `net.inet.tcp.mptcp_preferred_version` | 1 |
| `net.inet.tcp.mptcp_version_timeout` | 1440 |
| `net.inet.tcp.msl` | 15000 |
| `net.inet.tcp.mssdflt` | 512 |
| `net.inet.tcp.newreno_sockets` | 0 |
| `net.inet.tcp.now_init` | 34697612 |
| `net.inet.tcp.packetchain` | 50 |
| `net.inet.tcp.path_mtu_discovery` | 1 |
| `net.inet.tcp.pcbcount` | 644 |
| `net.inet.tcp.pmtud_blackhole_detection` | 1 |
| `net.inet.tcp.pmtud_blackhole_mss` | 1200 |
| `net.inet.tcp.rack` | 1 |
| `net.inet.tcp.randomize_ports` | 0 |
| `net.inet.tcp.randomize_timestamps` | 1 |
| `net.inet.tcp.rcvsspktcnt` | 512 |
| `net.inet.tcp.reass.overflows` | 0 |
| `net.inet.tcp.reass.qlen` | 0 |
| `net.inet.tcp.recv_allowed_iaj` | 5 |
| `net.inet.tcp.recv_throttle_minwin` | 16384 |
| `net.inet.tcp.recvbg` | 0 |
| `net.inet.tcp.recvspace` | 131072 |
| `net.inet.tcp.rexmt_slop` | 200 |
| `net.inet.tcp.rexmt_thresh` | 3 |
| `net.inet.tcp.rfc3465_lim2` | 1 |
| `net.inet.tcp.rfc3465` | 1 |
| `net.inet.tcp.rledbat` | 1 |
| `net.inet.tcp.rtt_min` | 100 |
| `net.inet.tcp.rtt_recvbg` | 1 |
| `net.inet.tcp.rxt_seg_drop` | 0 |
| `net.inet.tcp.rxt_seg_max` | 1024 |
| `net.inet.tcp.sack_globalholes` | 0 |
| `net.inet.tcp.sack_globalmaxholes` | 65536 |
| `net.inet.tcp.sack_maxholes` | 128 |
| `net.inet.tcp.sack` | 1 |
| `net.inet.tcp.sendspace` | 131072 |
| `net.inet.tcp.slowlink_wsize` | 8192 |
| `net.inet.tcp.socket_unlocked_on_output` | 1 |
| `net.inet.tcp.tcbhashsize` | 4096 |
| `net.inet.tcp.tcp_resched_timerlist` | 17295926 |
| `net.inet.tcp.tcp_timer_advanced` | 30633 |
| `net.inet.tcp.timer_fastmode_idlemax` | 10 |
| `net.inet.tcp.tso_debug` | 0 |
| `net.inet.tcp.tso` | 1 |
| `net.inet.tcp.use_ledbat` | 0 |
| `net.inet.tcp.use_min_curr_rtt` | 1 |
| `net.inet.tcp.use_newreno` | 0 |
| `net.inet.tcp.v6mssdflt` | 1024 |
| `net.inet.tcp.win_scale_factor` | 3 |

https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/sysctl.3.html

https://calomel.org/freebsd_network_tuning.html

https://slaptijack.com/system-administration/mac-os-x-tcp-performance-tuning.html

https://www.nas.nasa.gov/hecc/support/kb/TCP-Performance-Tuning-for-WAN-Transfers_137.html

https://github.com/apple-oss-distributions/xnu/blob/e3723e1f17661b24996789d8afc084c0c3303b26/bsd/netinet/tcp_output.c#L287

## Erlang TCP/IP Stack Optimization

## Arweave TCP/IP Stack Optimization

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
