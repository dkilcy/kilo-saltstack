kilo-saltstack-yumrepo:
  pkgrepo.managed:
    - name: kilo-saltstack
    - humanname: kilo-saltstack
    - baseurl: {{ salt['pillar.get']('openstack:repo:baseurl') }}
    - gpgcheck: 0
    - enabled: True
  cmd.run:
    - name: yum -y clean all

  
