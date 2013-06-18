git:
  pkg.installed:
  {% if grains['os'] == 'RedHat' or grains['os'] == 'Fedora' or grains['os'] == 'CentOS'%}
    - name: git-core
  {% elif grains['os'] == 'Debian' or grains['os'] == 'Ubuntu'%}
    - name: git
  {% endif %}

  user.present:
    - require:
      - group: git

    - groups:
      - git

  group.present:
    - system: True

/var/git:
  file.directory:
    - user: git
    - group: git
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: git
      - user: git
      - group: git
    - watch_in:
      - cmd: git init --bare

git init --bare:
  cmd.wait

