#!/bin/bash
#
# naam script: parmas.sh

# Script print:
# - naam van de script
# - Het aantal argumenten
# - Het eerste, derde en tiende argument (of niets als deze niet opgegeven zijn)
# - Als er meer dan drie positionele parameters opgegeven werden, gebruik  dan shift om alle waarden drie plaatsen op te schuiven
# - Geef opnieuw het aantal (overblijvende) argumenten
# - En druk ze allemaal ineens af

# Author: Naoufal Thabet
#
#
# Default script settings

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

echo "Script name: ${0}"
echo "num params: ${#}"
echo "Param 1: ${1}"
echo "Param 3: ${3}"
echo "Param 10: ${10}"

if [ "${#}" -gt '3' ]; then
  shift
  shift
  shift
fi

echo "num params: ${#}" 
echo "Remaining: ${@}"
