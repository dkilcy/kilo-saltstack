#
# http://docs.openstack.org/kilo/install-guide/install/yum/content/neutron-controller-node.html
# 
# Install and configure controller node
# ...
# Before you configure the OpenStack Networking (neutron) service, you must create a database, service credentials, and API endpoint.
#

{% from "mysql/map.jinja" import mysql with context %}

{% set neutron_dbpass = salt['pillar.get']('openstack:auth:NEUTRON_DBPASS') %}
{% set mysql_host = salt['pillar.get']('openstack:controller:host') %}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pass') %}
{% set controller = salt['pillar.get']('openstack:controller:host') %}
{% set metadata_secret = salt['pillar.get']('openstack:auth:METADATA_SECRET') %}

neutron_db:
  mysql_database.present:
    - name: neutron
    - host: {{ mysql_host }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

#
# Grant proper access to the neutron database:
#

neutron_grant_localhost:
  mysql_user.present:
    - name: neutron
    - host: localhost
    - password: {{ neutron_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: localhost
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

neutron_grant_all:
  mysql_user.present:
    - name: neutron
    - host: '%'
    - password: {{ neutron_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: '%'
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

#
# Create the neutron user:
#

create-neutron-user:
  cmd.run:
    - name: openstack user create --password {{ salt['pillar.get']('openstack:auth:NEUTRON_PASS') }} neutron
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack user show neutron

#
# Add the admin role to the neutron user and service project:
#

add-admin-role-to-neutron:
  cmd.run:
    - name: openstack role add --project service --user neutron admin
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3

#
# Create the neutron service entity:
#

create-neutron-service:
  cmd.run:
    - name: openstack service create --name neutron --description "OpenStack Networking" network
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack service show network

#
# 4. Create the Networking service API endpoint:
#

neutron-service-endpoint:
  cmd.run:
    - name: 'openstack endpoint create --publicurl http://{{ controller }}:9696 --internalurl http://{{ controller }}:9696 --adminurl http://{{ controller }}:9696  --region RegionOne network'
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack endpoint show network

#
# To install the Networking components:

neutron-controller-pkgs:
  pkg.installed:
    - pkgs:
      - openstack-neutron
      - openstack-neutron-ml2
      - python-neutronclient
      - which

#
# To configure the Networking server component
# ...
# Edit the /etc/neutron/neutron.conf file and complete the following actions:
# a. In the [database] section, configure database access:
# b. In the [DEFAULT] and [oslo_messaging_rabbit] sections, configure RabbitMQ message queue access:
# c. In the [DEFAULT] and [keystone_authtoken] sections, configure Identity service access:
#    Comment out or remove any other options in the [keystone_authtoken] section.
# d. In the [DEFAULT] section, enable the Modular Layer 2 (ML2) plug-in, router service, and overlapping IP addresses:
# e. In the [DEFAULT] and [nova] sections, configure Networking to notify Compute of network topology changes:
# f. (Optional) To assist with troubleshooting, enable verbose logging in the [DEFAULT] section:
#
  
/etc/neutron/neutron.conf:
    ini.options_present:
    - sections:
        DEFAULT:
          verbose: True
          rpc_backend: rabbit
          auth_strategy: keystone
          core_plugin: ml2
          service_plugins: router
          allow_overlapping_ips: True
          notify_nova_on_port_status_changes: True
          notify_nova_on_port_data_changes: True
          nova_url: http://{{ controller }}:8774/v2
        nova:
          auth_url: http://{{ controller }}:35357
          auth_plugin: password
          project_domain_id: default
          user_domain_id: default
          region_name: RegionOne
          project_name: service
          username: nova
          password: {{ salt['pillar.get']('openstack:auth:NOVA_PASS') }}
        database:
          connection: 'mysql://neutron:{{ neutron_dbpass }}@{{ mysql_host }}/neutron'
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
#
#
# Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file and complete the following actions:
#
# a. In the [ml2] section, enable the flat, VLAN, generic routing encapsulation (GRE), and virtual extensible LAN (VXLAN) network type drivers, GRE tenant networks, and the OVS mechanism driver:
# b. In the [ml2_type_gre] section, configure the tunnel identifier (id) range:
# c. In the [securitygroup] section, enable security groups, enable ipset, and configure the OVS iptables firewall driver: 
#

/etc/neutron/plugins/ml2/ml2_conf.ini:
  ini.options_present:
  - sections:
      ml2:
        type_drivers: flat,vlan,gre,vxlan
        tenant_network_types: gre
        mechanism_drivers: openvswitch
      ml2_type_gre:
        tunnel_id_ranges: '1:1000'
      securitygroups:
        enable_security_group: True
       
#
# To configure Compute to use Networking
#
# Edit the /etc/nova/nova.conf file on the controller node and complete the following actions:
# a. In the [DEFAULT] section, configure the APIs and drivers:
# b. In the [neutron] section, configure access parameters:
#

neutron-/etc/nova/nova.conf:
  ini.options_present:
  - name: /etc/nova/nova.conf
  - sections:
      DEFAULT:
        network_api_class: nova.network.neutronv2.api.API
        security_group_api: neutron
        linuxnet_interface_drver: nova.network.linux_net.LinuxOVSInterfaceDriver
        firewall_driver: nova.virt.firewall.NoopFirewallDriver
      neutron:
        url: http://{{ controller }}:9696
        auth_strategy: keystone
        admin_auth_url: http://{{ controller }}:35357/v2.0
        admin_tenant_name: service
        admin_username: neutron
        admin_password: {{ salt['pillar.get']('openstack:auth:NEUTRON_PASS') }} 
        service_metadata_proxy: True
        metadata_proxy_shared_secret: {{ metadata_secret }}

#
# To finalize installation
#
# 1. The Networking service initialization scripts expect a symbolic link 
# /etc/neutron/plugin.ini pointing to the ML2 plug-in configuration file, 
# /etc/neutron/plugins/ml2/ml2_conf.ini. 
#

/etc/neutron/plugin.ini:
  file.symlink:
    - name: /etc/neutron/plugin.ini
    - target: /etc/neutron/plugins/ml2/ml2_conf.ini

# 2. Populate the database:
# Database population occurs later for Networking because the script requires complete server and plug-in configuration files.
#

neutron_db_sync:
  cmd.run:
    - name: /bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head
    - user: neutron

# 3. Restart the Compute services:

# 4. Start the Networking service and configure it to start when the system boots:

neutron-server-service:
  service.running:
    - name: neutron-server
    - enable: True


