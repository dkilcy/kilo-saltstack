
openstack:

  'G@kilo-saltstack:*':
    - yumrepo
    - auth

  'G@kilo-saltstack:role:controller':
    - auth 
    - mysql
    - rabbitmq
    - keystone

