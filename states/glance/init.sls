{% from "mysql/map.jinja" import mysql with context %}

{% set glance_dbpass = salt['pillar.get']('openstack:auth:GLANCE_DBPASS') %}
{% set mysql_host = salt['pillar.get']('openstack:controller:host') %}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pass') %}

#
# Create the glance database
#

glance_db:
  mysql_database.present:
    - name: glance
    - host: {{ mysql_host }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

#
# Grant proper access to the glance database:
#

glance_grant_localhost:
  mysql_user.present:
    - name: glance
    - host: localhost
    - password: {{ glance_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - user: glance
    - host: localhost
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

glance_grant_all:
  mysql_user.present:
    - name: glance
    - host: '%'
    - password: {{ glance_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - user: glance
    - host: '%'
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

#
# Create the glance user:
#

{% set controller = salt['pillar.get']('openstack:controller:host') %}

create-glance-user:
  cmd.run:
    - name: openstack user create --password {{ salt['pillar.get']('openstack:auth:GLANCE_PASS') }} glance
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack user show glance

#
# Add the admin role to the glance user and service project:
#

add-admin-role-to-glance:
  cmd.run:
    - name: openstack role add --project service --user glance admin
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3

#
# Create the glance service entity:
#

create-glance-service:
  cmd.run:
    - name: openstack service create --name glance --description "OpenStack Image service" image
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack service show image

glance-service-endpoint:
  cmd.run:
    - name: 'openstack endpoint create --publicurl http://{{ controller }}:9292 --internalurl http://{{ controller }}:9292 --adminurl http://{{ controller }}:9292  --region RegionOne image'
    - env:
      - OS_PROJECT_DOMAIN_ID: default
      - OS_USER_DOMAIN_ID: default
      - OS_PROJECT_NAME: admin
      - OS_TENANT_NAME: admin
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
      - OS_AUTH_URL: http://{{ controller }}:35357/v3
    - unless:
      - openstack endpoint show image

#
# Install the packages:
#

glance-pkgs:
  pkg.installed:
    - pkgs:
      - openstack-glance
      - python-glance
      - python-glanceclient

/etc/glance/glance-api.conf:
    ini.options_present:
    - sections:
        DEFAULT:
          notification_driver: noop
          verbose: True
        database:
          connection: 'mysql://glance:{{ glance_dbpass }}@{{ mysql_host }}/glance'
        keystone_authtoken:
          auth_uri: http://{{ controller }}:5000
          auth_url: http://{{ controller }}:35357
          auth_plugin: password
          project_domain_id: default
          user_domain_id: default
          project_name: service
          username: glance
          password: {{ salt['pillar.get']('openstack:auth:GLANCE_PASS') }}
        paste_deploy:
          flavor: keystone
        glance_store:
          default_store: file
          filesystem_store_datadir: /var/lib/glance/images

/etc/glance/glance-registry.conf:
    ini.options_present:
    - sections:
        DEFAULT:
          notification_driver: noop
          verbose: True
        database:
          connection: mysql://glance:{{ glance_dbpass }}@{{ mysql_host }}/glance
        keystone_authtoken:
          auth_uri: http://{{ controller }}:5000
          auth_url: http://{{ controller }}:35357
          auth_plugin: password
          project_domain_id: default
          user_domain_id: default
          project_name: service
          username: glance
          password: {{ salt['pillar.get']('openstack:auth:GLANCE_PASS') }}
        paste_deploy:
          flavor: keystone

glance_db_sync:
  cmd.run:
    - name: /bin/glance-manage db_sync
    - user: glance

glance-api-service:
  service.running:
    - name: openstack-glance-api
    - enable: True

glance-registry-service:
  service.running:
    - name: openstack-glance-registry
    - enable: True


