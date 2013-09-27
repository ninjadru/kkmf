#!/bin/bash
# kkmf
# Description : A bash script for doing emueration over snmp
# Version : 1.0
# Author : Dru Streicher
# Licence : GPLv2

# Commands
CMD_BASENAME="/usr/bin/basename"
CMD_SNMPGET="/usr/bin/snmpget"
CMD_SNMPWALK="/usr/bin/snmpwalk"
CMD_AWK="/usr/bin/awk"
CMD_GREP="/bin/grep"
CMD_EXPR="/usr/bin/expr"

# Script name
SCRIPTNAME=`$CMD_BASENAME $0`

# Version
VERSION="1.0"

# Default options
COMMUNITY="public"
HOSTNAME="127.0.0.1"

# Platform variables
WIN="windows"
LIN="linux"
CIS="cisco"

# Option processing
print_usage() {
  echo "Usage: ./kkmf -H 127.0.0.1 -C public"
  echo " $SCRIPTNAME -H ADDRESS"
  echo " $SCRIPTNAME -C STRING"
  echo " $SCRIPTNAME -p PLATFORM"
  echo " $SCRIPTNAME -h"
  echo " $SCRIPTNAME -V"
}

print_version() {
  echo $SCRIPTNAME version $VERSION
  echo ""
  echo "This nagios plugin comes with ABSOLUTELY NO WARRANTY."
  echo "You may redistribute copies of this plugin under the terms of the GNU General Public License v2."
}

print_help() {
  print_version
  echo ""
  print_usage
  echo ""
  echo "Check the memory on pfsense"
  echo ""
  echo "-H ADDRESS"
  echo " Name or IP address of host (default: 127.0.0.1)"
  echo "-C STRING"
  echo " Community name for the host's SNMP agent (default: public)"
  echo "-p PLATFORM"
  echo " The Plateform on the networked device (example: linux)"
  echo "-h"
  echo " Print this help screen"
  echo "-V"
  echo " Print version and license information"
  echo ""
  echo ""
  echo "This plugin uses the 'snmpget' command and the 'snmpwalk' command included with the NET-SNMP package."
  echo "This plugin support performance data output."
  echo "If the percentage of the warning level and the critical level are set to 0, then the script returns an OK state."
}

while getopts H:C:t:d:w:c:p:hV OPT
do
case $OPT in
    H) HOSTNAME="$OPTARG" ;;
    C) COMMUNITY="$OPTARG" ;;
    p) PLATFORM="$OPTARG" ;;
    h)
      print_help
      exit $STATE_UNKNOWN
      ;;
    V)
      print_version
      exit $STATE_UNKNOWN
      ;;
   esac
done

if [ "$PLATFORM" == "$LIN" ]
then
# OID's
OID_DISK_DESC="hrStorageDescr"
OID_SYST_HOST="sysName.0"
OID_SYST_DESC="sysDescr.0"
OID_PORT_TCPO="tcpConnState."
OID_PORT_UDPO="udpLocalPort."
OID_INTF_NAME="ifName"
OID_SYST_UPTI="sysUpTimeInstance"
OID_SYST_CONT="sysContact.0"
OID_SYST_LOCA="sysLocation.0"


# linux processing
SYST_HOST=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_HOST|cut -d ':' -f4|cut -d ' ' -f2)
SYST_DESC=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_DESC|cut -d ' ' -f4)
SYST_FLAV=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_DESC|cut -d '-' -f5|cut -d ' ' -f1)
SYST_KERN=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_DESC|cut -d ' ' -f6)
SYST_LOCA=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_LOCA|cut -d ' ' -f4-)
SYST_CONT=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_CONT|cut -d ' ' -f4)
SYST_UPTI=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_UPTI|cut -d ')' -f2)
PORT_TCPO=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_PORT_TCPO|grep listen|cut -d '.' -f6|sort -u -n)
PORT_UDPO=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_PORT_UDPO|cut -d ':' -f4|cut -d ' ' -f2|sort -n)
DISK_DESC=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_DISK_DESC|grep "/"|cut -d ':' -f4|cut -d ' ' -f2|sort -d)
INTF_NAME=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_INTF_NAME|cut -d ':' -f4|cut -d ' ' -f2)

echo "------------------------------------------"
echo "SYSTEM INFO:"
echo "------------------------------------------"
echo "HOSTNAME: $SYST_HOST"
echo "OPERATING SYSTEM: $SYST_DESC"
echo "FLAVOR: $SYST_FLAV"
echo "KERNEL: $SYST_KERN"
echo "UPTIME:$SYST_UPTI"
echo "LOCATION: $SYST_LOCA"
echo "CONTACT: $SYST_CONT"
echo " "
echo "------------------------------------------"
echo "NETWORK INTERFACES:"
echo "------------------------------------------"
echo "$INTF_NAME"
echo "------------------------------------------"
echo "OPEN TCP PORTS:"
echo "------------------------------------------"
echo "$PORT_TCPO"
echo "------------------------------------------"
echo "OPEN UDP PORTS:"
echo "------------------------------------------"
echo "$PORT_UDPO"
echo "------------------------------------------"
echo "MOUNT POINTS:"
echo "------------------------------------------"
echo "$DISK_DESC"

