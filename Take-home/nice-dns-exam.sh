#! /bin/bash
#
# Nice DNS: the script builds up an authoritative DNS server using DNSmasq,
# and offers options to populate and ask questions to the local DNS server run by the daemon.
#
# Author: Andy Van Maele <andy.vanmaele@hogent.be>

# Stop het script bij een onbestaande variabele
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

# selinux op permissve zetten, anders moeten we een context voor dnsmasq om de nodige toegang te krijgen om te werken in locatie /var/dns
sudo setenforce 0

# install cowsay and figlet
#sudo dnf install epel-release cowsay figlet -y &> /dev/null

### Algemene variabelen worden eerst gedefinieerd
DNS_DIR=/var/dns
DOMAIN=linux.prep
RANGE=10.22.33.0/24
LIST_NAMES=~/voornamen.list
DNS_IP=192.168.76.1

# lijst met voornamen
if [ ! -e "${LIST_NAMES}" ]; then
wget http://157.193.215.171/voornamen.list -P ~/ &> /dev/null
fi

### --- functions ---

# installeer de DNS server, ook al zou de service al geïnstalleerd zijn. 
# Gebruik idempotente commando's waar mogelijk.
function install_dnsserver {
  # Installeer de DNSserver software 

  #if ! [ "$(dnf list installed dnsmasq &> /dev/null)" ] ; then
    sudo dnf install dnsmasq -y &> /dev/null

  #else
   # echo "" > /dev/null
  #fi
  # Ga na of de map voor de DNS-inhoud bestaat. Indien niet, maak ze aan
  if ! [ -d "${DNS_DIR}" ] ; then
    sudo mkdir -p "${DNS_DIR}"
    sudo chmod a+w "${DNS_DIR}"
  else
    echo "" > /dev/null
  fi
  
  # Pas de configuratie van de DNS server aan

  # aanpassen config direcotry naar /var/dns
    sudo sed -i "s|^conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig|conf-dir=${DNS_DIR}|" /etc/dnsmasq.conf

  # interface eth1 toevoegen, dns server mag enkel luisteren naar eth1 port 5353/udp
  if ! systemctl is-enabled dnsmasq.service > /dev/null 2> /dev/null ; then
  sudo sed -i 's/^interface=lo/interface=eth1/' /etc/dnsmasq.conf
  sudo sed -i '/^#except-interface=/a  except-interface=lo' /etc/dnsmasq.conf
  sudo sed -i '/^#listen-address=/a  listen-address=192.168.76.1' /etc/dnsmasq.conf
  sudo sed -i '/^#port=5353/a port=5353' /etc/dnsmasq.conf
  fi
  # Herstart de service 
  if ! systemctl is-enabled dnsmasq.service > /dev/null 2> /dev/null ; then
  sudo systemctl enable dnsmasq > /dev/null 2> /dev/null
  fi
  sudo systemctl restart dnsmasq > /dev/null 2> /dev/null



  # firewall regel toevoegen en service herstarten
  if ! sudo firewall-cmd --info-service dns &> /dev/null ; then
  sudo firewall-cmd --add-service=dns --permanent &> /dev/null
  sudo firewall-cmd --add-port=5353/udp --permanent &> /dev/null
  sudo firewall-cmd --remove-port=53/udp --permanent &> /dev/null
  sudo firewall-cmd --remove-port=53/tcp --permanent &> /dev/null
  sudo firewall-cmd --reload &> /dev/null
fi

}

# Initialiseer een nieuwe database voor het opgegeven domain;
# voeg drie eerste gebruikers toe.
# Bemerk: de range wordt hier hardcoded gebruikt - dit kan in se beter!
function init_dns_db {
  local Domain=${1}
  
  if ! [ -f "${DNS_DIR}"/db."${Domain}" ] ; then
	# Generate an empty file, let everybody write to it
    cat << EOF > "${DNS_DIR}"/db."${Domain}"
# SOA config
# ----------------------------------------------------------------------------
auth-soa=2016021014,hostmaster.${Domain},1200,120,604800
auth-server=${DOMAIN},${DNS_IP}
auth-zone=${DOMAIN},${RANGE}

# A records
# ----------------------------------------------------------------------------
host-record=andy.linux.prep,10.22.33.1
host-record=bert.linux.prep,10.22.33.2
host-record=thomas.linux.prep,10.22.33.3
EOF
  fi
  sudo chmod a+w "${DNS_DIR}"/db."${Domain}"
}

# De functie neemt een naam en een domain als input, en voegt een RR
# (resource record) toe in de database file in de juiste map (globale variabelen)
function create_resource_record {
  local Name
  Name=$(toUpperCase "${1}")
  local Domain=${2}
  local NetworkID='10.22.33'
  local lastHost
  lastHost=$(tail --lines 1 "${DNS_DIR}"/db."${DOMAIN}" | cut --delimiter "." --fields 6)
  local Host=$((lastHost+1))

  echo "host-record=${Name}.${Domain},${NetworkID}.${Host}" >> "${DNS_DIR}"/db."${DOMAIN}"
    sudo systemctl restart dnsmasq &> /dev/null
    short_lookup "${Name}"
}

