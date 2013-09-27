apache:
  pkg.installed:
  {% if grains['os'] == 'RedHat' %}
    - name: httpd
  service:
  - name: httpd
  - running
  {% elif grains['os'] == 'Ubuntu' %}
    - name: apachetest
  service:
  - name: apachetest
  - running
  {% endif %}
