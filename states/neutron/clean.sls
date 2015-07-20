{% from "mysql/map.jinja" import mysql with context %}

{% set neutron_dbpass = salt['pillar.get']('openstack:auth:NEUTRON_DBPASS') %}
{% set nova_dbpass = salt['pillar.get']('openstack:auth:NOVA_DBPASS') %}
{% set mysql_host = salt['pillar.get']('openstack:controller:host') %}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pass') %}
{% set controller = salt['pillar.get']('openstack:controller:host') %}

openvswitch-service-dead:
  service.dead:
    - name: openvswitch

neutron-dhcp-agent-dead:
  service.dead:
    - name: neutron-dhcp-agent

neutron-l3-agent-dead:
  service.dead:
    - name: neutron-l3-agent

neutron-metadata-agent-dead:
  service.dead:
    - name: neutron-metadata-agent

neutron-openvswitch-agent:
  service.dead:
    - name: neutron-openvswitch-agent

neutron-network-purged-pkgs:
  pkg.purged:
    - pkgs:
      - openstack-neutron
      - openstack-neutron-ml2
      - openstack-neutron-openvswitch
      - openvswitch

neutron-server-service-dead:
  service.dead:
    - name: neutron-server

neutron-controller-purged-pkgs:
  pkg.purged:
    - pkgs:
      - openstack-neutron
      - openstack-neutron-ml2
      - python-neutronclient

clean-neutron-logs:
  file.directory:
    - name: /var/log/neutron
    - clean: True

clean-openvswitch-logs:
  file.directory:
    - name: /var/log/openvswitch
    - clean: True

clean-/etc/neutron:
  file.directory:
    - name: /etc/network
    - clean: True

neutron_grant_localhost-absent:
  mysql_user.absent:
    - name: neutron
    - host: localhost
    - password: {{ neutron_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

  mysql_grants.absent:
    - database: neutron.*
    - user: neutron
    - host: localhost
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

neutron_grant_all-absent:
  mysql_user.absent:
    - name: neutron
    - host: '%'
    - password: {{ neutron_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

  mysql_grants.absent:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: '%'
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

drop-neutron-database:
  mysql_database.absent:
    - name: neutron
    - host: {{ mysql_host }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

