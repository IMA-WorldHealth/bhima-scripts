#!/bin/bash -e

# bash strict mode
set -eou pipefail

# the MySQL database credentials to be passed to mysql dump
MYSQL_USER=""
MYSQL_DATABASE=""
MYSQL_PASSWORD=""
MYSQL_HOST=""

# the database dump directory - default to the current directory if not defined
PWD="$(pwd)"
DAILY_DIR_NAME="$(date '+%d-%m-%Y')"
DUMP_DIR="${DUMP_DIR:-$PWD}/$DAILY_DIR_NAME"

# the type of backup to perform
BACKUP_TYPE="data" # this can be 'schema', 'data', or 'both'

# tells it to use GZIP or not
USE_GZIP=true

# the frequency of backup is expected to be passed in to the script
# if the frequency is not set, it will append $DEFAULT_FREQUENCY to
# the filename to indicate that it was not triggered as such.
DEFAULT_FREQUENCY="default"
FREQUENCY="${FREQUENCY:-$DEFAULT_FREQUENCY}"

case "$FREQUENCY" in
  minute | hourly)
    DATE="$(date '+%d-%m-%Y-%R:%S')"
    ;;

  daily | weekly | biweekly | monthly)
    DATE="$(date '+%d-%m-%Y')"
    ;;

  *)
    DATE="$(date '+%d-%m-%Y%-R:%S')"
    ;;
esac

##
# BEGIN SCRIPT
#
# The script will:
#   1) Create the dump directory if it doesn't exist
#   2) Format the output file
#   3) Dump the database
#   4) Zip the database using gzip compression.
##

##
# Create the directory if necessary for the dump file
##
if [ ! -d "$DUMP_DIR" ]; then
  mkdir -p "$DUMP_DIR"
fi

case "$BACKUP_TYPE" in
  data)
    DUMP_CMD=( mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DATABASE --complete-insert --hex-blob --no-create-info --no-create-db --skip-triggers --ignore-table=$MYSQL_DATABASE.stage_billing_service,$MYSQL_DATABASE.stage_subsidy )
    ;;

  schema)
    DUMP_CMD=( mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DATABASE --routines --no-data )
    ;;

  *)
    DUMP_CMD=( mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DATABASE --routines --complete-insert --hex-blob )
    ;;
esac

##
# Actually execute the database dump
##
OUTFILE="$DUMP_DIR/$MYSQL_DATABASE.$DATE.$FREQUENCY.sql"
"${DUMP_CMD[@]}" > "$OUTFILE"

##
# Compress the output with gzip
##
if [ "$USE_GZIP" = true ]; then
  gzip "$OUTFILE"
fi

echo "Backed up $MYSQL_DATABASE to $OUTFILE"
