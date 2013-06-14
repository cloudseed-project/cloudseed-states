include:
  - apache

php5:
  pkg:
    - installed

php5-curl:
  pkg:
    - installed
    - watch_in:
      - service: httpd

php5-gd:
  pkg:
    - installed
    - watch_in:
      - service: httpd

libapache2-mod-php5:
  pkg:
    - installed
    - require:
      - pkg: httpd

    - watch_in:
      - service: httpd

/etc/apache2/sites-available/default:
  file.managed:
    - source: salt://lamp-basic/files/host.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

a2enmod rewrite:
  cmd.run:
    - onlyif: test -e /etc/apache2/mods-enabled/rewrite.load
    - watch_in:
      - service: httpd
