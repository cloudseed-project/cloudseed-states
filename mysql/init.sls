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

{% for db, value in salt['pillar.get']('mysql:databases', {}).iteritems() %}

mysql.user.{{ value.user }}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "CREATE USER '{{ value.user }}'@'{{ value.host|default('localhost') }}' IDENTIFIED BY '{{ value.password|default('') }}';"
    - require:
      - pkg: mysql-server
    - unless: mysql -u{{ value.user }} -p'{{ value.password|default('') }}' status > /dev/null

mysql.database.{{ db }}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "CREATE DATABASE {{ db }}"
    - unless: mysql -uroot -p'{{ root_password }}' -e "use {{ db }}"
    - require:
      - pkg: mysql-server

mysql.grant.{{ db }}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "GRANT {{ value.grant|default('ALL PRIVILEGES') }} ON {{ db }} . * TO '{{ value.user }}'@'{{ value.host|default('localhost') }}';"
    - require:
      - pkg: mysql-server
      - cmd: mysql.database.{{ db }}
      - cmd: mysql.user.{{ value.user }}

{% endfor %}
