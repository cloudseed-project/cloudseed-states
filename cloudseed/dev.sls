cloudseed.git:
  git.latest:
    - name: https://github.com/cloudseed-project/cloudseed.git
    - rev: develop
    - target: /home/root/cloudseed
    - watch_in:
      cmd: cloudseed.install

cloudseed.install:
  cmd.wait:
    - name: python setup.py develop
    - cwd: /home/root/cloudseed
