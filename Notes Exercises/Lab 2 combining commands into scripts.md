# Lab Combining commands into scripts

## Informative locations and commands



## Exercise 


## 1. Variabelen

 - Zoek de waarde op van volgende shellvariabelen. Wat betekent elke variabele? 
        
    1. PATH: Directories were the executable files are located
    2. HISTSIZE: variable is the maximum number of lines of history that we can store in memory
    3. UID: unique id of the current user
    4. HOME: path of home directory of the current user
    5. HOSTNAME: is a name which is given to a computer and it attached to the network
    6. LANG: chosen language 
    7. USER: current user
    8. OSTYPE: type of the operating system
    9. PWD: the current working directory

# Lab 2
## 2. Variabelen in scripts

 - Maak een script aan met de naam hello.sh. De eerste lijn van een script is altijd een "shebang". We gaan dat niet voor elke oefening herhalen, vanaf nu moet elk script een shebang hebben! De tweede lijn drukt de tekst "Hallo GEBRUIKER" af (met GEBRUIKER de login-naam van de gebruiker). Gebruik een geschikte variabele om de login-naam op te vragen. Maak het script uitvoerbaar en test het.

```script
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

```

`sudo chmod +x hello.sh`
`./hello.sh`

- De variabele met de login-naam van de gebruiker is niet gedefinieerd in het script zelf. Hoe heet dit soort variabelen?

    Environment variables

- Maak nu een tweede script aan met de naam hey.sh. Dit script drukt "Hallo" en de waarde van de variabele ${person} af (merk op dat we deze met opzet nog niet initialiseren!). Wat zal het resultaat zijn van dit script? M.a.w. wat drukt het script af wanneer je het uitvoert? Denk eerst na voordat je het uitprobeert!

    only hello will be printed on the stdout
        
- Voeg meteen na de shebang een regel toe met het commando set -o nounset en voer het script opnieuw uit. Wat gebeurt er nu? Wat denk je dat beter is: deze regel toevoegen of niet?

    scripts gives an error and exits withut executing a single command.

    yes, to avoid unforceen results because, because the script will excute subsquent lines.

- Definieer de variabele ${person} op de command-line (dus NIET in het script!). Druk de waarde ervan af om te verifiëren dat deze variabele bestaat. Voer vervolgens het script uit. Werkt het nu?

    No, declared variable in the terminal is outside the scope of the script.

- Wat moet je doen om de variabele ${person} zichtbaar te maken binnen het script?

    by exporting the variable.
    `export person`

- Verwijder de variabele ${person} met unset. Verifieer dat deze niet meer bestaat door de waarde op te vragen. Combineer nu eens het definiëren van deze variabele en het uitvoeren van het script in één regel, met een spatie tussen beide. De opdrachtregel heeft de vorm van: variabele=waarde ./script.sh. Werkt het script? Kan je de variabele nog opvragen nadat het script afgelopen is?

        Yes, and no, after the script is finished the variable cease to exist (temporary)
## 3. I/O Redirection en filter

- Op een Linux-systeem van de Debian-familie kan je een lijst van geïnstalleerde software opvragen met het commando apt list --installed. Doe dit op jouw Linux-Mint VM. Het commando genereert heel wat output, zo veel dat je misschien zelfs niet de volledige lijst kan zien in de terminal. Zorg er voor dat je telkens een pagina te zien krijgt en dat je op spatie kan drukken voor de volgende pagina.
    `apt list --installed | less`

- Als we verschillende dingen willen doen met de lijst van geïnstalleerde software, dan moeten we het commando telkens opnieuw uitvoeren. Dat is tijdrovend. Schrijf in plaats daarvan het resultaat van het commando weg in een bestand packages.txt.
    `apt list --installed > packages.txt`

- Bij het wegschrijven naar een bestand krijg je toch nog een waarschuwing te zien. Zorg er voor dat deze niet getoond wordt.
    `apt list --installed > packages.txt 2> /dev/null`

- Toon de eerste tien lijnen van packages.txt (met het geschikte commando!). De eerste lijn bevat nog geen naam van een package en hoort er dus eigenlijk niet bij. Gebruik een geschikt commando om er voor te zorgen dat die eerste lijn uit de uitvoer van apt list niet mee weggeschreven wordt naar packages.txt. Controleer het resultaat!

    `head packages.txt`
    `apt list --installed 2> /dev/null | tail -n+2 > packages.txt`

