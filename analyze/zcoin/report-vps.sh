#!/bin/bash

# (c) 2018 ConsulTent, Ltd

DATE=`date '+%y%m%d'`

LSB=`which lsb_release`
ID=`whoami`
PWD=`pwd`
DF=`df -l --output=source,pcent |egrep -v 'none|tmpfs|Filesystem|udev' | sed -r 's,^[/a-Z0-9?]*\s*([0-9]*)%,\1,g'`

ISSUES=0

#Custom vars
CNAME="zcoin"
if [ "$ID" == "root" ]; then
CHOME="/root/.${CNAME}/"
else
CHOME="/home/${ID}/.${CNAME}/"
fi
BINC=`find ~/ -name "${CNAME}d" -executable -print`
#
BINCLI="${BINC%?}-cli"
CPORT='8168'
#

if [ ! -d "${CHOME}" ]; then
	echo "Coin home directory $CHOME not found.  Please install and run $CNAME"
exit
fi

echo "${BINC} report on $DATE" 
if [ -n "$LSB" ]; then
LSBREL=`${LSB} -crsi`
  echo "System: ${LSBREL}" 
else
echo "$LSB"
  echo "System: unknown" 
fi

echo "User: ${ID}" 
echo "Coin: ${BINC}" 

DEBUGLOG="${CHOME}/debug.log"
if [ ! -f "${DEBUGLOG}" ]; then
	echo "${DEBUGLOG} does not exist.  Have you run ${BINC}?"
else
DEBUGLOGS=`ls -alh ${DEBUGLOG}|cut -d' ' -f5|grep 'G'`
fi

if [ "$DF" -gt "90" ]; then
  echo "Warning: Your filesystem is almost full."
	let "ISSUES++"
  if [ -n "$DEBUGLOGS" ]; then
	echo "Your debug log \[$DEBUGLOG\] is ${DEBUGLOGS}. This is BIG."
	let "ISSUES++"
  fi
fi

LISTEN=`lsof -ni TCP:${CPORT} |grep 'LISTEN'|wc -l` 

if [ -z "$LISTEN" ]; then
	if [ "$LISTEN" -lt "2" ]; then
		echo "Make sure that ${BINC} is up and running and listening on port ${CPORT}."
		let "ISSUES++"
	fi
fi

if [ "$ISSUES" -eq "0" ]; then
	echo -n "Testing for block increment."
BLOCKA=`${BINCLI} getinfo |grep blocks|cut -d: -f2|cut -d' ' -f2|cut -d, -f1`
	echo -n ".";sleep 1;echo -n ".";sleep 1;echo -n ".";sleep 1;echo -n ".";sleep 1
	echo -n ".";sleep 1;echo -n ".";sleep 1;echo -n ".";sleep 1;echo -n ".";sleep 1
	echo -n ".";sleep 1;echo -n ".";sleep 1;echo -n "."
BLOCKB=`${BINCLI} getinfo |grep blocks|cut -d: -f2|cut -d' ' -f2|cut -d, -f1`
	echo "."

	if [ "$BLOCKA" -eq "$BLOCKB" ]; then
		PEERS=`${BINCLI} getinfo |grep connections|cut -d: -f2|cut -d' ' -f2|cut -d, -f1`
		if [ "$PEERS" -eq "0" ]; then
			echo "Warning: You need to 'addnode' some more peers.  You have no connections."
			let "ISSUES++"
		fi
		echo "Alert: No blocks incremented in 10 seconds.  If your coin is already synced, this is not an issue!"
	fi
fi

if [ "$ISSUES" -eq "0" ]; then
	echo "No issues were found."
else
	echo "$ISSUES issues were found"
fi

