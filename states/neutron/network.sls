#
# http://docs.openstack.org/kilo/install-guide/install/yum/content/neutron-network-node.html
#
# Install and configure network node
#
# ...
#
# To configure prerequisites
#
# Before you install and configure OpenStack Networking, you must configure certain kernel networking parameters.
#
# 1. Edit the /etc/sysctl.conf file to contain the following parameters:
# 2. Implement the changes:
# 

{% from "mysql/map.jinja" import mysql with context %}

{% set neutron_dbpass = salt['pillar.get']('openstack:auth:NEUTRON_DBPASS') %}
{% set mysql_host = salt['pillar.get']('openstack:controller:host') %}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pass') %}
{% set controller = salt['pillar.get']('openstack:controller:host') %}
{% set ipintf = salt['pillar.get']('openstack:network:vm_intf') %}
{% set ip = salt['grains.get'](ipintf) %}
{% set metadata_secret = salt['pillar.get']('openstack:auth:METADATA_SECRET') %}

#

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - name: net.ipv4.conf.default.rp_filter
    - value: 0

net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - name: net.ipv4.conf.all.rp_filter
    - value: 0

net.ipv4.ip_forward:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1


#
# To install the Networking components
#

neutron-network-pkgs:
  pkg.installed:
    - pkgs:
      - openstack-neutron
      - openstack-neutron-ml2
      - openstack-neutron-openvswitch

#
# To configure the Networking common components
# ...
# Edit the /etc/neutron/neutron.conf file and complete the following actions:
#
# a. In the [database] section, comment out any connection options because network nodes do not directly access the database.
# b. In the [DEFAULT] and [oslo_messaging_rabbit] sections, configure RabbitMQ message queue access:
# c. In the [DEFAULT] and [keystone_authtoken] sections, configure Identity service access:
# d. In the [DEFAULT] section, enable the Modular Layer 2 (ML2) plug-in, router service, and overlapping IP addresses:
# e. (Optional) To assist with troubleshooting, enable verbose logging in the [DEFAULT] section:
# 

network-/etc/neutron/neutron.conf:
  ini.options_present:
    - name: /etc/neutron/neutron.conf
    - sections:
        DEFAULT:
          verbose: True
          rpc_backend: rabbit
          auth_strategy: keystone
          core_plugin: ml2
          service_plugins: router
          allow_overlapping_ips: True
        oslo_messaging_rabbit:
          rabbit_host: {{ controller }}
          rabbit_userid: {{ salt['pillar.get']('rabbitmq:user') }}
          rabbit_password: {{ salt['pillar.get']('rabbitmq:pass') }}
        keystone_authtoken:
          auth_uri: http://{{ controller }}:5000
          auth_url: http://{{ controller }}:35357
          auth_plugin: password
          project_domain_id: default
          user_domain_id: default
          project_name: service
          username: neutron
          password: {{ salt['pillar.get']('openstack:auth:NEUTRON_PASS') }}


#
# To configure the Modular Layer 2 (ML2) plug-in
# ...
# Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file and complete the following actions:
# a. In the [ml2] section, enable the flat, VLAN, generic routing encapsulation (GRE), and virtual extensible LAN (VXLAN) 
# network type drivers, GRE tenant networks, and the OVS mechanism driver:
# b,
# c,
# d.
# e.
# f
#

network-/etc/neutron/plugins/ml2/ml2_conf.ini:
  ini.options_present:
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
    - sections:
        ml2:
          type_drivers: flat,vlan,gre,vxlan
          tenant_network_types: gre
          mechanism_drivers: openvswitch
        ml2_type_flat:
          flat_networks: external
        ml2_type_gre:
          tunnel_id_ranges: '1:1000'
        securitygroups:
          enable_security_group: True
          enable_ipset: True
          firewall_driver: neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
        ovs:
          local_ip: {{ ip }}
          bridge_mappings: 'external:br-ex'
        agent:
          tunnel_types: gre

#
# To configure the Layer-3 (L3) agent
# ...
# Edit the /etc/neutron/l3_agent.ini file and complete the following actions:
# a. In the [DEFAULT] section, configure the interface driver, external network bridge, and enable deletion of defunct router namespaces:
# b.
#

network-/etc/neutron/l3_agent.ini:
  ini.options_present:
    - name: /etc/neutron/l3_agent.ini
    - sections:
        DEFAULT:
          verbose: True
          interface_driver: neutron.agent.linux.interface.OVSInterfaceDriver
          external_network_bridge: ''
          router_delete_namespaces: True

#
# To configure the DHCP agent
# ...
# 1. Edit the /etc/neutron/dhcp_agent.ini file and complete the following actions:
# a. In the [DEFAULT] section, configure the interface and DHCP drivers and enable deletion of defunct DHCP namespaces:
# b. Optional) To assist with troubleshooting, enable verbose logging in the [DEFAULT] section:
#

network-/etc/neutron/dhcp_agent.ini:
  ini.options_present:
    - name: /etc/neutron/dhcp_agent.ini
    - sections:
        DEFAULT:
          verbose: True
          interface_driver: neutron.agent.linux.interface.OVSInterfaceDriver
          dhcp_driver: neutron.agent.linux.dhcp.Dnsmasq
          dhcp_delete_namespaces: True

#
# To configure the metadata agent
#

network-/etc/neutron/metadata_agent.ini:
  ini.options_present:
    - name: /etc/neutron/metadata_agent.ini
    - sections:
        DEFAULT:
          verbose: True
          nova_metadata_ip: {{ controller }}
          metadata_proxy_shared_secret: {{ metadata_secret }}
          auth_uri: http://{{ controller }}:5000
          auth_url: http://{{ controller }}:35357
          auth_region: RegionOne
          auth_plugin: password
          project_domain_id: default
          user_domain_id: default
          project_name: service
          username: neutron
          password: {{ salt['pillar.get']('openstack:auth:NEUTRON_PASS') }}
      
#
# To configure the Open vSwitch (OVS) service
# ..
# 1. Start the OVS service and configure it to start when the system boots:
# 2. Add the external bridge:
# 3. Add a port to the external bridge that connects to the physical external network interface:

openvswitch-service:
  service.running:
    - name: openvswitch
    - enable: True

#
# To finalize the installation
#
# 1. The Networking service initialization scripts expect a symbolic link 
# /etc/neutron/plugin.ini pointing to the ML2 plug-in configuration file, 
# /etc/neutron/plugins/ml2/ml2_conf.ini. 
#
# Due to a packaging bug, the Open vSwitch agent initialization script explicitly looks for the Open vSwitch 
# plug-in configuration file rather than a symbolic link /etc/neutron/plugin.ini pointing to the ML2 plug-in configuration file.
#

network-/etc/neutron/plugin.ini:
  file.symlink:
    - name: /etc/neutron/plugin.ini
    - target: /etc/neutron/plugins/ml2/ml2_conf.ini
           
neutron_network_neutron_openvswitch_agent:
  file.replace:
    - name: /usr/lib/systemd/system/neutron-openvswitch-agent.service
    - pattern: plugins/openvswitch/ovs_neutron_plugin.ini
    - repl: plugin.ini

#
# 2. Start the Networking services and configure them to start when the system boots:
#

compute_openvswitch_agent_service_start:
  service.running:
    - name: neutron-openvswitch-agent
    - enable: True

compute_l3_agent_service_start:
  service.running:
    - name: neutron-l3-agent
    - enable: True

compute_dhcp_agent_service_start:
  service.running:
    - name: neutron-dhcp-agent
    - enable: True

compute_metadata_agent_service_start:
  service.running:
    - name: neutron-metadata-agent
    - enable: True


