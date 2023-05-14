#! /bin/bash

set -o nounset
set -o pipefail
set -o errexit

cut -d: -f1 /etc/passwd | sort
