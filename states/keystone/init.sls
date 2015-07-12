{% from "mysql/map.jinja" import mysql with context %}

{% set keystone_dbpass = salt['pillar.get']('openstack:auth:KEYSTONE_DBPASS') %}
{% set mysql_host = salt['pillar.get']('openstack:controller:host') %}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pass') %}

#
# Create the keystone database
#

keystone_db:
  mysql_database.present:
    - name: keystone
    - host: {{ mysql_host }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

# 
# Grant proper access to the keystone database:
#

keystone_grant_localhost:
  mysql_user.present:
    - name: keystone
    - host: localhost
    - password: {{ keystone_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: localhost
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

keystone_grant_all:
  mysql_user.present:
    - name: keystone
    - host: '%'
    - password: {{ keystone_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: '%'
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
#      - pkg: {{ mysql.python }}

#
# Install identity services
#

{% set admin_token = salt['pillar.get']('openstack:keystone:admin_token') %}

keystone-pkgs:
  pkg.installed:
    - pkgs:
      - openstack-keystone
      - httpd
      - mod_wsgi
      - python-openstackclient
      - memcached
      - python-memcached

#
# Start the Memcached service and configure it to start when the system boots:
#

memcached-service:
  service.running:
    - name: memcached
    - enable: True

#
# Edit the /etc/keystone/keystone.conf file and complete the following actions:
#

/etc/keystone/keystone.conf:
  ini.options_present:
    - sections:
        DEFAULT:
          admin_token: {{ admin_token }}
          verbose: True
        database:
          connection: 'mysql://keystone:{{ keystone_dbpass }}@{{ mysql_host }}/keystone'
        memcache:
          servers: 'localhost:11211'
        token:
          driver: keystone.token.persistence.backends.memcache.Token
          provider: keystone.token.providers.uuid.Provider
        revoke:
          driver: keystone.contrib.revoke.backends.sql.Revoke

#
# Populate the Identity service database:
#

{% set controller = salt['pillar.get']('openstack:controller:host') %}

keystone_db_sync:
  cmd.run:
    - name: /bin/keystone-manage db_sync
    - user: keystone

/etc/httpd/conf/httpd.conf:
  file.replace:
    - name: /etc/httpd/conf/httpd.conf
    - pattern: '#ServerName www.example.com:80'
    - repl: 'ServerName {{ controller }}'

/etc/httpd/conf.d/wsgi-keystone.conf:
  file.managed:
    - name: /etc/httpd/conf.d/wsgi-keystone.conf
    - source: salt://keystone/files/wsgi-keystone.conf

/var/www/cgi-bin/keystone:
  file.directory:
    - name: /var/www/cgi-bin/keystone
    - mkdirs: True
    - user: keystone
    - group: keystone
    - mode: 755

/var/www/cgi-bin/keystone/main:
  file.managed:
    - name: /var/www/cgi-bin/keystone/main
    - source: salt://keystone/files/keystone.py

/var/www/cgi-bin/keystone/admin:
  file.managed:
    - name: /var/www/cgi-bin/keystone/admin
    - source: salt://keystone/files/keystone.py


httpd-service:
  service.running:
    - name: httpd
    - enable: True

#
# Create the service entity for the Identity service:
#

keystone-identity-service:
  cmd.run:
    - name: 'openstack service create --name keystone --description "OpenStack Identity" identity'
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack service show identity

#
# Create the Identity service API endpoint:
#
 
keystone-service-endpoint:
  cmd.run:
    - name: 'openstack endpoint create --publicurl http://{{ controller }}:5000/v2.0 --internalurl http://{{ controller }}:5000/v2.0 --adminurl http://{{ controller }}:35357/v2.0  --region RegionOne identity'
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack endpoint show identity

#
# Create the admin project:
#

create-admin-project:
  cmd.run:
    - name: 'openstack project create --description "Admin Project" admin'
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack project show admin

#
# Create the admin user:
#

create-admin-user:
  cmd.run:
    - name: openstack user create --password {{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }} admin
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack user show admin

#
# Create the admin role:
#

create-admin-role:
  cmd.run:
    - name: openstack role create admin
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack role show admin

#
# Add the admin role to the admin project and user:
#

add-admin-role:
  cmd.run:
    - name: openstack role add --project admin --user admin admin
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0

#
# Create the service project:
#

create-service-project:
  cmd.run:
    - name: 'openstack project create --description "Service Project" service'
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack project show service

#
# Create the demo project:
#

create-demo-project:
  cmd.run:
    - name: 'openstack project create --description "Demo Project" demo'
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack project show demo 

create-demo-user:
  cmd.run:
    - name: openstack user create --password {{ salt['pillar.get']('openstack:auth:DEMO_PASS') }} demo
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack user show demo

create-user-role:
  cmd.run:
    - name: openstack role create user
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0
    - unless:
      - openstack role show user

add-demo-role:
  cmd.run:
    - name: openstack role add --project demo --user demo user
    - env:
      - OS_TOKEN: {{ admin_token }}
      - OS_URL: http://{{ controller }}:35357/v2.0

