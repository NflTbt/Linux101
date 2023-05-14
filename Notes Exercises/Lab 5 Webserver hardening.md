# Webserver hardening

## mysql mariadb server

Als eerste stap beperken we de ruimte voor de mysql server: we perken het IP adres in, en veranderen het poortnummer.

### MariaDB IP-adres veranderen

1. De configuratie van de mysql server vind je typisch in het bestand my.cnf. Bekijk dit bestand. Waar vind je op deze server de werkelijke configuratie terug? Maak een backup van dit 'mariadb...cnf' bestand door het te kopiëren voor je start met het bewerken. 

/etc/my.cnf 

`sudo cp /etc/my.cnf.d/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf.bak`

2. Ga de status van de mariadb server na met systemctl. Verifiëer het IP-adres en poortnummer van de service met ss.

`systemctl status mariadb`

mariadb is running and enabled.

`ss -tln`

local address is * means all ipv4 and ipv6 address and service is listening to port 3306 

3. Open het configuratiebestand. Plaats bij de sectie [server] in het bestand een variabele bind_address, en zet de waarde op het "intnet" IP-adres van je server. Herstart de service, en verifiëer met ss dat de mariadb service enkel nog actief is op dit IP-adres. 

```console
sudo nano /etc/my.cnf.d/mariadb-server.cnf
bind_address=192.168.76.12
sudo systemctl restart mariadb
sudo ss -tln
```

4. Installeer de package netcat. Maak een test-verbinding met de mariadb server: nc -nvz [IP-adres] 3306. Test dit eveneens met de twee andere IP-adressen van je server (NAT, localhost). Verifiëer dat dit niet langer werkt! 

```console
sudo dnf install nmap
nc -nvz 192.168.76.12 3306
```
with ip of the server it works but with others it doessn't anymore even with localhost


### MariaDB poortnummer veranderen

1. 3306 is een te publiek gekende poort - en trekt gemakkelijk online de aandacht van hackers. Laten we een alternatieve poort zoeken: welk poortnummer vind je in /etc/services terug voor het niet langer gebruikte UniSQL protocol? Noteer.

```console
sudo cat /etc/services | grep UniSQL
port: 1978
```

2. Bewerkt opnieuw het mysql configuratiebestand, en plaats een waarde port onder het IP-adres van hierboven. Stel op deze manier het 
poortnummer in op dit van UniSQL.Herstart de mariadb service.

```console
  sudo nano /etc/my.cnf.d/mariadb-server.cnf
  port=1978
  sudo systemctl restart mariadb
```
gives an errr after restarting 

3. Als alles goed gaat, zal je mariadb server niet opstarten! Immers: SELinux laat slechts een beperkt aantal poorten toe voor MariaDB. 
Ga op https://dev.mysql.com/doc/refman/8.0/en/selinux-context-mysqld-tcp-port.html na hoe je het hierboven gekozen poortnummer kan toevoegen aan de juiste SELinux context. Herstart nu nogmaals je mariadb service - tot hij werkt.

```console
# we need to add network port type definition -a for add - t for type (type name here is mysqld_port_t ) and we need to specify the new port (with the p flag)
sudo semanage port -a -t mysqld_port_t -p tcp 1978
sudo semanage port -l | grep mysql
sudo systemctl restart mariadb

```

4. Test je (mariadb) server met nc -nvz [IP-adres] [nieuw poortnummer].
`sudo nc -nvz 192.168.76.12 1978`

works now 

### MariaDB directory veranderen

 1. Standaard bewaart de DB server zijn data in de map /var/lib/mysql. Maak een map /dbdata aan op je server. Verander de eigenaar en de groep van deze map naar mysql:mysql - het is deze gebruiker die operaties uitvoert op de map als de service zaken verandert!

```console
  cd /
  sudo mkdir dbdata
  sudo chown mysql:mysql dbdata
```

 2. Wijzig in het config bestand de default locatie voor de database data naar deze map.

```console 
sudo nano /etc/my.cnf.d/mariadb-server.cnf 
datadir=/dbdata
```

 3. Herstart de mariadb service. Als alles goed gaat, zal je mariadb server niet opstarten! Opnieuw gaan we ook SELinux nog moeten aanpassen opdat deze map gebruikt mag worden.
 4. Ga na op https://mariadb.com/kb/en/selinux/ welke aanpassingen je nog moet uitvoeren op je nieuwe map. 
 Herstart nu nogmaals je mariadb service - tot hij werkt.

```console
#we need to set a file contect for the new db directory via type mysqld_db_t
  sudo semanage fcontext -a -t mysqld_db_t "/dbdata(/.*)?"
  sudo restorecon -Rv /dbdata #to restore context according to the file context recursivly (-R)
  sudo systemctl restart mariadb
```

### mysql data input

