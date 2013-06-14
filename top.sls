base:
  'master':
    - master

  'aventurella.local':
    - aventurella

  'roles:lamp-basic':
    - match: grain
    - lamp-basic
