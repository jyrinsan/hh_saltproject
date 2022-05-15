asennukset:
  pkg.installed:
    - pkgs:
      - virtualenv
      - libapache2-mod-wsgi-py3

adduser:
  user.present:
    - name: django
    - password: $1$JeVTvOSq$lbPDz6CkLxA.dmo8CWml20
    
/home/django/publicwsgi:
  file.directory:
    - user: django
    - group: django
    - mode: 0755

'virtualenv -p python3 --system-site-packages env':
  cmd.run:
    - cwd: /home/django/publicwsgi
    - runas: django
    - unless: ls |grep env

'source env/bin/activate':
  cmd.run:
    - cwd: /home/django/publicwsgi
    - shell: /bin/bash
    - runas: django
    - stateful: True

/home/django/publicwsgi/requirements.txt:
  file.managed:
    - source: salt://django/requirements.txt
    - user: django
    - group: django
    - mode: 0644

'pip install -r requirements.txt':
  cmd.run:
    - cwd: /home/django/publicwsgi
    - unless: django-admin --version
