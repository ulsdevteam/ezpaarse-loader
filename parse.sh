#!/bin/bash

# Allow override of $EZPFILESDIR and $EZPURL
source `dirname $0`/common.env

SKIPCOMPRESSION="${SKIPCOMPRESSION:-0}"

function compress_file() {
	if [[ $SKIPCOMPRESSION == 0 ]]
	then
		gzip $1;
		if [[ $? != 0 ]]
		then
			>&2 echo 'Failed to compress '$2', gzip exited with '$?
		fi
	fi
}

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# By default, $EZPFILESDIR is this program directory
if [[ "$EZPFILESDIR" == "" ]]
then
	EZPFILESDIR=$SCRIPTDIR
fi

# Check to see if any downloads are queued
if ! compgen -G "$EZPFILESDIR/downloads/*" > /dev/null
then
	echo 'No files match in '$EZPFILESDIR/downloads
	exit;
fi

# By default, EZPAARSE is at http://localhost:59599/
if [[ "$EZPURL" == "" ]]
then
	EZPURL=localhost:59599
fi

# EZPAARSE output will be stored here
PROCESSED_DIR=$EZPFILESDIR/parsed

# Check each downloaded log file
for f in $EZPFILESDIR/downloads/*
do
	# Extract the log file name
	RAW_LOG_FILE=`basename $f`

	# If file is already compressed, skip it
	if [[ $RAW_LOG_FILE == *.gz ]]
	then
		continue;
	fi

	# If results already exist for this log file, compress the file and skip it
	if [ -e $PROCESSED_DIR/$RAW_LOG_FILE/results.txt ]
	then
		# Only compress if they don't skip it
		compress_file "$f" "$RAW_LOG_FILE"
		continue;
	fi

	# Otherwise, the presence of a working directoy indicates a prior failed run
	if [ -d $PROCESSED_DIR/$RAW_LOG_FILE ]
	then
		rm -fR $PROCESSED_DIR/$RAW_LOG_FILE
	fi
	# Create a working directory
	mkdir $PROCESSED_DIR/$RAW_LOG_FILE

	# Send the logfile to EZPAARSE
	curl -s -X POST --no-buffer -H 'Reject-Files: all' -H 'Crypted-Fields: none' -H 'Log-Format-ezproxy: %h %u %{ezproxy-session}i %t "%r" %s %b' -H 'Date-Format: DD/MMM/YYYY:HH:mm:ss Z' -H 'Connection: keep-alive' --data-binary @$f http://$EZPURL -o $PROCESSED_DIR/$RAW_LOG_FILE/results.txt -D $PROCESSED_DIR/$RAW_LOG_FILE/headers.txt

	# Did something go entirely wrong?
	if [ ! -e $PROCESSED_DIR/$RAW_LOG_FILE/results.txt ]
	then
		>&2 echo 'Failed to process '$RAW_LOG_FILE
		continue
	fi

	# Download job information files
	for l in job-report lines-unknown-formats lines-ignored-domains lines-unknown-domains lines-unqualified-ecs lines-duplicate-ecs lines-unordered-ecs lines-filtered-ecs lines-ignored-hosts lines-robots-ecs lines-unknown-errors
	do
		PROCESSED_REPORT=`grep -i '^'$l': ' $PROCESSED_DIR/$RAW_LOG_FILE/headers.txt | cut -d':' -f2- | tr -d '\r'`
		if [ "$PROCESSED_REPORT" != "" ]
		then
			wget -q $PROCESSED_REPORT -P $PROCESSED_DIR/$RAW_LOG_FILE/
		fi
	done

	# Check if the job was aborted or any 5xx error occurred
	grep -q -e '^Job aborted$' -e '^{"statusCode":5' $PROCESSED_DIR/$RAW_LOG_FILE/results.txt
	if [ "$?" == "0" ]
	then
		# Flag this result as failed
		mv $PROCESSED_DIR/$RAW_LOG_FILE/results.txt $PROCESSED_DIR/$RAW_LOG_FILE/results.failed
		>&2 echo 'Processing failed for '$RAW_LOG_FILE
	else
		# Copy the sucessful results for pickup
		cp $PROCESSED_DIR/$RAW_LOG_FILE/results.txt $EZPFILESDIR/pending/$RAW_LOG_FILE
		# Compress log file within downloads directory
		# Only compress if they don't skip it
		compress_file "$f" "$RAW_LOG_FILE"
	fi
done
