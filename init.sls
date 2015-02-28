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
