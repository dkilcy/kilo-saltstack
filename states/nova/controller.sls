#
#
#

{% from "mysql/map.jinja" import mysql with context %}

{% set nova_dbpass = salt['pillar.get']('openstack:auth:NOVA_DBPASS') %}
{% set mysql_host = salt['pillar.get']('openstack:controller:host') %}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pass') %}
{% set controller = salt['pillar.get']('openstack:controller:host') %}
{% set ipintf = salt['pillar.get']('openstack:controller:mgmt_intf') %}
{% set ip = salt['grains.get'](ipintf) %}

#
# Create the nova database
#

nova_db:
  mysql_database.present:
    - name: nova
    - host: {{ mysql_host }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

#
# Grant proper access to the nova database:
#

nova_grant_localhost:
  mysql_user.present:
    - name: nova
    - host: localhost
    - password: {{ nova_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: nova.*
    - user: nova
    - host: localhost
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

nova_grant_all:
  mysql_user.present:
    - name: nova
    - host: '%'
    - password: {{ nova_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: nova.*
    - user: nova
    - host: '%'
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

#
# Create the nova user:
#

create-nova-user:
  cmd.run:
    - name: openstack user create --password {{ salt['pillar.get']('openstack:auth:NOVA_PASS') }} nova
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack user show nova

#
# Add the admin role to the nova user and service project:
#

add-admin-role-to-nova:
  cmd.run:
    - name: openstack role add --project service --user nova admin
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3

#
# Create the nova service entity:
#

create-nova-service:
  cmd.run:
    - name: openstack service create --name nova --description "OpenStack Compute service" compute
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack service show compute

nova-service-endpoint:
  cmd.run:
    - name: 'openstack endpoint create --publicurl http://{{ controller }}:8774/v2/%\(tenant_id\)s --internalurl http://{{ controller }}:8774/v2/%\(tenant_id\)s --adminurl http://{{ controller }}:8774/v2/%\(tenant_id\)s  --region RegionOne compute'
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack endpoint show compute

#
# Install the packages:
#

nova-pkgs:
  pkg.installed:
    - pkgs:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-conductor
      - openstack-nova-console
      - openstack-nova-novncproxy
      - openstack-nova-scheduler
      - python-novaclient

/etc/nova/nova.conf:
    ini.options_present:
    - sections:
        DEFAULT:
          auth_strategy: keystone
          my_ip: {{ ip }}
          rpc_backend: rabbit
          verbose: True
          vncserver_listen: {{ ip }}
          vncserver_proxyclient_address: {{ ip }}
        database:
          connection: 'mysql://nova:{{ nova_dbpass }}@{{ mysql_host }}/nova'
        glance:
          host: {{ controller }}
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
          username: nova
          password: {{ salt['pillar.get']('openstack:auth:NOVA_PASS') }}
        oslo_concurrency:
          lock_path: /var/lib/nova/tmp

nova_db_sync:
  cmd.run:
    - name: /bin/nova-manage db sync
    - user: nova

nova-api-service:
  service.running:
    - name: openstack-nova-api
    - enable: True

nova-cert-service:
  service.running:
    - name: openstack-nova-cert
    - enable: True

nova-consoleauth-service:
  service.running:
    - name: openstack-nova-consoleauth
    - enable: True

nova-scheduler-service:
  service.running:
    - name: openstack-nova-scheduler
    - enable: True

nova-conductor-service:
  service.running:
    - name: openstack-nova-conductor
    - enable: True

nova-novncproxy-service:
  service.running:
    - name: openstack-nova-novncproxy
    - enable: True

