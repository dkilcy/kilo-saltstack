
### Configure Open vSwitch (OVS) service

Reference: 
- [http://docs.openstack.org/kilo/install-guide/install/yum/content/neutron-network-node.html](http://docs.openstack.org/kilo/install-guide/install/yum/content/neutron-network-node.html)


```
[root@network1 ~]$ ovs-vsctl show
ovs-vsctl: unix:/var/run/openvswitch/db.sock: database connection failed (No such file or directory)
[root@network1 ~]$ 
[root@network1 ~]$ systemctl start openvswitch.service
[root@network1 ~]$ ovs-vsctl show
96a02b11-1850-4b32-95bc-4b2340ba0328
    ovs_version: "2.3.1"
[root@network1 ~]$ ovs-vsctl add-br br-ex
[root@network1 ~]$ ovs-vsctl show
96a02b11-1850-4b32-95bc-4b2340ba0328
    Bridge br-ex
        Port br-ex
            Interface br-ex
                type: internal
    ovs_version: "2.3.1"
[root@network1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp4s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 68:05:ca:24:7b:02 brd ff:ff:ff:ff:ff:ff
3: enp0s20f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq master team0 state UP qlen 1000
    link/ether 0c:c4:7a:31:24:08 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ec4:7aff:fe31:2408/64 scope link 
       valid_lft forever preferred_lft forever
4: enp0s20f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 9000 qdisc mq master team0 state DOWN qlen 1000
    link/ether 0c:c4:7a:31:24:08 brd ff:ff:ff:ff:ff:ff
5: enp0s20f2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq master team1 state UP qlen 1000
    link/ether 0c:c4:7a:31:24:0a brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ec4:7aff:fe31:240a/64 scope link 
       valid_lft forever preferred_lft forever
6: enp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq master team1 state UP qlen 1000
    link/ether 0c:c4:7a:31:24:0a brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ec4:7aff:fe31:240a/64 scope link 
       valid_lft forever preferred_lft forever
7: team0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP 
    link/ether 0c:c4:7a:31:24:08 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.21/24 brd 10.0.0.255 scope global team0
       valid_lft forever preferred_lft forever
    inet6 fe80::ec4:7aff:fe31:2408/64 scope link 
       valid_lft forever preferred_lft forever
8: team1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP 
    link/ether 0c:c4:7a:31:24:0a brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.21/24 brd 10.0.1.255 scope global team1
       valid_lft forever preferred_lft forever
    inet6 fe80::ec4:7aff:fe31:240a/64 scope link tentative dadfailed 
       valid_lft forever preferred_lft forever
9: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN 
    link/ether 02:49:42:2b:3d:21 brd ff:ff:ff:ff:ff:ff
10: br-ex: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN 
    link/ether 5e:2e:94:c9:16:4e brd ff:ff:ff:ff:ff:ff
[root@network1 ~]$ ovs-vsctl add-port br-ex enp4s0
[root@network1 ~]$ ovs-vsctl show
96a02b11-1850-4b32-95bc-4b2340ba0328
    Bridge br-ex
        Port br-ex
            Interface br-ex
                type: internal
        Port "enp4s0"
            Interface "enp4s0"
    ovs_version: "2.3.1"
[root@network1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp4s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master ovs-system state DOWN qlen 1000
    link/ether 68:05:ca:24:7b:02 brd ff:ff:ff:ff:ff:ff
3: enp0s20f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq master team0 state UP qlen 1000
    link/ether 0c:c4:7a:31:24:08 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ec4:7aff:fe31:2408/64 scope link 
       valid_lft forever preferred_lft forever
4: enp0s20f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 9000 qdisc mq master team0 state DOWN qlen 1000
    link/ether 0c:c4:7a:31:24:08 brd ff:ff:ff:ff:ff:ff
5: enp0s20f2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq master team1 state UP qlen 1000
    link/ether 0c:c4:7a:31:24:0a brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ec4:7aff:fe31:240a/64 scope link 
       valid_lft forever preferred_lft forever
6: enp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq master team1 state UP qlen 1000
    link/ether 0c:c4:7a:31:24:0a brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ec4:7aff:fe31:240a/64 scope link 
       valid_lft forever preferred_lft forever
7: team0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP 
    link/ether 0c:c4:7a:31:24:08 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.21/24 brd 10.0.0.255 scope global team0
       valid_lft forever preferred_lft forever
    inet6 fe80::ec4:7aff:fe31:2408/64 scope link 
       valid_lft forever preferred_lft forever
8: team1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP 
    link/ether 0c:c4:7a:31:24:0a brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.21/24 brd 10.0.1.255 scope global team1
       valid_lft forever preferred_lft forever
    inet6 fe80::ec4:7aff:fe31:240a/64 scope link tentative dadfailed 
       valid_lft forever preferred_lft forever
9: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN 
    link/ether 02:49:42:2b:3d:21 brd ff:ff:ff:ff:ff:ff
10: br-ex: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN 
    link/ether 68:05:ca:24:7b:02 brd ff:ff:ff:ff:ff:ff
[root@network1 ~]$ ls -l /etc/neutron/plugin.ini
lrwxrwxrwx 1 root root 37 Jul 19 20:35 /etc/neutron/plugin.ini -> /etc/neutron/plugins/ml2/ml2_conf.ini
[root@network1 ~]$ systemctl start neutron-openvswitch-agent.service neutron-l3-agent.service \
>   neutron-dhcp-agent.service neutron-metadata-agent.service
[root@network1 ~]$ 
[root@network1 ~]$ 
[root@network1 ~]$ systemctl status neutron-openvswitch-agent.service neutron-l3-agent.service   neutron-dhcp-agent.service neutron-metadata-agent.service
neutron-openvswitch-agent.service - OpenStack Neutron Open vSwitch Agent
   Loaded: loaded (/usr/lib/systemd/system/neutron-openvswitch-agent.service; disabled)
   Active: active (running) since Sun 2015-07-19 20:46:32 UTC; 21s ago
 Main PID: 4931 (neutron-openvsw)
   CGroup: /system.slice/neutron-openvswitch-agent.service
           ├─4931 /usr/bin/python2 /usr/bin/neutron-openvswitch-agent --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutr...
           ├─5101 sudo neutron-rootwrap /etc/neutron/rootwrap.conf ovsdb-client monitor Interface name,ofport --format=json
           ├─5103 /usr/bin/python2 /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovsdb-client monitor Interface name,ofport --format=json
           └─5105 /bin/ovsdb-client monitor Interface name,ofport --format=json

Jul 19 20:46:39 network1 sudo[5110]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-vsctl --timeout=10 --oneline -...-ex patch-tun
Jul 19 20:46:39 network1 sudo[5113]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-vsctl --timeout=10 --oneline -...-ports br-int
Jul 19 20:46:39 network1 sudo[5116]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-vsctl --timeout=10 --oneline -...-ex patch-tun
Jul 19 20:46:40 network1 sudo[5119]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-ofctl dump-flows br-int table=23
Jul 19 20:46:42 network1 sudo[5122]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-ofctl dump-flows br-int table=23
Jul 19 20:46:44 network1 sudo[5125]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-ofctl dump-flows br-int table=23
Jul 19 20:46:46 network1 sudo[5128]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-ofctl dump-flows br-int table=23
Jul 19 20:46:48 network1 sudo[5132]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-ofctl dump-flows br-int table=23
Jul 19 20:46:50 network1 sudo[5135]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-ofctl dump-flows br-int table=23
Jul 19 20:46:52 network1 sudo[5138]: neutron : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/neutron-rootwrap /etc/neutron/rootwrap.conf ovs-ofctl dump-flows br-int table=23

neutron-l3-agent.service - OpenStack Neutron Layer 3 Agent
   Loaded: loaded (/usr/lib/systemd/system/neutron-l3-agent.service; disabled)
   Active: active (running) since Sun 2015-07-19 20:46:32 UTC; 21s ago
 Main PID: 4932 (neutron-l3-agen)
   CGroup: /system.slice/neutron-l3-agent.service
           └─4932 /usr/bin/python2 /usr/bin/neutron-l3-agent --config-file /usr/share/neutron/neutron-dist.conf --config-dir /usr/share/neutron/l3_agent --config-file /etc/neutron/neutr...

Jul 19 20:46:32 network1 systemd[1]: Starting OpenStack Neutron Layer 3 Agent...
Jul 19 20:46:32 network1 systemd[1]: Started OpenStack Neutron Layer 3 Agent.

neutron-dhcp-agent.service - OpenStack Neutron DHCP Agent
   Loaded: loaded (/usr/lib/systemd/system/neutron-dhcp-agent.service; disabled)
   Active: active (running) since Sun 2015-07-19 20:46:32 UTC; 21s ago
 Main PID: 4933 (neutron-dhcp-ag)
   CGroup: /system.slice/neutron-dhcp-agent.service
           └─4933 /usr/bin/python2 /usr/bin/neutron-dhcp-agent --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/dhcp...

Jul 19 20:46:32 network1 systemd[1]: Starting OpenStack Neutron DHCP Agent...
Jul 19 20:46:32 network1 systemd[1]: Started OpenStack Neutron DHCP Agent.

neutron-metadata-agent.service - OpenStack Neutron Metadata Agent
   Loaded: loaded (/usr/lib/systemd/system/neutron-metadata-agent.service; disabled)
   Active: active (running) since Sun 2015-07-19 20:46:32 UTC; 21s ago
 Main PID: 4934 (neutron-metadat)
   CGroup: /system.slice/neutron-metadata-agent.service
           ├─4934 /usr/bin/python2 /usr/bin/neutron-metadata-agent --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/...
           ├─4961 /usr/bin/python2 /usr/bin/neutron-metadata-agent --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/...
           ├─4962 /usr/bin/python2 /usr/bin/neutron-metadata-agent --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/...
           ├─4963 /usr/bin/python2 /usr/bin/neutron-metadata-agent --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/...
           └─4964 /usr/bin/python2 /usr/bin/neutron-metadata-agent --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/...

Jul 19 20:46:32 network1 systemd[1]: Starting OpenStack Neutron Metadata Agent...
Jul 19 20:46:32 network1 systemd[1]: Started OpenStack Neutron Metadata Agent.
Hint: Some lines were ellipsized, use -l to show in full.
[root@network1 ~]$ ovs-vsctl show
96a02b11-1850-4b32-95bc-4b2340ba0328
    Bridge br-int
        fail_mode: secure
        Port br-int
            Interface br-int
                type: internal
        Port int-br-ex
            Interface int-br-ex
                type: patch
                options: {peer=phy-br-ex}
        Port patch-tun
            Interface patch-tun
                type: patch
                options: {peer=patch-int}
    Bridge br-tun
        fail_mode: secure
        Port patch-int
            Interface patch-int
                type: patch
                options: {peer=patch-tun}
        Port br-tun
            Interface br-tun
                type: internal
    Bridge br-ex
        Port phy-br-ex
            Interface phy-br-ex
                type: patch
                options: {peer=int-br-ex}
        Port br-ex
            Interface br-ex
                type: internal
        Port "enp4s0"
            Interface "enp4s0"
    ovs_version: "2.3.1"
[root@network1 ~]$ 
```
