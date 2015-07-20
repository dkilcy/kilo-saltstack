### Salt tools for OpenStack Kilo

Install OpenStack Kilo in a 3+ node architecture with neutron networking on CentOS 7 using SaltStack.

#### Introduction

![Node Deployment](notes/node-deployment.png "Node Deployment")

##### Repository Contents

- states: SaltStack state files  
- pillar: SaltStack pillar data  
- notes : Documentation and sample configuration files  

#### Prerequesites

- Salt Master is installed on the utility (workstation) node.
- Salt Minion is installed on all OpenStack nodes. 
- SELinux is disabled on all nodes.
- NTP time service is running and all times are in sync

Instruction on how to [Setup Salt Master and Minions](https://github.com/dkilcy/saltstack-base/blob/master/notes/setup-salt.md)

Related repositories: 
- [Salt Tools for bare-metal provisioning](https://github.com/dkilcy/saltstack-base)


### Update Salt Master

1. Create /etc/salt/master.d/99-salt-envs.conf

```yaml
file_roots:
  base:
    - /srv/salt/base/states
  openstack:
    - /srv/salt/openstack/states
 
pillar_roots:
  base:
    - /srv/salt/base/pillar
  openstack:
    - /srv/salt/openstack/pillar
```

2. Point Salt to the git repository: `ln -sf ~/git/kilo-saltstack /srv/salt/openstack`
3. Restart the Salt Master: `systemctl restart salt-master.service`

### Update Salt Minions

From the Salt master:

1. Test connectivity to the pillars: `salt '*' test.ping`
2. Set the grains for each machine

 ```bash
salt 'controller*' grains.setvals "{'kilo-saltstack':{'role':'controller'}}"
salt 'compute*' grains.setvals "{'kilo-saltstack':{'role':'compute'}}"
salt 'network*' grains.setvals "{'kilo-saltstack':{'role':'network'}}"
```

3. Refresh and sync the minions:

 ```bash
salt '*' saltutil.refresh_pillar
salt '*' saltutil.sync_all
```

### OpenStack Kilo Setup

1. Run highstate against the controller nodes.

Perform these steps **on the Salt master**
 ```
salt -G 'kilo-saltstack:role:controller' test.ping
salt -G 'kilo-saltstack:role:controller' state.highstate --state-output=mixed
```
2. Verify the controller services setup.

Perform these steps **on the controller node.**
 ```
cd /home/devops/kilo-saltstack
source auth-openrc.sh
source admin-openrc.sh
```
```
mkdir /tmp/images
wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
glance image-create --name "cirros-0.3.4-x86_64" --file /tmp/images/cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare --visibility public --progress
glance image-list
```
```
nova service-list
nova endpoints
nova image-list
```
```
neutron ext-list
neutron agent-list
 ```
3. Run highstate against the network nodes.

Perform these steps **on the Salt master.**
 ```
salt -G 'kilo-saltstack:role:network' test.ping
salt -G 'kilo-saltstack:role:network' state.highstate --state-output=mixed
```
4.  Configure the Open vSwtich (OVS) service on the network nodes.

Perform these steps on **the network nodes.**

5. Create the initial networks.

Perform these steps **on the controller node.***

a. Source the admin credentials to gain access to admin-only CLI commands:
b. Create the network 
 ```
neutron net-create ext-net --router:external \
 --provider:physical_network external --provider:network_type flat
```

Create the subnet
```
neutron subnet-create ext-net 192.168.1.0/24 --name ext-subnet \
--allocation-pool start=192.168.1.200,end=192.168.1.224 \
--disable-dhcp --gateway 192.168.1.1
```

6. Create the tenant network

```
source demo-openrc.sh
```
```
neutron net-create demo-net
neutron subnet-create demo-net 172.16.1.0/24 \
--name demo-subnet --gateway 172.16.1.1
neutron router-create demo-router
neutron router-interface-add demo-router demo-subnet
neutron router-gateway-set demo-router ext-net
```

7. From a host on the the external network, ping the tenant router gateway:

```
ping -c 4 192.168.1.200
```

##### References
- [OpenStack Installation Guide for Red Hat Enterprise Linux 7, CentOS 7, and Fedora 21 ](http://docs.openstack.org/kilo/install-guide/install/yum/content/)
