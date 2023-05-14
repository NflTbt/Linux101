#!/bin/bash
#
# naam script: sort-passwd.sh
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

#if no paramaters are given is queal to giving number 1 as parameter
# passwd file will be formated as a tabe and sorted by username
# t= table, s= delemiter in this case a ":"
# k = sort firt field / column.
if [ "${#}" -eq '0' ]; then
  sudo column -t -s ":" /etc/passwd | sort -k 1

# if the parameter is between 1 and 7
elif [ "${1}" -gt '0' ] && [ "${1}" -lt '8' ]; then

    # check if paramter is 3 or 4
    #sort nummeric (n) by the 3 or 4th field
  if [ "${1}" -eq '3' ] || [ "${1}" -eq '4' ]; then
     sudo column -t -s ":" /etc/passwd | sort -n -k "${1}"
  else
     sudo column -t -s ":" /etc/passwd | sort -k "${1}"
  fi
  ## if some other parameter was enterd other than a number between 0 and 7 
else
  echo "Please enter a number between 1 and 7 (included)"
fi