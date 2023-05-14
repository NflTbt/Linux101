#!/bin/bash
#
# naam script: all-params.sh
#
#script prints all the parametes given to the script one by one
#
# Author: Naoufal Thabet
#
#
# Default script settings

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

if [ "${#}" -eq '0'  ]; then
  echo "geen parameters meegegeven!" 
  exit 1
fi


for ITEM in "${@}"; do
  echo ${ITEM}
done