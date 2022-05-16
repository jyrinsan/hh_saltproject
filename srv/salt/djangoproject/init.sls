'django-admin startproject myapp':
  cmd.run:
    - cwd: /home/django/publicwsgi
    - runas: django
    - unless: ls | grep myapp

/etc/apache2/sites-available/myapp.conf:
  file.managed:
    - source: salt://djangoproject/myapp.conf

/etc/apache2/sites-enabled/myapp.conf:
  file.symlink:
    - target: ../sites-available/myapp.conf

/etc/apache2/sites-enabled/000-default.conf:
  file.absent

/home/django/publicwsgi/myapp/myapp/settings.py:
  file.managed:
    - source: salt://djangoproject/settings.py
    - user: django
    - group: django
    - mode: 0644

restarttaaApache:
  service.running:
    - name: apache2.service
    - watch:
      - file: /etc/apache2/sites-enabled/myapp.conf
      - file: /home/django/publicwsgi/myapp/myapp/settings.py


'echo yes python3 /manage.py collectstatic':
  cmd.run:
    - cwd: /home/django/publicwsgi/myapp
    - unless: ls | grep static

/home/django/publicwsgi/myapp/static:
  file.recurse:
    - source: salt://djangoproject/static
    - user: django
    - group: django
    - dir_mode: 0755
    - file_mode: 0755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
