#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

history | awk '{ print $2 }' | sort | uniq -c | sort -nr | head -10 
