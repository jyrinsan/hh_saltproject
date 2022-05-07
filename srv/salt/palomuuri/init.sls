ufw:
  pkg.installed

/etc/ufw/ufw.conf:
  file.managed:
    - source: salt://palomuuri/ufw.conf

'ufw allow 22/tcp':
  cmd.run

ufw.service:
  service.running
