{% set root_password = salt['pillar.get']('mysql:root_password', '') %}

mysql-server:
  pkg:
    - installed
  service:
    - name: mysql
    - running
    - enable: True
    - require:
      - pkg: mysql-server
    - watch_in:
        cmd: mysql.admin

mysql.admin:
  cmd.run:
    - name: mysqladmin -u root password '{{ root_password }}'
    - unless: mysqladmin -u root -p'{{ root_password }}' status > /dev/null
    - require:
      - pkg: mysql-server

{% for user in salt['pillar.get']('mysql:users', []) %}
mysql.user.{{ user.name }}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "CREATE USER '{{ user.name }}'@'{{user.host|default('localhost')}}' IDENTIFIED BY '{{user.password|default('')}}';"
    - require:
      - pkg: mysql-server
    - unless: mysql -u{{user.name}} -p'{{user.password|default('')}}' status > /dev/null
{% endfor %}

{% for db in salt['pillar.get']('mysql:databases', []) %}
mysql.database.{{ db }}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "create database {{ db }}":
    - unless: mysql -uroot -p'{{ root_password }}' -e "use {{ db }}"
    - require:
      - pkg: mysql-server
{% endfor %}

{% for grant in salt['pillar.get']('mysql:grants', []) %}
mysql.grant.{{grant.database}}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "GRANT {{ grant.grant|default('ALL PRIVILEGES') }} ON {{ grant.database }} . * TO '{{ grant.user }}'@'{{ grant.host }}';":
    - require:
      - pkg: mysql-server
      - cmd: mysql.database.{{ grant.database }}
      - cmd: mysql.user.{{ grant.user }}
{% endfor %}

