#!/bin/bash
#
# naam script: srm.sh
#
#safely remove files that are given as parameters, files get compressed and moved to ~/trash
#
# Author: Naoufal Thabet


# Default script settings

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes


## varaibles ##
trash='~/.trash'


# if no parameters were give, echo message and exit script
if [ "${#}" -eq '0' ]; then
  echo "Expected at least one argument!"
  exit 1
fi

# if the hidden trash direcotry doesn't exit create one and output the message in the console
if [ ! -d "${trash}" ]; then
  echo "Created trash folder $dir" 
  mkdir "${trash}" # no p switch needed, sub directories are not expected
fi

# remove files older than 14 days in the trash directory
find "{trash}" -type f -ntime+14 -exec rm -v {} \;

# check if all parameters are normal files if yes compress and remove verbosely 
for ITEM in "${@}"; do
  if [ -f "${ITEM}" ]; then
    gzip "${ITEM}" 
    mv -v $("${ITEM}".gz "${trash}"/"{ITEM}".gz)
  else
    echo "${ITEM} is not a file! Skipping..."
  fi
done


