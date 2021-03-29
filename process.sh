#!/bin/bash

source common.env

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo :$LD_LIBRARY_PATH: | grep -qF :$ORACLE_HOME/lib:
if [[ $? != 0 ]]
then
	export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
fi

if [[ "$EZPFILESDIR" == "" ]]
then
	EZPFILESDIR=$SCRIPTDIR
fi

if ! compgen -G "$EZPFILESDIR/pending/*" > /dev/null
then
	echo 'No files match in '$EZPFILESDIR/pending
	exit;
fi

for f in $EZPFILESDIR/pending/*
do
	fname=`basename $f`
	if [ -e $EZPFILESDIR/done/$fname ]
	then
		>&2 echo $fname' already exists in "done"'
		continue
	fi
	if [ -e $EZPFILESDIR/working/$fname ]
	then
		>&2 echo $fname' already exists in "working"'
		continue
	fi
	mv $f $EZPFILESDIR/working/$fname
	sed 1d < $EZPFILESDIR/working/$fname | sed "s/^/$fname;;;/" >> $EZPFILESDIR/working/$fname.data
	echo -e "DELETE FROM EZPAARSE_RESULTS WHERE \"loadid\" = '$fname';\n/\nEXIT" > $EZPFILESDIR/working/$fname.sql
	$ORACLE_HOME/bin/sqlplus -S $ORAUSER/$ORAPW@$ORASERVER @$EZPFILESDIR/working/$fname.sql > $EZPFILESDIR/working/$fname.sqllog
	grep -q 'rows deleted.' $EZPFILESDIR/working/$fname.sqllog
	if [[ $? != 0 ]]
	then
		>&2 echo 'Failed to clear any existing loads for '$fname
		continue
	fi
	$ORACLE_HOME/bin/sqlldr $ORAUSER/$ORAPW@$ORASERVER data=$EZPFILESDIR/working/$fname.data control=$SCRIPTDIR/sqlldr.ctl log=$EZPFILESDIR/working/$fname.load.rpt bad=$EZPFILESDIR/working/$fname.load.bad > $EZPFILESDIR/working/$fname.sqllog
	if [[ $? != 0 ]]
	then
		>&2 echo 'Failed to load '$fname
		>&2 cat $EZPFILESDIR/working/$fname.sqllog
	else
		mv $EZPFILESDIR/working/$fname $EZPFILESDIR/done/
		rm $EZPFILESDIR/working/$fname.*
	fi
done
