# saltstack-mesos
Mesos Saltstack States for Easy Install

### You'll need /etc/salt/minion such as this
```
grains:
    app:
    - mesos
    env:
    - dev
    roles:
    - mesos
    - master
master: salt
mine_functions:
    grains.item:
    - app
    - roles
    - env
    - fqdn
    network.interfaces: []
    ```
