#! /bin/bash

1set -o errexit
set -o nounset
set -o pipefail

awk -F: '{ if($3 < 1000) print $1 }' /etc/passwd
