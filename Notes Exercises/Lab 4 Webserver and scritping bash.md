# Lb 4 Webserver & scriting

## Webserver opzetten

In dit labo zullen we een webserver opzetten in de (server) VM die je in het vorige labo gemaakt hebt. Een van de populairste toepassingen van Linux als server is de zgn. LAMP-stack. Deze afkorting staat voor Linux + Apache + MySQL + PHP. De combinatie vormt een platform voor het ontwikkelen van webapplicaties waar vele bekende websites (bv. Facebook) op gebaseerd zijn.

Beschrijf telkens zo precies mogelijk de procedure die je gevolgd hebt. Zorg er voor dat je aan de hand van je beschrijving deze taken later heel vlot kan herhalen als dat nodig is - we gaan deze stappen later gebruiken om te automatiseren! Test ook telkens na elke stap dat die correct verlopen is.

### De Apache webserver installeren

Het is belangrijk dat je controleert voordat je aan dit labo begint, dat je twee netwerkinterfaces hebt op je virtuele machine. De ene moet van het type NAT zijn. Deze heeft verbinding met het internet en heeft typisch als IP-adres 10.0.2.15. De andere netwerkinterface moet van het type Internal Network zijn. Via deze kan je communiceren met de Linux GUI VM en je webserver testen. Als je niets hebt veranderd de standaardinstellingen van VirtualBox, is het server IP-adres hoogstwaarschijnlijk 192.168.76.2.

1. Installeer Apache op je virtuele machine en verifieer dat hij draait en vanop de GUI VM bereikbaar is.
2. Installeer ondersteuning voor PHP en verifieer dat dit werkt, bijvoorbeeld met een eenvoudige PHP-pagina

```console
sudo dnf install httpd
sudo systemctl start httpd
sudo systemctl status httpd
sudo systemctl enable httpd
curl localhost
```
### isntall PHP

```script
sudo dnf install php # install php
  cd /var/www/html #webserver default location for website 
  nano info.php #create a webpage page so we can later test if php works
  <?php phpinfo(); ?> # syntax to create the php info page

  curl http://localhost/info.php #to transfer dat from server to client, in this case it will output the webpage in html code on the console
```

### MariaDB (MySQL)

MariaDB is de naam van een variant (fork) van de bekende database MySQL. Op sommige Linux-distributies (zoals Fedora) is MySQL zelfs niet meer beschikbaar. MariaDB is wel grotendeels compatibel en kan perfect dienen als vervanger. Installeer MariaDB op je virtuele machine. Voer daarna het script mysql_secure_installation uit om het root-wachtwoord voor MariaDB in te stellen.

#### install MariaDB

```console
sudo dnf install mariadb-server
  sudo systemctl start mariadb
  sudo systemctl status mariadb
  sudo systemctl enable mariadb
```

#### secure MariaDB

enter `  sudo mysql_secure_installation` and follow the interactive configuration program.

#### login MariaDB

`mysql -uroot -phogent2022 mysql`

-u is option is for username and the -p option is for password. we are loging on with the root account of the database != root account of the linux server, it's the one we created via the wizard.

## Testing & logfiles

1. Met welk commando test je of een host op het netwerk op dit moment online is? Probeer dit uit vanop je VM met het IP-adres van je host-systeem en voeg de uitvoer hieronder in. Welk protocol uit de TCP/IP familie wordt door deze tool gebruikt?

    with the `ping` commmand, ping uses icmp

2. Met het commando ss -tln kan je opvragen welke services er draaien op je systeem, ahv. de open netwerkpoorten. Leg uit wat de opties (-tln) betekenen. Probeer het commando uit op je VM wanneer Apache en MariaDB draaien en voeg de uitvoer hieronder in. Geef voor elke open poort beneden de 10.000 welke netwerkservice er mee geassocieerd is.

t = to list tcp connections
l = to list sockets that listening
n = prevents the resolutiion of service names and prints the numaric value of the ports

3. Met welk commando kan je de logs voor een bepaalde netwerkservice bekijken?

`journalctl`

4. Wat is de naam van het logbestand waar je kan opvolgen welke webpagina's er opgevraagd worden aan je webserver?



5. Open dit bestand met `tail -f` en laad een webpagina via een webbrowser. Wat gebeurt er in het logbestand?

output stays fixed to the terminal and it's dynamic, new entries to the log are immediatly visible (appended / updated)

## Scripting oefeningen '102'

see folder [script102](../script102/)


