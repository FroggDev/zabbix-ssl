### Zabbix Template Module SSL version 1.0.0

Tested on Zabbix 4.4

# Introduction
Template for zabbix to check SSL expiration using external script.
It can check:
* days left until expire
* if SSL certificate can be read

# Requirement
The script use the commands **smbclient** so it requires the linux package **openssl**

To install it you can use the package manager of your distribution

Exemple
```bash
apt-get install openssl
```
By the way you may require sudoer rights to run the command.

# Installation

## Content
The template installation require 2 files:
* **frogg_ssl_check.sh** Zabbix external script
* **frogg_ssl_check.xml** Zabbix template configuration

## External script

You need to place the script **frogg_ssl_check.sh** into zabbix external forlder **externalscripts** (by default in **/usr/lib/zabbix/externalscripts**) 

You can find the external script folder in Zabbix configuration file **zabbix_server.conf** (by default in **/etc/zabbix/zabbix_server.conf**)

You will need to add execute permission on the script
```bash
chmod +x frogg_ssl_check.sh 
```

### Testing the installation
You can run the command:
- To Test SSL certificate 
```bash
./frogg_ssl_check.sh -a=exist -s=frogg.fr -p=443
```
- To get day left of ssl certificate 
```bash
./frogg_ssl_check.sh -a=expire -s=frogg.fr -p=443
```
## Template

Then you need to import the **frogg_ssl_check.xml** template configuration file in the zabbix web interface in **Template** tab using the import button

# Host configuration
The template use 5 macros :

MACRO | Description | Default
----- | ----------- | -------
{$SSL.DNS} | web server DNS name | 
{$SSL.PORT} | server web ssl port | port 443
{$SSL.INFO} | number of days left before triggering information | 60 days
{$SSL.WARN} | number of days left before triggering warning | 30 days
{$SSL.AVG} | number of days left before triggering average | 10 days

# Template items
![Zabbix SSL Template](https://tool.frogg.fr/upload/github/zabbix-ssl/items.png)

# Template triggers
![Zabbix SSL Template triggers](https://tool.frogg.fr/upload/github/zabbix-ssl/triggers.png)

# Debuging

Going further...This step is working with most of externals scripts

If you got troubles getting an external script working, first :
1. Check the Zabbix tab **Monitoring > lastest data**
If you select an host, you should see all items linked to it, check for your item and you should see the lasted data linked to it.
If it appear in gray (disabled) that mean there is something wrong with the external script (rights, path, arguments ...)
To find more about it you can check logs
2. By default the logs are in **/var/log/zabbix/zabbix_server.log** or you can find the log path in Zabbix configuration file **zabbix_server.conf** (by default **/etc/zabbix/zabbix_server.conf**)

To get the last log lines you can use for example:
```bash
tail -f /var/log/zabbix/zabbix_server.log
```
Then look at the script trouble...

Example:
![Zabbix NFS error sample](https://tool.frogg.fr/upload/github/zabbix-nfs/error.png)
In this case Zabbix cannot find the path of the script as you can see *no such file or directory*
