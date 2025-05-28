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
net.ipv4.tcp_tw_reuse=1
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

### MacOS/X TCP/IP Stack Optimization

```sh
```

https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/sysctl.3.html

https://calomel.org/freebsd_network_tuning.html

https://slaptijack.com/system-administration/mac-os-x-tcp-performance-tuning.html

https://www.nas.nasa.gov/hecc/support/kb/TCP-Performance-Tuning-for-WAN-Transfers_137.html

## Workarounds

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
