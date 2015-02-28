mesos-slave-metapackage:
  pkg.installed:
    - pkgs:
      - mesos
      - docker.io
    - require:
      - pkgrepo: mesos-base-repository

docker-change-default-subnet:
  file.managed:
    - name: /etc/default/docker.io
    - source: salt://mesos/slave/default.docker
    - require_in:
      - pkg: mesos-slave-metapackage

mesos-docker-service:
  service.running:
    - name: docker.io
    - enable: True
    - require:
      - pkg: mesos-slave-metapackage

mesos-slave-service:
  service.running:
    - name: mesos-slave
    - enable: True
    - require:
      - pkg: mesos-slave-metapackage

mesos-master-service-dead:
  service.dead:
    - name: mesos-master
    - require:
      - pkg: mesos-slave-metapackage

mesos-master-service-disable:
  service.disabled:
    - name: mesos-master
    - require:
      - pkg: mesos-slave-metapackage

mesos-zookeeper-service-dead:
  service.dead:
    - name: zookeeper
    - require:
      - pkg: mesos-slave-metapackage

mesos-zookeeper-service-disable:
  service.disabled:
    - name: zookeeper
    - require:
      - pkg: mesos-slave-metapackage

{% set myid=grains['ip_interfaces']['eth0'][0].split('.')[3] %}

{% set my_env = grains['env'] %}
{% set my_app = grains['app'] %}
{% set hosts = [] %}
{% for host, value in salt['mine.get']('app:mesos', 'grains.item', expr_form='grain').items() %}
# host = {{ host }} value = {{ value }}
{%   if 'mesos' in value.roles and 'master' in value.roles and my_env == value.env and my_app == value.app %}
{%     do hosts.append(host + ':2181') %}
{%   endif %}
{% endfor %}

{% set hosts = hosts|sort %}
# hosts = {{ hosts }}
{% set i = 0 %}

{% set zk='zk://' + hosts|join(',') + '/mesos' %}
{% if hosts|length > 0 %}
mesos-slave-zookeeper-config-file:
  file.managed:
    - name: /etc/mesos/zk
    - contents: {{ zk }}
    - watch_in:
      - service: mesos-slave-service
{% endif %}

mesos-docker-config:
  file.managed:
    - name: /etc/mesos-slave/containerizers
    - contents: 'docker,mesos'
    - watch_in:
      - service: mesos-slave-service

mesos-docker-timeout:
  file.managed:
    - name: /etc/mesos-slave/executor_registration_timeout
    - contents: '5mins'
    - watch_in:
      - service: mesos-slave-service
