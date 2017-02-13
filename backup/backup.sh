#!/bin/bash -e

# bash strict mode
set -eou pipefail

# source the variables
. ./variables.sh

# the database dump directory - default to the current directory if not defined
PWD="$(pwd)"
DAILY_DIR_NAME="$(date '+%d-%m-%Y')"
DUMP_BASE_DIR="${DUMP_DIR:-$PWD}"
DUMP_DIR="$DUMP_BASE_DIR/$DAILY_DIR_NAME"

# the type of backup to perform
BACKUP_TYPE="${BACKUP_TYPE:-data}" # this can be 'schema', 'data', or 'both'

# tells it to use GZIP or not
USE_GZIP="${USE_GZIP:-true}"

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
    DUMP_CMD=( mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DATABASE --complete-insert --hex-blob --no-create-info --no-create-db --skip-triggers --ignore-table=$MYSQL_DATABASE.document_map --ignore-table=$MYSQL_DATABASE.entity_map --skip-add-locks --single-transaction )
    ;;

  schema)
    DUMP_CMD=( mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DATABASE --routines --no-data --skip-add-locks )
    ;;

  *)
    DUMP_CMD=( mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DATABASE --routines --complete-insert --hex-blob --skip-add-locks --single-transaction --ignore-table=$MYSQL_DATABASE.document_map --ignore-table=$MYSQL_DATABASE.entity_map  )
    ;;
esac

##
# Actually execute the database dump
##
OUTFILE="${OUTFILE:-$DUMP_DIR/$MYSQL_DATABASE.$DATE.$FREQUENCY.sql}"
"${DUMP_CMD[@]}" > "$OUTFILE"

##
# Compress the output with gzip
##
if [ "$USE_GZIP" = true ]; then
  gzip "$OUTFILE"
fi

# clean out dump directories older than 14 days old (two weeks).
find $DUMP_BASE_DIR/* -type d -ctime +14 -exec rm -rf {} +

echo "Backed up $MYSQL_DATABASE to $OUTFILE"
