mesos-metapackage:
  pkg.installed:
    - pkgs:
      - mesos
      - marathon
      - chronos
    - require:
      - pkgrepo: mesos-base-repository

mesos-master-service:
  service.running:
    - name: mesos-master
    - enable: True

mesos-chronos-service:
  service.running:
    - name: chronos
    - enable: True

mesos-marathon-service:
  service.running:
    - name: marathon
    - enable: True

mesos-zookeeper-service:
  service.running:
    - name: zookeeper
    - enable: True
    - watch:
      - file: mesos-zookeeper-id

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

{% for host in hosts %}
{%   set i = i + 1 %}
{% if grains['nodename'] in host %}
mesos-zookeeper-id:
  file.managed:
    - name: /etc/zookeeper/conf/myid
    - contents: {{ i }}
{% endif %}
{% endfor %}

{% set zk='zk://' + hosts|join(',') + '/mesos' %}
{% if hosts|length > 0 %}
mesos-master-zookeeper-config-file:
  file.managed:
    - name: /etc/mesos/zk
    - contents: {{ zk }}
    - watch_in:
      - service: mesos-master-service
{% endif %}

mesos-master-zoo-conf:
  file.managed:
    - name: /etc/zookeeper/conf/zoo.cfg
    - source: salt://mesos/master/zookeeper/zoo.cfg.jinja
    - template: jinja
    - defaults:
      hosts: {{ hosts }}
    - watch_in:
      - service: mesos-zookeeper-service
