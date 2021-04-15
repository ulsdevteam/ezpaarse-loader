#!/bin/bash

# Require $PROXYUSER, $PROXYPASS, $MYSITE; Optionally set $EZPFILESDIR
source `dirname $0`/common.env

DAYSPRIOR=30
if [[ "$1" =~ ^[0-9]+$ ]]
then
	DAYSPRIOR=$1
fi

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Default directory is this program's working directory
if [[ "$EZPFILESDIR" == "" ]]
then
	EZPFILESDIR=$SCRIPTDIR
fi

CURDATE=`date +%Y-%m-%d`
SESSIONFILE=/tmp/ezp.sess.$$
OUTPUTFILE=/tmp/ezp.out.$$
wget -q --post-data "user=${PROXYUSER}&pass=${PROXYPASS}" -O $OUTPUTFILE --no-check-certificate --keep-session-cookies --save-cookies $SESSIONFILE "https://${MYSITE}.idm.oclc.org/login"

if [[ $? != 0 ]]
then
	>&2 echo 'Failed to authenticate to EZProxy'
	>&2 cat $OUTPUTFILE
	exit 1
fi

for ((i=1; i<=$DAYSPRIOR; i++))
do
	TARGETDATE=`date "+%Y%m%d" -d "$CURDATE -$i days"`
	if [[ ! -e $EZPFILESDIR/downloads/ezp${TARGETDATE}.log ]]
	then
		wget -q --load-cookies $SESSIONFILE -O ${EZPFILESDIR}/downloads/ezp${TARGETDATE}.log  "https://login.${MYSITE}.idm.oclc.org/loggedin/admlog/ezp${TARGETDATE}.log"
		if [[ $? != 0 ]]
		then
			rm ${EZPFILESDIR}/downloads/ezp${TARGETDATE}.log
			>&2 echo 'Failed to download ezp'$TARGETDATE', wget exited with '$?
		fi
	fi
done

rm $OUTPUTFILE
rm $SESSIONFILE
