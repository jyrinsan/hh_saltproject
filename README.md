## Django ympäristö Saltilla
Moduulin tarkoitus: Asentaa ympäristö Django-webbisovelluksen kehittämiseen Linux-palvelimille. 

### Suunnitelma lopulliselle versiolle
- tuotantoserveri:
  - appikset: hyödyllisiä pikkuohjelmia micro, bash-completion, pwgen, tree
  - palomuuri: ufw palomuurin, asennus, enablointi ja avaus ssh ja apache portille
  - apache asennus, testisivu ja käyttäjän kotisivu
  - django tuotantoasennus
  - testisovellus, jolla toiminta voidaan demota

### Moduulin ulkopuolelle jääviä jatkokehitysehdotuksia
- kehitysserveri, jossa django asennetaan kehitysserverinä
- postgressql ja sen käyttöönotto djangossa vakiona olevan sqllite3:n sijaan

Nimeni: Sanna Jyrinki

Kypsyysaste: Beta

Latauslinkki: https://github.com/jyrinsan/hh_saltproject/tree/master/srv/salt

Moduulin lisenssi: GPL2

### Beta-versio

Moduulin ajo monta kertaa peräkkäin osoittaa sen olevan idempotentti eli muutoksia ei tapahdu kun mitään ei ole muutettu

![Image](images/beta.PNG)

### Alpha-versio
- micro tekstieditori
- ufw palomuuri, enablointi ja avaus ssh portille
- apache asennus, testisivu ja käyttäjän kotisivu

![Image](images/alpha.PNG)
