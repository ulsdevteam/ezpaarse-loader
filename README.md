# EZPAARSE Data Loader

## Purpose
Download EZProxy logs, parse with EZPAARSE, and load processed logs into an Oracle table.

## Configuration
 * Copy common.env.sample to common.env with your Oracle username, password, and server, and any other customizations

## Usage
 * `./parse.sh`
   * will look in `downloads/` for new logs, capturing EZPAARSE output to `parsed/`
   * failures will be output to STDERR, and failed logs and temporary files will be left in `parsed/`
 * `./process.sh`
   * will look in `pending/` for new logs, moving them to `done/` when completed
   * failures will be output to STDERR, and failed logs and temporary files will be left in `working/`

## Copyright/License
 * Copyright University of Pittsburgh
 * Licensed under GPL v2, or (at your option) any later version.
 * Maintained by ULS Systems Development
