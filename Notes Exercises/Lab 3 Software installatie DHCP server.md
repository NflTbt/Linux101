# Lab Software installatie: DHCP server

## Informative locations and commands

### debian 

dpkg is the sofware base (low leve tool )of the package manamgent system of a debian based operating system

apt, apt-get and aptitude are higher-level tools (more user friendly) that work on top of dpkg (front end for dpkg).

/etc/apt/sources.list :location repositorys on Debian

deb is the format, as well as extension of the software package format for the Debian Linux distribution and its derivatives. 


### RedHat
rpm is the orignal package manar for RedHat, it is also extension of the software packages

dnf and yum are front end tools for the package manager of RedHat base operating systems 

/etc/yum.repos.d : Location repos on RedHat, every file is a repo


# Exercise 


## Package management

- Installeer onderstaande applicaties of “packages Zorg er voor dat je dit zowel via de grafische gebruikersinterface kan als vanop de command-line.
Git client, ShellCheck, VI Improved, incl. variant met GTK3 GUI, Visual Studio Code

```console
    sudo apt update
    sudo apt upgrade (packages updaten)

    apt search git
    apt show git
    sudo apt install git

    apt search shellcheck
    sudo apt install shellcheck

    apt search vi | grep gtk3
    apt show vim-gtk3
    apt install vim-gtk3

    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/

    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    
    cat  /etc/apt/sources.list.d/vscode.list

    deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main

    cat  /etc/apt/sources.list.d/vscode.list

    sudo apt update

    sudo apt install code
```
## 2. IP configuratie

- VM toevoegen en installeren in virtualbox
    
    Download de iso file
    klik op file en selecteer: import virtual appliance
    selecteer de iso file
    klik next en import. installatie is done

- VM's configureren

    LINUX MINT VM:
    Internal network aanzetten in de linuxmint VM
    zodat die op 1 intern netwerk zit verbonden met de almalinux server

    Stel in de vm zelf de ipv4 config op manual en geeft het een ipv4 address zoals 192.168.76.10 netmask 24

    gebruik "ip a" of "route" in de terminal om te checken

    ALMA LINUX SERVER VM:
    Voor de almalinux server vm zet je 1 Nat network aan zodat hij verbinding naar het internet krijgt. en 1 internal network
    zodat hij de router en dhcp server kan spele voor de linuxmint vm


- pas de netwerk instelling aan in de almalinux vm. Zorg dat de tweede netwerkinterface een vast IP-adres toegekend krijgt (nl. 192.168.76.12/24) door het gepaste configuratiebestand aan te passen.
Op deze netwerkinterface wordt geen default gateway of DNS-server ingesteld. 

```console
sudo ifdown eth1 #turn off the nic
sudo nano /etc/sysconfig/network-scripts/ifcfg-eth1
sudo ifup eth1 #turn on the the nic
```

        via routeor ip a you can check the gateway

- Als beide VMs het juiste IP-adres hebben, dan zou je moeten kunnen pingen tussen de twee. Controleer dit in beide richtingen.

    ping 192.168.76.10 on almalinux vm -> works
    ping 192.168.76.12 on linux mint vm -> works

- Welke voorwaarden moeten voldaan zijn zodat twee hosts op eenzelfde LAN naar elkaar kunnen pingen?

    The need to be in the same subnet (via the subnetmask). If they are in the same range they will be able to ping each other (arp will make this possible).  


## DHCP server Almalinux

- Installeer de ISC DHCP server

    sudo dnf update

    dnf search ISC | grep DHCP
    sudo dnf install dhcp-server.x86_64

- Bewerk het configuratiebestan en declareer een subnet voor ip netwerk 192.168.76.0/24. Deze DHCP-server deelt dynamische IP-adressen uit vanaf 192.168.76.101 tot en met 192.168.76.253. De default lease time komt op 4u, de maximale op 8u. Eens de configuratie klaar is, start je de service op en zorg je er meteen voor dat deze ook bij booten van de VM meteen wordt opgestart.
  
    before you start better take back up of the config files 
    1. go to /etc/dhcp/ but for that you need to be logged on as roo
     
    `sudo su - `

    `cd /etc/dhcp/`

    3. modify dhcpd.conf
   
    `nano /etc/dhcp/dhcpd.conf`

   4. values:
    
    ```script
         default-lease-time 900;
    max-lease-time 10800;
    ddns-update-style none;
    authoritative;
    subnet 192.168.76.0 netmask 255.255.255.0 {
        range 192.168.76.101 192.168.76.253
    }
    ```
    `sudo systemctl start dhcpd` # to start the service.

    `sudo systemctl enable dhcpd` # to enable the service on startup

    `systemctl status dhcpd # check status`

    `journalctl _PID=*PID*` #check log file via process id

    `journalctl -u dhcpd` #check log file via service name


- Configureer opnieuw de tweede netwerkinterface van de Linux Mint-VM. Stel deze opnieuw in om een IP-adres via DHCP aan te vragen. Herstart de netwerkinterface en controleer of je een IP-adres krijgt en of dat overeenkomt met de DHCP-configuratie.

        manually adjust to config of the card (via the gui)
       
- Wat moet je doen om er voor te zorgen dat je Linux Mint-VM opnieuw Internet-toegang kan krijgen?

        The almalinux servier needs to peform nat for the linux mint vmbecause it became the gateway for the linux mint vm 

