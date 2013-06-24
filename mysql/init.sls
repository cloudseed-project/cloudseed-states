mysql-server:
  pkg:
    - installed
  service:
    - name: mysqld
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
