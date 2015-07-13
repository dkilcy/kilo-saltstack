
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

  'G@kilo-saltstack:role:compute':
    - nova.compute
 
