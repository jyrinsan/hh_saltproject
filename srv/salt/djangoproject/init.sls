'django-admin startproject myapp':
  cmd.run:
    - cwd: /home/django/publicwsgi
    - runas: django
    - unless: ls | grep myapp

/etc/apache2/sites-available/myapp.conf:
  file.managed:
    - source: salt://djangoapp/myapp.conf

/etc/apache2/sites-enabled/myapp.conf:
  file.symlink:
    - target: ../sites-available/myapp.conf

/etc/apache2/sites-enabled/000-default.conf:
  file.absent

/home/django/publicwsgi/myapp/myapp/settings.py:
  file.managed:
    - source: salt://djangoapp/settings.py
    - user: django
    - group: django
    - mode: 0644

'echo yes python3 /manage.py collectstatic':
  cmd.run:
    - cwd: /home/django/publicwsgi/myapp
    - runas: django

/home/django/publicwsgi/myapp/static:
  file.recurse:
    - source: salt://djangoapp/static
    - user: django
    - group: django
    - dir_mode: 0755
    - file_mode: 0755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
