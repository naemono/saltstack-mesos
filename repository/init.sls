mesos-base-repository:
  pkgrepo.managed:
    - humanname: Mesos Ubuntu Repository
{% if 'lsb_distrib_release' in grains and '14.04' in grains['lsb_distrib_release'] %}
    - name: deb http://repos.mesosphere.io/ubuntu trusty main
    - dist: trusty
{% elif 'lsb_distrib_release' in grains and '12.04' in grains['lsb_distrib_release'] %}
    - name: deb http://repos.mesosphere.io/ubuntu precise main
    - dist: precise
{% endif %}
    - file: /etc/apt/sources.list.d/mesos.list
    - keyid: E56151BF
    - keyserver: keyserver.ubuntu.com
