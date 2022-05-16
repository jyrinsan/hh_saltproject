## Django tuotantoympäristö SaltStackilla

Moduulin tarkoitus on asentaa Django-tuotantoympäristö webbipalvelun julkaisuun Linux-palvelimille. Moduuli asentaa djangon, apachen, tulimuurin, postgresql tietokannan sekä hyödyllisiä pikkusovelluksia, joita sovelluksen tekoon tarvitaan. Moduuli asentaa myös yksinkertaisen crm-esimerkkisovelluksen, jolla ympäristön toimintaa voi demota. Tämän hetkinen versio käyttää vielä sqlite3 kantaa, jatkokehityksessä kanta aiotaan vaihtaa postgresql-kantaan, jonka vuoksi sen asennus on jo otettu mukaan tähän.

Moduulin lisenssi: [GNU General Public License v2.0](https://opensource.org/licenses/gpl-2.0.php)

```
Nimi              Sanna Jyrinki
Oppilaitos        Haaga-Helian ammattikorkeakoulu
Kurssi            Palvelinten hallinta ICT4TN022-3015
Opettaja          Tero Karvinen
Tietokoneena      AMD Ryzen 5 PRO 4650U with Radeon Graphics 2.10 GHz
Käyttöjärjestelmä Windows 11 Pro, Versio 21H2
Linux             Oracle Virtual Box 6.1, Debian 11.3
```

### Toteutussuunnitelma
- moduuli sisältää seuraavat tilat:
  - appikset: hyödyllisiä pikkuohjelmia micro, bash-completion, pwgen, tree
  - palomuuri: ufw palomuurin, asennus, enablointi ja avaus ssh ja apache portille
  - postgresql: tietokanta jatkokehitystä varten (django sisältää oletuksena kevyen sqlite3 tietokannan)
  - apache asennus, testisivu ja käyttäjän kotisivu
  - django asennus, tuotanto-projektin luonti
  - testisovellus crm, jolla toiminta voidaan demota

- jatkokehitysehdotuksia, joita ei keretty toteuttaa tähän versioon
  - kehitysserveri, jossa django asennetaan kehitysserverinä
  - postgressql ja sen käyttöönotto djangossa vakiona olevan sqllite3:n sijaan
  - jinjalla voisi siistiä usein toistuvat esim tunnukset/hakemistopolut yhdessä paikassa oleviksi vakioiksi
  - ssh ja sftp mahdollisesti olisi myös hyödyllistä asentaa, jos on tarpeen toimia myös ulkoisen virtuaalipalvelimen kanssa

### Toteutus

Moduuli sisältää seuraavat tilat ja top.sls tiedoston, jonka avulla koko moduulin saa ajettua 
```
sudo salt '*' state.apply
```

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ ls
<font color="#5555FF"><b>apache</b></font>  <font color="#5555FF"><b>appsit</b></font>  <font color="#5555FF"><b>crmapp</b></font>  <font color="#5555FF"><b>django</b></font>  <font color="#5555FF"><b>djangoproject</b></font>  <font color="#5555FF"><b>firewall</b></font>  <font color="#5555FF"><b>postgresql</b></font>  top.sls
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat top.sls 
base:
  &apos;*&apos;:
    - appsit
    - firewall
    - postgresql
    - apache
    - django
    - djangoproject
    - crmapp
</pre>

#### Moduulin tilat

##### appsit

Tila **appsit** asentaa yksinkertaisia pikkusovelluksia, jotka osoittautuivat hyödyllisiksi djangon asennuksessa ja djangosovelluksen teossa.

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ ls appsit
init.sls
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat appsit/init.sls 
appsit:
  pkg.installed:
    - pkgs:
      - micro
      - bash-completion
      - pwgen
      - tree
</pre>

##### firewall

Tila **firewall** asentaa ja konfiguroi ufw tulimuurin. Se enabloi sen serverin käynnistyessä, ja avaa reiät ssh:n ja apache:n portteihin.

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ ls firewall
init.sls
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat firewall/init.sls 
ufw:
  pkg.installed

&apos;ufw enable&apos;:
  cmd.run:
    - unless: &quot;ufw status verbose |grep &apos;Status: active&apos;&quot;

&apos;ufw allow 22/tcp&apos;:
  cmd.run:
    - unless: &quot;ufw status verbose |grep &apos;^22/tcp&apos; &quot;

&apos;ufw allow 80/tcp&apos;:
  cmd.run:
    - unless: &quot;ufw status verbose |grep &apos;^80/tcp&apos; &quot;

ufw.service:
  service.running
</pre>

##### postgresql

Tila **postgresql** asentaa postgresql tietokantademonin ja käynnistää sen. Ko. tietokantaa ei kuitenkaan vielä tässä versiossa hyödynnetä djangon kanssa.

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ ls postgresql
init.sls
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat postgresql/init.sls 
postgresql:
  pkg.installed

postgresql.service:
  service.running
</pre>

##### apache

Tila **apache** asentaa apachen, muodostaa oletustestisivun ja aktivoi käyttäjien kotisivun, jos käyttäjä tekee kotisivun oman kotihakemiston public_html hakemistoon. Tila myös käynnistää apachen.

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ ls apache
default-index.html  init.sls
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat apache/init.sls 
apache2:
  pkg.installed

/var/www/html/index.html:
  file.managed:
    - source: salt://apache/default-index.html

/etc/apache2/mods-enabled/userdir.conf:
  file.symlink:
    - target: ../mods-available/userdir.conf

/etc/apache2/mods-enabled/userdir.load:
  file.symlink:
    - target: ../mods-available/userdir.load

apache2.service:
  service.running:
    - watch:
      - file: /etc/apache2/mods-enabled/userdir.conf
      - file: /etc/apache2/mods-enabled/userdir.load
</pre>

##### django

Tila **django** luo django nimisen käyttäjän (salasana on django, joka asetetaa ssh tiedostoon hashattuna linux-komennolla `openssl passwd -1` [SaltStack Contributors, 2022](https://docs.saltproject.io/en/3000/ref/states/all/salt.states.user.html). Tila luo käyttäjän kotihakemiston alle publicwsgi-hakemiston ja asentaa djangon. Tilassa on myös asennettu virtualenv-ympäristö ja aktivoitu se, mutta en tiedä toimiiko se, kun se ei näkynyt missään. Ilmeisesti sillä ei ole itse toimintaan mitään vaikutusta, joten ehkäpä kokeilen vielä poistaa.


<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ ls django
init.sls  requirements.txt
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat django/requirements.txt 
django
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat django/init.sls 
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

&apos;virtualenv -p python3 --system-site-packages env&apos;:
  cmd.run:
    - cwd: /home/django/publicwsgi
    - runas: django
    - unless: ls |grep env

&apos;source env/bin/activate&apos;:
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

&apos;pip install -r requirements.txt&apos;:
  cmd.run:
    - cwd: /home/django/publicwsgi
    - unless: django-admin --version
</pre>

##### djangoproject

Tila **djangoproject** luon djangoprojektin nimeltään **myapp**, joka tekee publicwsgi:n alle myapp hakemiston alihakemistoineen, josta merkittävänä löytyy projektin konfiguraatio settings.xml. Tila tekee myös apachelle konfiguraation myapp.conf, joka säätelee apachelle enabloidut sivut. Djangon automaattisesti tarjoaman /admin sivun lisäksi asetetaan siinä staattiset sivut päälle polussa /static. Tila myös kopioi saltin alta settings.xml tiedoston, johon on tehty muutamia muutoksia, mm. asetettu debug tila pois päältä ja sallittu osoite localhost. Lähteintä olevista Djangon materiaaleista voit katsoa tarkemmin asennuksen yksityiskohdat. Jotta /admin polusta löytyvä sisäänkirjautumissivu näyttää tyylikkäämmältä, tila myös kerää static hakemiston alle djangon staattiset tyylisivut.

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ tree djangoproject/
<font color="#5555FF"><b>djangoproject/</b></font>
├── init.sls
├── myapp.conf
├── settings.py
└── <font color="#5555FF"><b>static</b></font>
    └── staticpage.html

1 directory, 4 files
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat djangoproject/myapp.conf 
Define TDIR /home/django/publicwsgi/myapp
Define TWSGI /home/django/publicwsgi/myapp/myapp/wsgi.py
Define TUSER django
Define TVENV /home/django/publicwsgi/env/lib/python3.9/site-packages

&lt;VirtualHost *:80&gt;
        Alias /static/ ${TDIR}/static/
        &lt;Directory ${TDIR}/static/&gt;
                Require all granted
        &lt;/Directory&gt;

        WSGIDaemonProcess ${TUSER} user=${TUSER} group=${TUSER} threads=5 python-path=&quot;${TDIR}:${TVENV}&quot;
        WSGIScriptAlias / ${TWSGI}
        &lt;Directory ${TDIR}&gt;
             WSGIProcessGroup ${TUSER}
             WSGIApplicationGroup %{GLOBAL}
             WSGIScriptReloading On
             &lt;Files wsgi.py&gt;
                Require all granted
             &lt;/Files&gt;
        &lt;/Directory&gt;

&lt;/VirtualHost&gt;

Undefine TDIR
Undefine TWSGI
Undefine TUSER
Undefine TVENV
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat djangoproject/init.sls 
&apos;django-admin startproject myapp&apos;:
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

&apos;echo yes python3 /manage.py collectstatic&apos;:
  cmd.run:
    - cwd: /home/django/publicwsgi/myapp
    - runas: django
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
</pre>

##### crmapp

Tila **crmapp** muodostaa esimerkkisovelluksen, jonka alulla voi demota sovelluksen toiminta. Sovellus on aluksi muodostettu käsin, ja tila vain kopioi sekä crm-hakemiston sisällön paikoilleen sekä myös sqlite3 tietokannan. Myöhemmässä moduulin vaiheessa tietokanta voidaan muuttaa postgressql tietokannaksi.

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ tree crmapp
<font color="#5555FF"><b>crmapp</b></font>
├── <span style="background-color:#00AA00"><font color="#0000AA">crm</font></span>
│   ├── <font color="#55FF55"><b>admin.py</b></font>
│   ├── <font color="#55FF55"><b>apps.py</b></font>
│   ├── <font color="#55FF55"><b>__init__.py</b></font>
│   ├── <font color="#5555FF"><b>migrations</b></font>
│   │   ├── <font color="#55FF55"><b>0001_initial.py</b></font>
│   │   ├── <font color="#55FF55"><b>0002_alter_customer_name.py</b></font>
│   │   ├── <font color="#55FF55"><b>__init__.py</b></font>
│   │   └── <font color="#5555FF"><b>__pycache__</b></font>
│   │       ├── <font color="#55FF55"><b>0001_initial.cpython-39.pyc</b></font>
│   │       ├── <font color="#55FF55"><b>0002_alter_customer_name.cpython-39.pyc</b></font>
│   │       └── <font color="#55FF55"><b>__init__.cpython-39.pyc</b></font>
│   ├── <font color="#55FF55"><b>models.py</b></font>
│   ├── <font color="#5555FF"><b>__pycache__</b></font>
│   │   ├── <font color="#55FF55"><b>admin.cpython-39.pyc</b></font>
│   │   ├── <font color="#55FF55"><b>apps.cpython-39.pyc</b></font>
│   │   ├── <font color="#55FF55"><b>__init__.cpython-39.pyc</b></font>
│   │   └── <font color="#55FF55"><b>models.cpython-39.pyc</b></font>
│   ├── <font color="#55FF55"><b>tests.py</b></font>
│   └── <font color="#55FF55"><b>views.py</b></font>
├── <font color="#55FF55"><b>db.sqlite3</b></font>
└── init.sls

4 directories, 18 files
<font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>/srv/salt</b></font>$ cat crmapp/init.sls 
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
    - replace: True
</pre>

#### Testaus

Moduulin toteutus ja testaus suoritettiin Windows-raudalla, jossa oli asennettuna VirtualBoxiin 2 eri Debian 11-konetta, joista toisesta tehtiin salt-master ja toisesta salt-minion. Salt masterilla moduuli on /srv/salt hakemistossa, jonka sisältö vietiin versionhallintaan. Kehitystä tehtiin askel kerrallaan asentaen ensin Debianille asia manuaalisesti ja sen jälkeen automatisoimalla saltila. Useita kertoja (tai kymmeniä jopa) tehtiin uusi orja-debian kone, ja testattiin puhtaalla debianilla toimiiko moduuli.

Testaus orja-koneella ennen moduulin ajoa kun mitään ei ole asennettu:

<pre><font color="#55FF55"><b>sanna@sanna-virtualbox</b></font>:<font color="#5555FF"><b>~</b></font>$ curl http://localhost
curl: (7) Failed to connect to localhost port 80: Connection refused
<font color="#55FF55"><b>sanna@sanna-virtualbox</b></font>:<font color="#5555FF"><b>~</b></font>$ curl http://localhost/admin
curl: (7) Failed to connect to localhost port 80: Connection refused
<font color="#55FF55"><b>sanna@sanna-virtualbox</b></font>:<font color="#5555FF"><b>~</b></font>$ curl http://localhost/static
curl: (7) Failed to connect to localhost port 80: Connection refused
</pre>

[Täältä](RUN_1.MD) löytyy salt loki, kun koko valmistunut moduuli ajetaan puhtaalle Debianille, jonne ei vielä ole asennettu muutakuin salt-minion.

<pre><font color="#55FF55"><b>master@master-virtualbox</b></font>:<font color="#5555FF"><b>~</b></font>$ sudo salt &apos;*&apos; state.apply | more
[sudo] password for master: 
ERROR: Minions returned with non-zero exit code
slave3:
    Minion did not return. [No response]
    The minions may not have all finished running and any remaining minions will
 return upon completion. To look up the return data for this job later, run the 
following command:
    
    salt-run jobs.lookup_jid 20220516150644685475
</pre>

Jatkettaessa ajoa `salt-run jobs.lookup_jid 20220516150644685475` menee loppuun virheittä

salt-run jobs.lookup_jid 20220516150644685475

[Täältä](RUN_2.MD) löytyy salt loki, kun koko valmistunut moduuli ajetaan toisen kerran peräkkäin, josta näkyy, että koko moduuli on idempotentti, eli mitään uutta ei asennu, koska mitään ei ole muutettu.

### Lähteet

- Djangocentral. n.a. Luettavissa [Using PostgreSQL with Django](https://djangocentral.com/using-postgresql-with-django/). Luettu 15.5.2022.
- Karvinen, T. 2022a. Luettavissa [Configuration management systems 2022](https://terokarvinen.com/2021/configuration-management-systems-2022-spring/#arviointi). Luettu 03-05/22.
- Karvinen, T. 2022b. [Django 4 Instant Customer Database Tutorial](https://terokarvinen.com/2022/django-instant-crm-tutorial/). Luettu 14-15.5.2022.
- Karvinen, T. 2022c. [Deploy Django 4 - Production Install](https://terokarvinen.com/2022/deploy-django/?fromSearch=django). Luettu 14-15.5.2022.
- SaltStack Contributors. 2022. [SALT.STATES.USER
, MANAGEMENT OF USER ACCOUNTS](https://docs.saltproject.io/en/3000/ref/states/all/salt.states.user.html)
- Shellhacks Contributors. 2020. Luettavissa [Auto Answer “Yes/No” to Prompt – PowerShell & CMD](https://www.shellhacks.com/auto-answer-yes-no-prompt-powershell-cmd/). Luettu 15.5.2022.

