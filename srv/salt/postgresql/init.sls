postgresql:
  pkg.installed

'postgres createdb sanna':
  cmd.run

postgresql.service:
  service.running
