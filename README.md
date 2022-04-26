# EZPAARSE Data Loader

## Purpose
Download EZProxy logs, parse with EZPAARSE, and load processed consulation events into an Oracle table.  The users from these consulation events will be matched against Responsiblity Centers (RCs).

## Configuration
 * Copy common.env.sample to common.env with your Oracle username, password, and server, and any other customizations
 * By default, parse.sh will compress all succesful log files using gzip. This can be skipped by editing SKIPCOMPRESSION within common.env to 1

## Usage
 * `./download.sh [n]`
   * will look in `downloads/` and fill the directory with any missing logs from the last *n* days (default: 14)
 * `./parse.sh`
   * will look in `downloads/` for new logs, capturing EZPAARSE output to `parsed/`
   * failures will be output to STDERR, and failed logs and temporary files will be left in `parsed/`
   * successful output will be copied to `pending`
 * `./process.sh`
   * will look in `pending/` for new logs, moving them to `done/` when completed
   * failures will be output to STDERR, and failed logs and temporary files will be left in `working/`
   * files with the same name will overwrite existing data within the database
 * `./sponsor.sh`
   * will look at custom LDAP attributes to populate a custom table of RC codes for certain accounts
   * failures will be output to STDERR
   * for usage outside of Pitt, you'll need to modify the LDAP filter and attributes selected
 * `./postprocess.sh`
   * will populate a datatable with RC codes based on custom SQL
   * failures will be output to STDERR
   * for usage outside of Pitt, you'll need to modify the postprocess.sql file

## Rerunning
To re-run a log from start to finish, clear the log file from the `downloads/` and `parsed/` directories.  This will force re-download and re-parsing, and subsequent steps will overwrite existing data within the database based on the newly downloaded and parsed files.

## Copyright/License
 * Copyright University of Pittsburgh
 * Licensed under GPL v2, or (at your option) any later version.
 * Maintained by ULS Systems Development
