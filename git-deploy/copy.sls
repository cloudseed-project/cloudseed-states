deploy.stage1:
  file.directory:
    - name: {{ salt['pillar.get']('git-deploy:cwd', '/var/www') }}
    - makedirs: True

deploy.stage2:
  cmd.run:
    - name: GIT_WORK_TREE={{ salt['pillar.get']('git-deploy:cwd', '/var/www') }} git checkout -f
    - cwd: /var/git
    - require:
      - file: deploy.stage1
