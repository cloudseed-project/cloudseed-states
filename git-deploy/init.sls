git:
  pkg.installed:
  {% if grains['os'] == 'RedHat' or grains['os'] == 'Fedora' or grains['os'] == 'CentOS'%}
    - name: git-core
  {% elif grains['os'] == 'Debian' or grains['os'] == 'Ubuntu'%}
    - name: git
  {% endif %}


/var/git:
  file.directory:
    - user: {{ salt['pillar.get']('cloudseed:ssh_username', 'vagrant') }}
    - group: {{ salt['pillar.get']('cloudseed:ssh_username', 'vagrant') }}
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: git
    - watch_in:
      - cmd: git init --bare

git init --bare:
  cmd.wait:
    - cwd: /var/git
    - require:
      - file: /var/git

/var/git/hooks/post-receive:
  file.managed:
    - source: salt://git-deploy/files/post-receive
    - template: jinja
    - user: {{ salt['pillar.get']('cloudseed:ssh_username', 'vagrant') }}
    - group: {{ salt['pillar.get']('cloudseed:ssh_username', 'vagrant') }}
    - mode: 755
    - require:
      - file: /var/git
      - cmd: git init --bare
