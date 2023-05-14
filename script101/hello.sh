#! /bin/bash

## Adjust standard behavior bash 
set -o errexit #abort on nonzero exitstatus
set -o nounset #abort on ubound variable
set -o pipefail #don't hide errors within pipes
##

## Clear screen
clear
##

# Script
printf 'Hallo %s\n' "${USER}"




