#!/bin/bash -e

# bash strict mode
set -eou pipefail

# the MySQL database credentials to be passed to mysql dump
MYSQL_USER=""
MYSQL_DATABASE=""
MYSQL_PASSWORD=""
MYSQL_HOST="localhost"

# the database dump file
DUMP_DIR=""

# the frequency of backup is expected to be passed in to the script
# if the frequency is not set, it will append $DEFAULT_FREQUENCY to
# the filename to indicate that it was not triggered as such.
DEFAULT_FREQUENCY="default"
FREQUENCY="${FREQUENCY:-$DEFAULT_FREQUENCY}"

case "$FREQUENCY" in
  minute | hourly)
    DATE="$(date '+%d-%m-%Y %R:%S')"
    ;;

  daily | weekly | biweekly | monthly)
    DATE="$(date '+%d-%m-%Y')"
    ;;

  *)
    DATE="$(date '+%d-%m-%Y %R:%S')"
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

##
# Actually execute the database dump
##
OUTFILE="$DUMP_DIR/$MYSQL_DATABASE.$DATE.$FREQUENCY.sql"
mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DATABASE > "$OUTFILE"

##
# Compress the output with gzip
##
gzip "$OUTFILE"

echo "Backed up $MYSQL_DATABASE to $OUTFILE"
