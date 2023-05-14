#! /bin/bash
#
## Usage: ./passphrase.sh [N] [WORDLIST]
##        ./passphrase.sh -h|--help
##
## Generate a passphrase, as suggested by http://xkcd.com/936/
##
## N           The number of words the passphrase should consist of
##             Default: 4
##
## WORDLIST    A text file containing words, one on each line
##             Default: /usr/share/dict/words
##
## OPTIONS     -h, --help
##
##
## EXAMPLES
##
## $ ./passphrase.sh
## unscandalous syagush merest lockout
##
## $ .passphrase.sh /usr/share/hunspell/nl_BE.dic 3
## tegengif/Ze Boevink/PN smekken

#---------- Shell options -----------------------------------------
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#---------- Variables ---------------------------------------------

num_words=4
word_list='/usr/share/dict/words'

#---------- Main function -----------------------------------------
main() {
  process_cli_args "${@}"
  generate_passphrase
}

#---------- Helper functions --------------------------------------

# Usage: generate_passphrase
# Generates a passphrase with ${num_words} words from ${word_list}
generate_passphrase() {
 shuf --head-count "${num_words}" "${word_list}" | tr '\n' ' '
 printf '\n'
}

# Usage: process_cli_args "${@}"
#
# Iterate over command line arguments and process them
process_cli_args() {

  # If the number of arguments is greater than 2: print the usage
  # message and exit with an error code
  if [ ${#} -gt 2 ]; then
    echo -e "At most two arguments expected, got ${#}" >&2
    usage
    exit 2
  fi
  # Loop over all arguments
  while [ "${#}" -gt 0 ]; do

    # Use a case statement to determine what to do
    case "${1}" in 

      # If -h or --help was given, call usage function and exit
      -h|--help)
        usage
        exit 0
        ;;
      # If any other option was given, print an error message and exit
      # with status 1
      -*)
      echo "Uknown option ${1}"
      exit 1
      ;;

      # In all other cases, we assume N or WORD_LIST was given
      *)
        # If the argument is a file, we're setting the word_list variable
        if [ -f "${1}" ]; then
          word_list="${1}"
        # If not, we assume it's a number and we set the num_words variable
        else 
          num_words="${1}"
        fi
        ;;
     esac
     shift
   done     
}

# Print usage message on stdout by parsing start of script comments.
# - Search the current script for lines starting with `##`
# - Remove the comment symbols (`##` or `## `)
usage() {

usage_output=$(grep '^## ' "${0}" | sed  's/^## //g')
printf '%s' "${usage_output}"

# cat << _EOF_
# Usage: ${0} [N] [WORDLIST]
#        ${0} -h|--help

# Generate a passphrase, as suggested by http://xkcd.com/936/

# N           The number of words the passphrase should consist of
#             Default: ${num_words}

# WORDLIST    A text file containing words, one on each line
#             Default: ${word_list}

# OPTIONS     -h, --help


# EXAMPLES

# $ ${0}
# unscandalous syagush merest lockout

# $ ${0} /usr/share/hunspell/nl_BE.dic 3
# tegengif/Ze Boevink/PN smekken
# _EOF_
}

# Call the main function
main "${@}"
