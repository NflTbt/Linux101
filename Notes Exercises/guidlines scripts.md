# Guidlines for scripting in Bash

## Template scripts
```script 
#!/bin/bash
#
# naam script -- wat het script doet
#
# Author: Naoufal Thabet
#
#
# Default script settings

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#
# 
#

```

