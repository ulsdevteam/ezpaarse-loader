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

$ORACLE_HOME/bin/sqlplus -S $ORAUSER/$ORAPW@$ORASERVER @$SCRIPTDIR/postprocess.sql > $EZPFILESDIR/working/postprocess.$$.sqllog
# Check for sane response from sqlplus
grep -qF 'PL/SQL procedure successfully completed.' $EZPFILESDIR/working/postprocess.$$.sqllog
if [[ $? != 0 ]]
then
	>&2 echo 'Failed to load new sponsored accounts.'
	>&2 cat $EZPFILESDIR/working/postprocess.$$.sqllog
fi
rm $EZPFILESDIR/working/postprocess.$$.sqllog
