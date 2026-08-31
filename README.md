# EZPAARSE Data Loader

## Note
We have migrated our database provider from Oracle to Snowflake, and as 
such the logic for uploading processed events into Oracle 
database will be left unmaintained. Due to this, the following
files will be removed from the repository (they can be found 
in the commit history if needed)

```
Files Removed:
- ./process.sh
- ./postprocess.sh
- ./sponsor.sh
```

The corresponding logic for uploading processed event files to snowflake 
lives in the following [repo](https://github.com/ulsdevteam/snowflake_ezpaarse_upload).

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
 * [`snowflake_ezpaarse_upload`](https://github.com/ulsdevteam/snowflake_ezpaarse_upload).
   * will look in `pending/` and will upload the output to snowflake
   * failed uploads and temporary files will be left in `working/`
   * successful output will be copied to `done`

## Rerunning
To re-run a log from start to finish, clear the log file from the `downloads/` and `parsed/` directories.  This will force re-download and re-parsing, and subsequent steps will overwrite existing data within the database based on the newly downloaded and parsed files.

## Copyright/License
 * Copyright University of Pittsburgh
 * Licensed under GPL v2, or (at your option) any later version.
 * Maintained by ULS Systems Development
