
openstack:

  'G@kilo-saltstack:*':
    - yumrepo
    - auth

  'G@kilo-saltstack:role:controller':
    - mysql
    - rabbitmq
    - keystone
    - glance
    - nova.controller
    - neutron.controller

  'G@kilo-saltstack:role:network':
    - neutron.network

  'G@kilo-saltstack:role:compute':
    - nova.compute
 
