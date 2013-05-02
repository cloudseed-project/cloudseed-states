cloudseed.git:
  git.latest:
    - name: https://github.com/cloudseed-project/cloudseed.git
    - rev: master
    - target: /root/cloudseed
    - watch_in:
      cmd: cloudseed.install

cloudseed.install:
  cmd.wait:
    - name: python setup.py develop
    - cwd: /root/cloudseed
