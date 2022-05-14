virtualenv:
  pkg.installed

libapache2-mod-wsgi-py3:
  pkg.installed

/home/sanna/publicwsgi:
  file.directory

'virtualenv -p python3 --system-site-packages env':
  cmd.run:
    - cwd: /home/sanna/publicwsgi
    - unless: ls |grep env

'source env/bin/activate':
  cmd.run:
    - cwd: /home/sanna/publicwsgi
    - shell: /bin/bash
    - unless: pöö

'pip install django':
  cmd.run:
    - cwd: /home/sanna/publicwsgi
    - unless: django-admin --version

'django-admin startproject sannaco':
  cmd.run:
    - cwd: /home/sanna/publicwsgi
    - unless: ls | grep sannaco

/etc/apache2/sites-available/sannaco.conf:
  file.managed:
    - source: salt://django/sannaco.conf

/etc/apache2/sites-enabled/sannaco.conf:
  file.symlink:
    - target: ../sites-available/sannaco.conf

/etc/apache2/sites-enabled/000-default.conf:
  file.absent

/home/sanna/publicwsgi/sannaco/sannaco/settings.py:
  file.managed:
    - source: salt://django/settings.py
