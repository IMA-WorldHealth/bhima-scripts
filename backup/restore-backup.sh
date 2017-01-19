#!/bin/bash -e

# bash strict mode
set -eou pipefail

# the MySQL database credentials to be passed to mysql dump
MYSQL_USER=""
MYSQL_DATABASE=""
MYSQL_PASSWORD=""
MYSQL_HOST="localhost"

INSTALL_DIR="/opt/bhima"
DUMP_FILE="dump.sql"

# build the test database
echo "Rebuilding database from a dump file"

mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS $MYSQL_DATABASE ;"
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

echo "Building schema"
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $INSTALL_DIR/server/models/schema.sql

echo "Building triggers...."
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $INSTALL_DIR/server/models/triggers.sql

echo "Building functions and procedures"
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $INSTALL_DIR/server/models/functions.sql
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $INSTALL_DIR/server/models/procedures.sql

echo "Building dump...."
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < dump.sql
