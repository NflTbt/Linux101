# Physical layer

- Turned on the network card and assigned it the internal network in virtualbox

# Network Layer
- adjust networkmask of eth 1 to 255.255.255.0
- add default gateway 192.168.76.8 to eth1 
- restart network service

# Transport layer
## httpd

-  Adjusted that httpd listens to port 80 in  /etc/httpd/conf/httpd.conf
- started httpd service
- enabled httpd service 

## firewall
- added http and https service permanently 
- added ports 80/tcp and 443  permanently
- reloaded firewall 

# applicaton
## httpd
-	Adjust documentroot to /var/www/html in /etc/httpd/conf/httpd.conf
-  gave everyone read permissions to /var/www/html
- restored context folder /var/www via the restorecon cmd (recursivly )

## php / mariaDB
- set sebool setsebool -P httpd_can_network_connect_db on  to on so php can make a nework connection with the DB (permanent flag )


