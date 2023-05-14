#!/bin/bash
#
# naam script: ip-info.sh
#
#script prints interface name (except the loopback), ip addresses, default gateway and dns server(s) 
#
# Author: Naoufal Thabet
#
#
# Default script settings


set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

ipaddresses=$(ip a -brief | awk 'NR!=1') # save output of ip brief except the first line (loopback interface) and save it to variable

echo "???? IP addresses ????"
ip -brief a | awk 'NR!=1'

echo -e "\n???? Default gateway ????"
# if first field is equal to default print 3,4 and 5th field
ip r | awk '{ if($1 == "default") print $3,$4,$5;}'

dnsservers=$(resolvectl)
echo -e "\n???? DNS server(s) ????"
echo "${dnsservers}"
