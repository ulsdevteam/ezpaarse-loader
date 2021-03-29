#!/bin/sh
if [[ "$EZPFILESDIR" == "" ]]
then
	EZPFILESDIR=$SCRIPTDIR
fi

if ! compgen -G "$EZPFILESDIR/downloads/*" > /dev/null
then
	echo 'No files match in '$EZPFILESDIR/downloads
	exit;
fi

if [[ "$EZPURL" == "" ]]
then
	EZPURL=locahost:59599
fi

PROCESSED_DIR=$EZPFILESDIR/parsed

for f in $EZPFILESDIR/downloads/*
do
	RAW_LOG_FILE=`basename $f`

	if [ -d $PROCESSED_DIR/$RAW_LOG_FILE ]
	then
		rm -fR $PROCESSED_DIR/$RAW_LOG_FILE
	fi
	mkdir $PROCESSED_DIR/$RAW_LOG_FILE

	curl -s -X POST --no-buffer -H 'Reject-Files: all' -H 'Crypted-Fields: none' -H 'Log-Format-ezproxy: %h %u %{ezproxy-session}i %t "%r" %s %b' -H 'Date-Format: DD/MMM/YYYY:HH:mm:ss Z' -H 'Connection: keep-alive' --data-binary @$f http://$EZPURL -o $PROCESSED_DIR/$RAW_LOG_FILE/results.txt -D $PROCESSED_DIR/$RAW_LOG_FILE/headers.txt

	for l in job-report lines-unknown-formats lines-ignored-domains lines-unknown-domains lines-unqualified-ecs lines-duplicate-ecs lines-unordered-ecs lines-filtered-ecs lines-ignored-hosts lines-robots-ecs lines-unknown-errors
	do
		PROCESSED_REPORT=`grep -i '^'$f': ' $PROCESSED_DIR/$RAW_LOG_FILE/headers.txt | cut -d':' -f2- | tr -d '\r'`
		if [ "$PROCESSED_REPORT" != "" ]
		then
			wget -q $PROCESSED_REPORT -P $PROCESSED_DIR/$RAW_LOG_FILE/
		fi
	done

	grep -q -e '^Job aborted$' -e '^{"statusCode":5' $PROCESSED_DIR/$RAW_LOG_FILE/results.txt
	if [ "$?" == "0" ]
	then
		mv $PROCESSED_DIR/$RAW_LOG_FILE/results.txt $PROCESSED_DIR/$RAW_LOG_FILE/results.failed
		>&2 echo 'Processing failed'
	else
		mv $PROCESSED_DIR/$RAW_LOG_FILE/results.txt $PROCESSED_DIR/pickup/$RAWLOGFILE
	fi
done
