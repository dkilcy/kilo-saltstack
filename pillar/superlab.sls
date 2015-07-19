
mysql:
  root_pass: password

rabbitmq:
  user: openstack
  pass: openstack

openstack:
 
  repo:
    baseurl: http://yumrepo/repo/centos/$releasever/openstack-kilo/

  user: devops

  controller:
    host: controller1
    mgmt_intf: 'ip4_interfaces:team0:0'
   
  network:
    host: network1
    mgmt_intf: 'ip4_interfaces:team0:0'
    vm_intf: 'ip4_interfaces:team1:0'
    pub_intf: 'ip4_interfaces:enp4s0:0'

  compute:
    mgmt_intf: 'ip4_interfaces:team0:0'
    vm_intf: 'ip4_interfaces:team1:0'

  auth:
    ADMIN_PASS: 94bcee677185fee9c0bf
    CEILOMETER_DBPASS: 55a0690b47fec6f98a31
    CEILOMETER_PASS: d16c43e1a962a554c948
    CINDER_DBPASS: 5680258bb2c2b4dee1ee
    CINDER_PASS: c9f59d5c328fc3977297
    DASH_DBPASS: f0baa153daac61a24102
    DEMO_PASS: 6efd10a180784267be4c
    GLANCE_DBPASS: 6d44ef12b707316851f2
    GLANCE_PASS: d6b6ed7dac1e80c684e8
    HEAT_DBPASS: a99a98179f6edb0ca113
    HEAT_PASS: c6adaa597fbce9289f90
    KEYSTONE_DBPASS: 376ebc0ee6649544c178
    NEUTRON_DBPASS: f06432c2e047666d99e3
    NEUTRON_PASS: b398f7d80d20b77e238c
    NOVA_DBPASS: e7b29ecfd4c688360e83 
    NOVA_PASS: a1b587dd687cff6a6dff
    SAHARA_DBPASS: 9b38ae1e7e75e5576ee2
    SWIFT_PASS: 0d882fe21dfe142ea3df
    TROVE_DBPASS: 8d2f0c22de016fe093f4
    TROVE_PASS: 18c357877c7120e6cca4
    METADATA_SECRET: 0cb2bb516881d71eff88

  keystone:
    admin_token: 5ef51bc4d3bf3e600f78


