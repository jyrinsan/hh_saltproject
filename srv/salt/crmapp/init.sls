/home/django/publicwsgi/myapp/db.sqlite3:
  file.managed:
    - source: salt://crmapp/db.sqlite3
    - user: django
    - group: django
    - mode: 0755

/home/django/publicwsgi/myapp/crm:
  file.recurse:
    - source: salt://crmapp/crm
    - user: django
    - group: django
    - dir_mode: 0755
    - file_mode: 0755
    - makedirs: True
