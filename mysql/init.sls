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

mysql.config:
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://mysql/files/my.cnf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

    - watch_in:
      - service: mysql-server

    - require:
        - pkg: mysql-server


{% for db, value in salt['pillar.get']('mysql:databases', {}).iteritems() %}

mysql.database.{{ db }}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "CREATE DATABASE {{ db }};"
    - unless: mysql -uroot -p'{{ root_password }}' -e "use {{ db }}"
    - require:
      - pkg: mysql-server

mysql.user.{{ value.user }}:
  cmd.run:
    - name: mysql -uroot -p'{{ root_password }}' -e "CREATE USER '{{ value.user }}'@'{{ value.host|default('localhost') }}' IDENTIFIED BY '{{ value.password|default('') }}';"
    - require:
      - pkg: mysql-server
      - cmd: mysql.database.{{ db }}
    - unless: mysql -u{{ value.user }} -p'{{ value.password|default('') }}' -e "SELECT COUNT(1);"
    - watch_in:
        - cmd: mysql.grant.{{ value.user }}

mysql.grant.{{ value.user }}:
  cmd.wait:
    - name: mysql -uroot -p'{{ root_password }}' -e "GRANT {{ value.grant|default('ALL PRIVILEGES') }} ON {{ db }} . * TO '{{ value.user }}'@'{{ value.host|default('localhost') }}';"
    - require:
      - pkg: mysql-server
      - cmd: mysql.database.{{ db }}
      - cmd: mysql.user.{{ value.user }}
    - watch:
      - cmd: mysql.user.{{ value.user }}

{% if grains['virtual'] == 'VirtualBox' %}
mysql.user.vagrant.{{ value.user }}:
  cmd.wait:
    - name: mysql -uroot -p'{{ root_password }}' -e "CREATE USER '{{ value.user }}'@'%' IDENTIFIED BY '{{ value.password|default('') }}';"
    - require:
      - pkg: mysql-server
      - cmd: mysql.user.{{ value.user }}
    - watch:
        - cmd: mysql.user.{{ value.user }}

mysql.grant.vagrant.{{ value.user }}:
  cmd.wait:
    - name: mysql -uroot -p'{{ root_password }}' -e "GRANT {{ value.grant|default('ALL PRIVILEGES') }} ON {{ db }} . * TO '{{ value.user }}'@'%';"
    - require:
      - pkg: mysql-server
      - cmd: mysql.user.vagrant.{{ value.user }}
    - watch:
        - cmd: mysql.user.vagrant.{{ value.user }}
{% endif %}

{% endfor %}