elif [ "$PLATFORM" == "$WIN" ]
then

# OID's
OID_DISK_DESC="hrStorageDescr"
OID_SYST_HOST="sysName.0"
OID_SYST_DESC="sysDescr.0"
OID_PORT_TCPO="tcpConnState."
OID_PORT_UDPO="udpLocalPort."
OID_PROC_RUNN="hrSWRunName.*"
OID_INTF_NAME="ifName"

# windows processing
SYST_HOST=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_HOST|cut -d ':' -f4|cut -d ' ' -f2)
SYST_DESC=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_DESC|cut -d ':' -f4|cut -d ' ' -f2)
PORT_TCPO=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_PORT_TCPO|grep listen|cut -d '.' -f6|sort -u -n)
PORT_UDPO=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_PORT_UDPO|cut -d ':' -f4|cut -d ' ' -f2|sort -n)
PROC_RUNN=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOMENAME $OID_PROC_RUNN)
DISK_DESC=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_DISK_DESC|grep "/"|cut -d ':' -f4|cut -d ' ' -f2|sort -d)
INTF_NAME=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_INTF_NAME|cut -d ':' -f4|cut -d ' ' -f2)

echo "------------------------------------------"
echo "SYSTEM INFO:"
echo "------------------------------------------"
echo "HOSTNAME:$SYST_HOST"
echo "OPERATING SYSTEM:$SYST_DESC"
echo " "
echo "------------------------------------------"
echo "NETWORK INTERFACES:"
echo "------------------------------------------"
echo "$INTF_NAME"
echo "------------------------------------------"
echo "OPEN TCP PORTS:"
echo "------------------------------------------"
echo "$PORT_TCPO"
echo "------------------------------------------"
echo "OPEN UDP PORTS:"
echo "------------------------------------------"
echo "$PORT_UDPO"
echo "------------------------------------------"
echo "PROCESSES:"
echo "------------------------------------------"
echo "$PROC_RUNN"
echo "------------------------------------------"
echo "MOUNT POINTS:"
echo "------------------------------------------"
echo "$DISK_DESC"

elif [ "$PLATFORM" == "$CIS" ]
then
# OID's
OID_DISK_DESC="hrStorageDescr"
OID_SYST_HOST="sysName.0"
OID_SYST_DESC="sysDescr.0"
OID_PORT_TCPO="tcpConnState."
OID_PORT_UDPO="udpLocalPort."
OID_PROC_RUNN="hrSWRunName.*"
OID_INTF_NAME="ifName"


# cisco processing
SYST_HOST=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_HOST|cut -d ':' -f4|cut -d ' ' -f2)
SYST_DESC=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_SYST_DESC|cut -d ':' -f4|cut -d ' ' -f2)
PORT_TCPO=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_PORT_TCPO|grep listen|cut -d '.' -f6|sort -u -n)
PORT_UDPO=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_PORT_UDPO|cut -d ':' -f4|cut -d ' ' -f2|sort -n)
PROC_RUNN=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOMENAME $OID_PROC_RUNN)
DISK_DESC=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_DISK_DESC|grep "/"|cut -d ':' -f4|cut -d ' ' -f2|sort -d)
INTF_NAME=$($CMD_SNMPWALK -v 2c -c $COMMUNITY $HOSTNAME $OID_INTF_NAME|cut -d ':' -f4|cut -d ' ' -f2)

echo "------------------------------------------"
echo "SYSTEM INFO:"
echo "------------------------------------------"
echo "HOSTNAME:$SYST_HOST"
echo "OPERATING SYSTEM:$SYST_DESC"
echo " "
echo "------------------------------------------"
echo "NETWORK INTERFACES:"
echo "------------------------------------------"
echo "$INTF_NAME"
echo "------------------------------------------"
echo "OPEN TCP PORTS:"
echo "------------------------------------------"
echo "$PORT_TCPO"
echo "------------------------------------------"
echo "OPEN UDP PORTS:"
echo "------------------------------------------"
echo "$PORT_UDPO"
echo "------------------------------------------"
echo "PROCESSES:"
echo "------------------------------------------"
echo "$PROC_RUNN"
echo "------------------------------------------"
echo "MOUNT POINTS:"
echo "------------------------------------------"
echo "$DISK_DESC"
fi
