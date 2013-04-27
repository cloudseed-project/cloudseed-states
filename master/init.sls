mongodb:
  pkg:
    - installed
  service:
    - running
  mongodb_user.present:
    - name: cloudseed
    - database: cloudseed
    - require:
      - service: mongodb
