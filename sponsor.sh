#!/bin/bash

# Require $ORAUSER, $ORAPW, $ORASERVER; Optionally set $EZPFILESDIR
source `dirname $0`/common.env

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# If LD_LIBRARY_PATH doesn't already have ORACLE_HOME, add it
echo :$LD_LIBRARY_PATH: | grep -qF :$ORACLE_HOME/lib:
if [[ $? != 0 ]]
then
	export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
fi

# Default directory is this program's working directory
if [[ "$EZPFILESDIR" == "" ]]
then
	EZPFILESDIR=$SCRIPTDIR
fi

# fetch sponsored accounts from LDAP
ldapsearch -LLL -D "$LDAPUSER" -w "$LDAPPASS" -p 389 -h "$LDAPHOST" -b "$LDAPBASE" -s sub -E pr=10000/noprompt '(&(PittSponsorRC=*)(!(PittSponsorRC=AL)))' cn PittSponsorRC > $EZPFILESDIR/working/sponsored.$$.ldap

if [[ $? != 0 ]]
then
	rm $EZPFILESDIR/working/sponsored.$$.ldap
	exit 1
fi

grep -v '^dn: ' $EZPFILESDIR/working/sponsored.$$.ldap | grep -v '^#' | grep -v '^ ' | sed "s/cn: \(.*\)/INSERT INTO EZPAARSE_SPACCT_RCS VALUES ('\\1',/" | sed "s/PittSponsorRC: \(.*\)/'\\1');/" > $EZPFILESDIR/working/sponsored.$$.sql
cat $SCRIPTDIR/SPACCT_RCS.head.sql $EZPFILESDIR/working/sponsored.$$.sql $SCRIPTDIR/SPACCT_RCS.tail.sql > $EZPFILESDIR/working/sponsored.$$.run.sql

$ORACLE_HOME/bin/sqlplus -S $ORAUSER/$ORAPW@$ORASERVER @$EZPFILESDIR/working/sponsored.$$.run.sql > $EZPFILESDIR/working/sponsored.$$.run.sqllog
# Check for sane response from sqlplus
grep -qF 'PL/SQL procedure successfully completed.' $EZPFILESDIR/working/sponsored.$$.run.sqllog
if [[ $? != 0 ]]
then
	>&2 echo 'Failed to load new sponsored accounts.'
	cat $EZPFILESDIR/working/sponsored.$$.run.sqllog
fi
rm $EZPFILESDIR/working/sponsored.$$.ldap $EZPFILESDIR/working/sponsored.$$.run.sqllog $EZPFILESDIR/working/sponsored.$$.run.sql $EZPFILESDIR/working/sponsored.$$.sql