# Gebruik de bovenstaande functie om N aantal records toe te voegen aan het 
# opgegeven domain. De lijst met namen is opnieuw een globale variabele.
# Bemerk: werken met een tempfile is slechts één mogelijkheid.
# Een oplossing met een array van namen is een andere.
function generate_RRs {
  local Number=${1}
  local Domain=${2}    
  local tempfile

  tempfile=$(mktemp)

  head --lines "${Number}" "${LIST_NAMES}" > "${tempfile}"
  #indien uitreiking willekeuring moet zijn vervang head commando met shuf 
  #shuf --head-count "${Number}" --output "${tempfile}" "${LIST_NAMES}"
  local Record=""
  while read -r Record ; do

	create_resource_record "${Record}" "${Domain}"
  echo "Added ${Record}.$Domain"

  done < "${tempfile}"
  
  rm "${tempfile}"
}

# de short lookup geeft enkel het IP-adres weer in grote letters.
# Hint: figlet
function short_lookup {
  local URL
  URL=$(toLowerCase "${1}")
  local Serv=${DNS_IP}
  local resource_record

  if ! [ "$(dnf list installed boxes &> /dev/null)" ] ; then
    sudo dnf install boxes -y 
  fi
  resource_record=$(dig @"${Serv}" "${URL}"."${DOMAIN}" +short)  
  boxes <<< "${resource_record}"
}

# de fancy lookup geeft eerst een newline, de datum, 
# en dan het resultaat van een lookup in een tekstballon van een koe
# Hint: cowsay
function fancy_lookup {
  local URL
  URL=$(toLowerCase "${1}")
  local Serv=${DNS_IP}
  local date_today
  date_today=$(date +%d-%m-%y)
  local resource_record
  resource_record=$(host "${URL}"."${DOMAIN}")

echo""
echo "vandaag is het: ${date_today}"
echo""
cowsay <<< "${resource_record}"
echo""


}

# Deze functie neemt als input een (hoofd)letter en een domain.
# De namenlijst is opnieuw een globale variabele.
# Alle namen beginnend met de letter worden (short) opge
function range_lookup {
local letter
letter=$(toLowerCase "${1}")
local Domain="${2}"
local listNames=$LIST_NAMES
local tempfile
tempfile=$(mktemp)

grep -i "^${letter}" "${listNames}" > "${tempfile}"

 while read -r Record 
 do

  echo "Looking up ${Record}"
  if  grep -i "${Record}.${DOMAIN}" "${DNS_DIR}/db.${DOMAIN}" > /dev/null ; then
    short_lookup "${Record}"
  fi
    

 done < "${tempfile}"

rm "${tempfile}"
}

function lettergen(){
local letter
letter=$(toUppCase "${1}")
local Domain="${2}"
local listNames=$LIST_NAMES
local tempfile
tempfile=$(mktemp)

grep -i "^${letter}" "${listNames}" > "${tempfile}"

 while read -r Record 
 do

  echo "Looking up ${Record}"
  if ! grep -i "${Record}.${DOMAIN}" "${DNS_DIR}/db.${DOMAIN}" > /dev/null ; then
    generate_RRs
  fi
    

 done < "${tempfile}"

rm "${tempfile}"
}
function toUpperCase(){
  tr "[:lower:]" "[:upper:]" <<< "${1}" 
}
function toLowerCase(){
  tr "[:upper:]" "[:lower:]" <<< "${1}" 
}


### --- main script ---
### Voer de opeenvolgende taken uit

# installeer DNS server, ook al is het reeds geïnstalleerd. 
install_dnsserver  
# initialiseer de local DNS database, indien nodig
init_dns_db "${DOMAIN}"

# Ga na of er argumenten zijn of niet; zoniet onderbreek je het script
if [ "${#}" -eq 0 ]; then
  echo 'At least one argument expected, exiting...'
  exit 1
fi

# With a case statement, check if the positional parameters, as a single
# string, matches one of the text the script understands.
case "${1}" in
 -s|--short)
  shift
  short_lookup "${1}"
  ;;
  -a|--add)
  shift
 create_resource_record  "${1}" "${DOMAIN}"
  sudo systemctl restart dnsmasq
 fancy_lookup "${1}"
  ;;
  -g|--gen)
  shift
  generate_RRs "${1}" "${DOMAIN}"
  sudo systemctl restart dnsmasq
  ;;
  -r|--range)
  shift
  range_lookup "${1}" "${DOMAIN}"
  ;;
  --lettergen) 
  lettergen "${1}"
  ;;
  *)
  fancy_lookup "${1}"
  ;;
esac

# Einde script