- Gebruik een geschikt commando om te tellen hoeveel packages er momenteel geïnstalleerd zijn. Tip: elke lijn van packages.txt bevat de naam van een package.
    `wc -l packages.txt`

- Op elke lijn staat naast de naam van de package en de versie ook de processorarchitectuur vermeld (bv. amd64). Toon een gesorteerde lijst van alle architecturen die voorkomen in het bestand (geen dubbels afdrukken!) en ook hoe vaak elk voorkomt.
    `cut -d" " -f3 packages.txt | sort | uniq -c`

- Zoek in packages.txt naar alle packages met python in de naam. Hoeveel zijn dit er?
    `grep python packages.txt | wc -l`
    98

- Het commando apt list --all-versions toont zowel packages die geïnstalleerd zijn als beschikbare packages. Gebruik het om alle packages met python in de naam op te lijsten. Let op: het is hier niet nodig om een apart commando te gebruiken om te zoeken op naam. Je kan dit al opgeven met het commando apt-list zelf.

    `apt list '*python*'`

- Het is vervelend dat in de uitvoer van dit commando lege lijnen zitten. Zo kunnen we het aantal niet makkelijk tellen. Laat ons deze lege regels wegfilteren aan de hand van een geschikt commando. (Tip: in een lege lijn wordt het begin van de regel onmiddellijk gevolgd door het einde van een regel). Schrijf het resultaat weg naar python-packages.txt. Zorg ook dat de waarschuwing niet getoond wordt en dat die eerste lijn (Listing...) niet mee weggeschreven wordt.
    ◘`apt list '*python*' |sed '1d' | sed '/^$/d'> python-packages.txt 2> /dev/null`

- Hoeveel packages zijn er opgesomd in python-packages.txt? Hoeveel daarvan hebben de vermelding "installed"?

    `wc -l python-packages.txt`
    4606 packages

    `grep installed python-packages.txt| wc -l`
    88 

- Als je goed kijkt in python-packages.txt zal je zien dat sommige packages 2x vermeld worden (bv. hexchat-python) en dus dubbel geteld worden. Haal enkel de package-namen uit het bestand (zonder versienummer, enz.) en laat alle dubbels vallen. Hoeveel packages hou je dan nog over?

    `cut -d/ -f1 python-packages.txt | sort | uniq | wc -l`
    4396

## 2.4.4 Filters in scripts

- Schrijf een script list-users.sh dat in het bestand /etc/passwd enkel de gebruikersnamen filtert en deze alfabetisch gesorteerd afdrukt.
```script
    #! /bin/bash

    set -o nounset
    set -o pipefail
    set -o errexit

    cut -d: -f1 /etc/passwd | sort

```

- Maak een variant list-system-users.sh dat enkel de "systeemgebruikers" (gesorteerd) afdrukt, d.w.z. gebruikers met een UID kleiner dan 1000.

```script
    #! /bin/bash

    1set -o errexit
    set -o nounset
    set -o pipefail

    awk -F: '{ if($3 < 1000) print $1 }' /etc/passwd
    # -F delimeter hier :
    # if 3rd field (the UID) is smaller than 1000
    # print the first field from file /etc/passwd
```

- Schrijf een script topcmd.sh dat een lijst afdrukt van de 10 commando's die je tot nu toe het vaakst gebruikt hebt

```script
#! /bin/bash

    set -o errexit
    set -o nounset
    set -o pipefail

    history | awk '{ print $2 }' | sort | uniq -c | sort -nr | head -n10  

    #from history take the second field (no delimter needed space is the seperatseparatoror here.
    # natural sorter to use the uniq command
    # in the uniq command we use the c option to have the distinct history entry and how many times they occure
    # we sort again by nummeric value of the entry via n (the occurences )but in rever order (largest number first )via r
    # via head take the first 10 (10 is default amount for head but i added in case the default value was changed)
```

## 2.4.5 Uitdaging: gebruikersnamen en wachtwoorden genereren

```script
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
```



