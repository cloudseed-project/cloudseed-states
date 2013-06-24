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
  cmd.wait:
    - name: mysqladmin -u root password '{{ salt['pillar.get']('mysql:root_password', '') }}'
    - unless: mysqladmin -u root -p'{{ salt['pillar.get']('mysql:root_password', '') }}' status > /dev/null
    - require:
      - pkg: mysql-server

{% for each in  salt['pillar.get']('mysql:databases', [])  %}
mysql -uroot -p'{{ salt['pillar.get']('mysql:root_password', '') }}' -e "create database {{ each.name }}":
  cmd.run:
    - unless: mysql -uroot -p'{{ salt['pillar.get']('mysql:root_password', '') }}' -e "use {{ each.name }}"
{% endfor %}
