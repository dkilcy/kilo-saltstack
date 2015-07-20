{% set controller = salt['pillar.get']('openstack:controller:host') %}

dir_setup:
  file.directory:
    - name: /home/devops/kilo-saltstack
    - user: {{ salt['pillar.get']('openstack:user') }}
    - group: {{ salt['pillar.get']('openstack:user') }}
    - mode: 775

auth_setup:
  file.managed:
    - name: /home/{{ salt['pillar.get']('openstack:user') }}/kilo-saltstack/auth-openrc.sh
    - user: {{ salt['pillar.get']('openstack:user') }}
    - group: {{ salt['pillar.get']('openstack:user') }}
    - mode: 755 
    - create: True
    - contents: |
        export ADMIN_PASS={{ salt['pillar.get']('openstack:auth:ADMIN_PASS') }}
        export CEILOMETER_DBPASS={{ salt['pillar.get']('openstack:auth:CEILOMETER_DBPASS') }}
        export CEILOMETER_PASS={{ salt['pillar.get']('openstack:auth:CEILOMETER_PASS') }}
        export CINDER_DBPASS={{ salt['pillar.get']('openstack:auth:CINDER_DBPASS') }}
        export CINDER_PASS={{ salt['pillar.get']('openstack:auth:CINDER_PASS') }}
        export DASH_DBPASS={{ salt['pillar.get']('openstack:auth:DASH_DBPASS') }}
        export DEMO_PASS={{ salt['pillar.get']('openstack:auth:DEMO_PASS') }}
        export GLANCE_DBPASS={{ salt['pillar.get']('openstack:auth:GLANCE_DBPASS') }}
        export GLANCE_PASS={{ salt['pillar.get']('openstack:auth:GLANCE_PASS') }}
        export HEAT_DBPASS={{ salt['pillar.get']('openstack:auth:HEAT_DBPASS') }}
        export HEAT_PASS={{ salt['pillar.get']('openstack:auth:HEAT_PASS') }}
        export KEYSTONE_DBPASS={{ salt['pillar.get']('openstack:auth:KEYSTONE_DBPASS') }}
        export NEUTRON_DBPASS={{ salt['pillar.get']('openstack:auth:NEUTRON_DBPASS') }}
        export NEUTRON_PASS={{ salt['pillar.get']('openstack:auth:NEUTRON_PASS') }}
        export NOVA_DBPASS={{ salt['pillar.get']('openstack:auth:NOVA_DBPASS') }}
        export NOVA_PASS={{ salt['pillar.get']('openstack:auth:NOVA_PASS') }}
        export SAHARA_DBPASS={{ salt['pillar.get']('openstack:auth:SAHARA_PASS') }}
        export TROVE_DBPASS={{ salt['pillar.get']('openstack:auth:TROVE_DBPASS') }}
        export TROVE_PASS={{ salt['pillar.get']('openstack:auth:TROVE_PASS') }}
        export SWIFT_PASS={{ salt['pillar.get']('openstack:auth:SWIFT_PASS') }}

admin_setup:
  file.managed:
    - name: /home/{{ salt['pillar.get']('openstack:user') }}/kilo-saltstack/admin-openrc.sh
    - user: {{ salt['pillar.get']('openstack:user') }}
    - group: {{ salt['pillar.get']('openstack:user') }}
    - mode: 755 
    - create: True
    - contents: |
        export OS_PROJECT_DOMAIN_ID=default
        export OS_USER_DOMAIN_ID=default
        export OS_PROJECT_NAME=admin
        export OS_TENANT_NAME=admin
        export OS_USERNAME=admin
        export OS_PASSWORD=$ADMIN_PASS
        export OS_AUTH_URL=http://{{ controller }}:35357/v3
        export OS_IMAGE_API_VERSION=2
        export OS_REGION_NAME: RegionOne

demo_setup:
  file.managed:
    - name: /home/{{ salt['pillar.get']('openstack:user') }}/kilo-saltstack/demo-openrc.sh
    - user: {{ salt['pillar.get']('openstack:user') }}
    - group: {{ salt['pillar.get']('openstack:user') }}
    - mode: 755 
    - contents: |
        export OS_PROJECT_DOMAIN_ID=default
        export OS_USER_DOMAIN_ID=default
        export OS_PROJECT_NAME=demo
        export OS_TENANT_NAME=demo
        export OS_USERNAME=demo
        export OS_PASSWORD=$DEMO_PASS
        export OS_AUTH_URL=http://{{ controller }}:5000/v3
        export OS_IMAGE_API_VERSION=2
        export OS_REGION_NAME: RegionOne


