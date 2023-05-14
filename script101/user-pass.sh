#! /bin/bash

set -o  errexit
set -o pipefail
set -o nounset

# if apg is not install apg via sudo install apg -y > /dev/null

#Variables 
file_employees='/home/osboxes/employees.csv'
output='/home/osboxes/user-pass.txt'
file_usernnames='/home/osboxes/usernames.txt'
list_passwords='/home/osboxes/passwords.txt'
count_employees=$(tail -n+1 "${file_employees}" | wc -l)

# generate password list

apg -n"${count_employees}" -m15 -x15 -M NCL > "${list_passwords}"

# create username

# take first name and last name + convert them to ascii and translate all letters to lower case and write everytihng to file
tail -n+2 "${file_employees}" | awk -F"," '{ printf "%s;%s\n", $4, $5}' | iconv -f UTF-8 -t ASCII//TRANSLIT | awk '{print tolower($0)}' > /home/osboxes/fullNames.txt

# seperate first and last name and write them both two temporary files
cut -d";" -f1 /home/osboxes/fullNames.txt > /home/osboxes/firstnames.txt

cut -d";" -f2 /home/osboxes/fullNames.txt> /home/osboxes/lastnames.txt

# get first letters of a last name
sed 's/ *\([^ ]\)[^ ]\{1,\} */\1/g' /home/osboxes/lastnames.txt > /home/osboxes/lettersLastname.txt

#join first name and first letters of the last name to a file 
paste --delimiters="\0" /home/osboxes/firstnames.txt /home/osboxes/lettersLastname.txt > "${file_usernnames}"

# join the username and password with a comma and output to a file

paste --delimiters="," "${file_usernnames}" "${list_passwords}" > "${output}"

#remove temporary files 

rm  /home/osboxes/fullNames.txt
rm  /home/osboxes/firstnames.txt
rm  /home/osboxes/lastnames.txt
rm /home/osboxes/lettersLastname.txt
rm "${file_usernnames}"
rm "${list_passwords}" 


