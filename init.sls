remove_invalid_localhosts_entry:
  file.sed:
    - name: /etc/hosts
    - before: '^127.0.1.1'
    - after: '#127.0.1.1'

include:
  - .repository
{% if 'roles' in grains and 'slave' in grains['roles'] %}
  - .slave
{% elif 'roles' in grains and 'master' in grains['roles'] %}
  - .master
{% endif %}

# setting up /etc/hosts file so all the services can speak with each with using hostnames
{% for host, value in salt['mine.get']('app:mesos', 'network.interfaces', expr_form='grain').items() %}
{{ host }}:
  host.present:
    - ip: {{ value['eth0']['inet'][0]['address'] }}
{% endfor %}
