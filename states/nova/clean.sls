{% from "mysql/map.jinja" import mysql with context %}

{% set nova_dbpass = salt['pillar.get']('openstack:auth:NOVA_DBPASS') %}
{% set mysql_host = salt['pillar.get']('openstack:controller:host') %}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pass') %}
{% set controller = salt['pillar.get']('openstack:controller:host') %}

openstack-nova-api-dead:
  service.dead:
    - name: openstack-nova-api

openstack-nova-cert-dead:
  service.dead:
    - name: openstack-nova-cert

openstack-nova-consoleauth-dead:
  service.dead:
    - name: openstack-nova-consoleauth

openstack-nova-scheduler-dead:
  service.dead:
    - name: openstack-nova-scheduler

openstack-nova-conductor-dead:
  service.dead:
    - name: openstack-nova-conductor

openstack-nova-novncproxy-dead:
  service.dead:
    - name: openstack-nova-novncproxy

nova-controller-purged-pkgs:
  pkg.purged:
    - pkgs:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-conductor
      - openstack-nova-console
      - openstack-nova-novncproxy
      - openstack-nova-scheduler
      - python-novaclient

clean-neutron-logs:
  file.directory:
    - name: /var/log/neutron
    - clean: True

clean-openvswitch-logs:
  file.directory:
    - name: /var/log/openvswitch
    - clean: True

clean-nova-logs:
  file.directory:
    - name: /var/log/nova
    - clean: True

clean-/etc/nova:
  file.directory:
    - name: /etc/nova
    - clean: True

clean-/etc/neutron:
  file.directory:
    - name: /etc/network
    - clean: True

nova_grant_localhost-absent:
  mysql_user.absent:
    - name: nova
    - host: localhost
    - password: {{ nova_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

  mysql_grants.absent:
    - grant: all privileges
    - database: nova.*
    - user: nova
    - host: localhost
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

nova_grant_all-absent:
  mysql_user.absent:
    - name: nova
    - host: '%'
    - password: {{ nova_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

  mysql_grants.absent:
    - grant: all privileges
    - database: nova.*
    - user: nova
    - host: '%'
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8

drop-nova-database:
  mysql_database.absent:
    - name: nova
    - host: {{ mysql_host }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8