Nu we een werkende database server hebben (weliswaar op een ingeperkt IP, een andere poort en een niet conventionele map), kunnen we de sql database ook initialiseren en er een set data aan voeden:

 1. Stel een (mysql) root wachtwoord in voor deze server met mysqladmin password
 2. Verbind met de mysql server op de CLI met mysql -u root -p. Geef het gekozen wachtwoord in.
 3. Maak een gebruiker aan die toegang krijgt tot een test-database. In SQL: 

 CREATE DATABASE IF NOT EXISTS trialsite;
 GRANT ALL ON trialsite.* TO 'www_user'@'%' identified by 'YourSitePassword';
 FLUSH PRIVILEGES;

 4. Voer met deze nieuwe gebruiker een set van data in in jouw database:

 mysql --user="www_user" --password="YourSitePassword" "trialsite" << _EOF_
 DROP TABLE IF EXISTS trialsite_tbl;
 CREATE TABLE trialsite_tbl (
   id int(5) NOT NULL AUTO_INCREMENT,
   name varchar(50) DEFAULT NULL,
   PRIMARY KEY(id)
 );
 INSERT INTO trialsite_tbl (name) VALUES ("Mr. IPtables");
 INSERT INTO trialsite_tbl (name) VALUES ("Mrs. SELinux");
 _EOF_

 5. Test je gecreëerde database met het volgende bash script test_db.sh. Je kan dit zelf aanmaken op je server system:

 #!/bin/bash
 test_database='trialsite'
 test_table='trialsite_tbl'
 test_user='www_user'
 test_password='YourSitePassword'

 mysql --host=192.168.76.12 --port=1978 \
   --user="${test_user}" \
   --password="${test_password}" \
   "${test_database}" \
   --execute="SELECT * FROM ${test_table};"

 Als je succesvol test, is je screen output het volgende:
 [admin@server ~]$ bash test_db.sh 
 +----+--------------+
 | id | name         |
 +----+--------------+
 |  1 | Mr. IPtables |
 |  2 | Mrs. SELinux |
 +----+--------------+

## webserver [apache2]

In dit vervolg zetten we enerzijds een php pagina op die kan verbinden met de database server; anderzijds gaan we aan de slag met het firewall-cmd.

### Testen basisconnectie

 1. Surf vanop je Linux GUI VM naar jouw webserver op 192.168.76.12. Waardoor kan je niet verbinden, als dit niet zou werken?
 2. Pas de firewall op de server aan opdat deze verbinding wel kan tot stand komen.

 `sudo firewall-cmd --add-service=mysql --permanent`

### PHP script met SELinux context

 1. Installeer de extra package php-mysqlnd op je server. Deze laat toe om via php te communiceren met een SQL server - wat we vervolgens gaan doen.

 `sudo dnf install -y php-mysqlnd`
`
 2. Ga naar jouw home folder (cd ~). Download hier het bestand test.php vanaf http://157.193.215.171/test.php

```console
  wget http://157.193.215.171/test.php
  or
  curl -O http://157.193.215.171/test.php
```

 3. Verplaats (met mv) vervolgens dit bestand naar de map /var/www/html.

```console
 sudo mv test.php /var/www/html
cd /var/www/html

```

 1. Dit bestand is momenteel eigendom van jou - de downloader. Ga dit na 

`ls -dZ`

 2. Echter, bestanden in deze map moeten toebehoren aan de juiste context. Neem de map /var/www/html als referentie, en stel dezelfde SELinux instellingen in voor dit nieuwe bestand. Hint: https://linuxconfig.org/introduction-to-selinux-concepts-and-management -> zoek op chcon --reference

`sudo chcon -t httpd_sys_content_t test.php `

 3. Als je succesvol bent, zal de PHP pagina correct inladen - maar wel geen connectie kunnen maken met de database server. Error:

### PHP met SELinux connections

We kunnen bij connectieproblemen verleid worden tot zoeken naar problemen bij de firewall. Echter, gezien de database service op dezelfde server geïnstalleerd is als de apache HTTP server, verlopen de verbindingen van het ene software programma naar het andere niet via de externe IP-adressen. Die gaat via het localhost adres - ook al worden andere IP-adressen gebruikt. Wie het verkeer monitort met e.g. wireshark of tcpdump (zie het vak "CyberSecurity & Virtualisation"), zou dit kunnen aantonen. Dit valt echter buiten de scope van dit vak "Linux".

Long story short: SELinux laat een HTTP daemon niet standaard toe om verbindingen met een database server te leggen. Om dit toch toe te laten, moet een boolean waarde verander worden. De stappen hiervoor vind je op https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/sect-security-enhanced_linux-booleans-configuring_booleans
Beoogd eindresultaat

`sudo setsebool httpd_can_network_connect_db on`

Je kan vanaf je Linux GUI VM verbinden met de test.php pagina, en die geeft het volgende weer:

