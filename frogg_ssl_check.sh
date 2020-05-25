#!/bin/bash
#            _ __ _
#        ((-)).--.((-))
#        /     ''     \
#       (   \______/   )
#        \    (  )    /
#        / /~~~~~~~~\ \
#   /~~\/ /          \ \/~~\
#  (   ( (            ) )   )
#   \ \ \ \          / / / /
#   _\ \/  \.______./  \/ /_
#   ___/ /\__________/\ \___
#  *****************************
#  Frogg - admin@frogg.fr
#  http://github.com/FroggDev/zabbix-ssl
#  *****************************

##########
# PARAMS #
##########
# init the list of required parameters
REQUIRES=("-a" "-s" "-p")


### PART 1 : send user param in array

# Requires bash 4 for associative array
declare -A PARAMS
for arg in "$@"
do

  case ${arg} in
    # use only params well formated (-command=value)
    # and store as associative array
    (-*=*)
    PARAMS[${arg%%=*}]=${arg#*=}
    ;;
    # help case
    (-h|-help|--help|-?)PARAMS[-a]="help";;
  esac
done

### PART 2 : check if required params are set

# if all required params arent set return a special number to be catch in Zabbix template
for REQUIRE in ${REQUIRES[@]}
do
 [ -z  ${PARAMS[$REQUIRE]} ] && echo 9999999999 && exit
# Set the help for out of box usage 
#[ -z  ${PARAMS[$REQUIRE]} ] && PARAMS[-a]="help"
done


########
# HELP #
########
# ---
# display the script help
function displayHelp
{
# Clean screen
#clear

echo -e "**********************\n"
echo -e "SSL script params:\n"
echo -e "------------------\n"
echo -e "-a={value} : action (expire/exist)\n"
echo -e "-s={value} : server\n"
echo -e "-p={value} : port\n"
echo -e "-h : display help\n"
echo -e "**********************\n"
}
#########
# FUNCS #
#########

# ---
# Check if can get SSL Cert
# @param serverIP
# @param server ssl port
# @return 1 if all is ok else 0
function isSSLCertAvailable()
{
timeout 5 bash -c \
 echo frogg | \
 openssl s_client -connect $1:$2 2>/dev/null | \
 openssl x509 >/dev/null 2>&1 \
 && echo 1 || echo 0
}

# ---
# Get the number of day left until SSL certificate expire
# @param serverIP
# @param server ssl port
# @return number of days left as int
function getSSLExpireDayLeft()
{
# Get expire date
EXPIRE=$(date -d "$(echo frogg | openssl s_client -connect $1:$2 2>/dev/null | openssl x509 -text 2>/dev/null | grep 'Not After' | awk '{print $4,$5,$7}')" +%s);
# Get today as
TODAY=$(date +%s);
# Return diff between expire and today
echo $((($EXPIRE - $TODAY)/(3600*24)))
}

########
# MAIN #
########

case ${PARAMS[-a]} in
  # command get day untill expire
  ("expire")echo $(getSSLExpireDayLeft ${PARAMS[-s]} ${PARAMS[-p]});;
  # command is cert available
  ("exist")echo $(isSSLCertAvailable ${PARAMS[-s]} ${PARAMS[-p]});;
  # command to display help
  (*)echo $(displayHelp);;
esac
