#!/bin/bash

source sqlplus.env

echo $LD_LIBRARY_PATH | grep -qF $ORACLE_HOME/lib
if [[ $? != 0 ]]
then
	LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
fi

for f in pending/*
do
	fname=`echo $f | cut -d'/' -f2`
	if [ -e done/$fname ]
	then
		>&2 echo $fname' already exists in "done"'
		continue
	fi
	if [ -e working/$fname ]
	then
		>&2 echo $fname' already exists in "working"'
		continue
	fi
	mv $f working/$fname
	sed 1d < working/$fname | sed "s/^/$fname;;;/" >> working/$fname.data
	echo -e "DELETE FROM EZPAARSE_RESULTS WHERE \"loadid\" = '$fname';\n/\nEXIT" > working/$fname.sql
	$ORACLE_HOME/bin/sqlplus -S $ORAUSER/$ORAPW@$ORASERVER @working/$fname.sql > working/$fname.sqllog
	grep -q 'rows deleted.' working/$fname.sqllog
	if [[ $? != 0 ]]
	then
		>&2 echo 'Failed to clear any existing loads for '$fname
		continue
	fi
	$ORACLE_HOME/bin/sqlldr $ORAUSER/$ORAPW@$ORASERVER data=working/$fname.data control=sqlldr.ctl log=working/$fname.load.rpt bad=working/$fname.load.bad > working/$fname.sqllog
	if [[ $? != 0 ]]
	then
		>&2 echo 'Failed to load '$fname
		>&2 cat working/$fname.sqllog
	else
		mv working/$fname done/
		rm working/$fname.*
	fi
done
