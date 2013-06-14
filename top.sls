base:
  'master':
    - master

  'minion0':
    - apache

  'aventurella.local':
    - aventurella

  'role:lamp':
    - match: grain
    - lamp
