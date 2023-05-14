#! /bin/bash
#
# Provisioning script for srv001

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "Starting server specific provisioning tasks on ${HOSTNAME}"

# TODO: insert code here, e.g. install Apache, add users, etc.
log "installing httpd"

# install apache, php and the ssl module for our webserver (for https)
dnf install -y httpd php mod_ssl

# enable webserver (apache)
systemctl enable --now httpd

# configure firewall (for http and https )
log "configuring firewall"

firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --reload

# install php-mysqlnd so php applications can use mysql dbs
log "install mysqlnd"

dnf install -y php-mysqlnd

# copy test
log "copy php files to var/www/html"


cp "${PROVISIONING_FILES}/test.php" /var/www/html

# we need to adjust the context of folder html and file test.php because root is the one who created those objects so root is owner 

# we also need to alter behavior of apache so it can make connection with a db over network by flipping the boolean on for that feature
log "configureer SElinux"

chcon --reference /var/www/html /var/www/html/test.php
setsebool -P httpd_can_network_connect_db on

# restart webserver for modifictions to take effect
log "restart apache"

systemctl restart httpd

log "webserver provisioning task on ${HOSTNAME} has finished"