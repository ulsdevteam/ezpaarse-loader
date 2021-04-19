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

# Check if there are pending files
if ! compgen -G "$EZPFILESDIR/pending/*" > /dev/null
then
	echo 'No files match in '$EZPFILESDIR/pending
	exit;
fi

# Process each pending file
for f in $EZPFILESDIR/pending/*
do
	# Get just the filename
	fname=`basename $f`

	# Check if this file has already been processed successfully
	if [ -e $EZPFILESDIR/done/$fname ]
	then
		>&2 echo $fname' already exists in "done"'
		continue
	fi
	# Check if this file has already been processed unsuccessfully
	if [ -e $EZPFILESDIR/working/$fname ]
	then
		>&2 echo $fname' already exists in "working"'
		continue
	fi
	# Move the file into the working directory
	mv $f $EZPFILESDIR/working/$fname
	# Munge the file to remove the header and to add the filename and blanks for the RC, DEPT.
	sed 1d < $EZPFILESDIR/working/$fname | sed "s/^/$fname;/" >> $EZPFILESDIR/working/$fname.data
	# Clear any existing records for this file (allows for re-runs with updated data)
	echo -e "DELETE FROM EZPAARSE_RESULT_DEPTS WHERE \"recordid\" IN (SELECT \"recordid\" FROM EZPAARSE_RESULTS WHERE \"loadid\" = '$fname');\n/\nEXIT" > $EZPFILESDIR/working/$fname.deldept.sql
	$ORACLE_HOME/bin/sqlplus -S $ORAUSER/$ORAPW@$ORASERVER @$EZPFILESDIR/working/$fname.deldept.sql > $EZPFILESDIR/working/$fname.deldept.sqllog
	# Check for sane response from sqlplus
	grep -q 'rows deleted.' $EZPFILESDIR/working/$fname.deldept.sqllog
	if [[ $? != 0 ]]
	then
		>&2 echo 'Failed to clear any existing loads (depts) for '$fname
		>&2 cat $EZPFILESDIR/working/$fname.deldept.sqllog
		continue
	fi
	echo -e "DELETE FROM EZPAARSE_RESULTS WHERE \"loadid\" = '$fname';\n/\nEXIT" > $EZPFILESDIR/working/$fname.delrec.sql
	$ORACLE_HOME/bin/sqlplus -S $ORAUSER/$ORAPW@$ORASERVER @$EZPFILESDIR/working/$fname.delrec.sql > $EZPFILESDIR/working/$fname.delrec.sqllog
	# Check for sane response from sqlplus
	grep -q 'rows deleted.' $EZPFILESDIR/working/$fname.delrec.sqllog
	if [[ $? != 0 ]]
	then
		>&2 echo 'Failed to clear any existing loads (results) for '$fname
		>&2 cat $EZPFILESDIR/working/$fname.delrec.sqllog
		continue
	fi
	# Load the data with sqlldr
	$ORACLE_HOME/bin/sqlldr $ORAUSER/$ORAPW@$ORASERVER data=$EZPFILESDIR/working/$fname.data control=$SCRIPTDIR/sqlldr.ctl log=$EZPFILESDIR/working/$fname.load.rpt bad=$EZPFILESDIR/working/$fname.load.bad > $EZPFILESDIR/working/$fname.sqllog
	# Check sqlldr for a 0 exit code: all data loaded
	if [[ $? != 0 ]]
	then
		>&2 echo 'Failed to load '$fname
		>&2 cat $EZPFILESDIR/working/$fname.sqllog.load.rpt
	else
		mv $EZPFILESDIR/working/$fname $EZPFILESDIR/done/
		rm $EZPFILESDIR/working/$fname.*
	fi
done
