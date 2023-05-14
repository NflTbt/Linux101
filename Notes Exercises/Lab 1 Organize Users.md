
# Lab 1

## Informative locations and commands 

in /etc/passwd you can find all info about user accounts and modify them.

in /etc/shadow/ you can find the passwords of the users.

in /etc/group you can see all the groups present on the system and modify them.

via command `id [username]` you van find information about a specific user, there are flags to get specific type of info

login as other user: `su - *username*` (look at the spaces!!)
> example: to login as root sudo su -

To lock a user you can use the following commands:
- `sudo usermod -- lock *username*`
- `sudo passwd --lock *username*`
- `sudo chage --expiredate 0 *username*`
- `sudo usermod --shell /sbin/nologin *username*` or modify shell in /etc/ in the row of the user account
- add an "!" after "$" in file /etc/shadow in the row of the useraccount

To unlock change the flags to unlock or change the files accordingly and to check the status you can use `id *username*` or `sudo passwd --status *username*` 
## Commands

`sudo adduser *username*`: is a command to create a user in an interactive way.

`sudo useradd [options] *username*` : add user but you need to know the right options to configure a user account properly. serperate mutliple secundary group names with a ***","***
> example: sudo useradd --create-home --group *primary group name* --groups *secundary group name(s)* --shel /bin/bash *username*

`passwd *username*`: to create a password for a user, for other you need **sudo** permissions.

`sudo addgroup *groupname*`: interactive way to create a group.

`sudo useradd --group *groupname*`: to overwrite user's primary group. 

`sudo useradd --groups *groupname(s)*`: to overwrite user's secundairy group(s).

`sudo useradd -a --groups *groupname(s)*`: to append to user's secundary group(s).

`sudo groupadd [options] *groupname*`: to create a new group but you need to know the corect options to create a group properly.

`sudo chmod [options] *path,name or folder*`: to change the permisions of a file or folder. see man pages for more info
> eamples:
> - changed owner of a file or director: `sudo chmod username *path, name file or folder*`
> - give owner and group all permissons on a file or folder: `chmod 771  *path, name file or folder*`
> - prevent others from deleting a file or folder even when they are part of the group owners except owners (add sticky bit): `sudo chmod +t *path, name file or folder*`
> - make sure that groupowners automatically become group owners to a file or folders (when new sub directories or files are created): `sudo chmod g+s *path, name file or folder*`

`sudo userdel --remove *username*`: to remove a user, for more info consult man pages.