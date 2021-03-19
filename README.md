# EZPAARSE Data Loader

## Purpose
Load EZPAARSE processed logs into an Oracle table.

## Configuration
 * Copy sqlplus.env.sample to sqlplus.env with your Oracle username, password, and server

## Usage
 * `./process.sh`
   * will look in `pending/` for new logs, moving them to `done/` when completed
   * failures will be output to STDERR, and failed logs and temporary files will be left in `working/`

## Copyright/License
 * Copyright University of Pittsburgh
 * Licensed under GPL v2, or (at your option) any later version.
 * Maintained by ULS Systems Development
