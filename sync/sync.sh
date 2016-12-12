#!/bin/bash -e

##
## This utility script backups up a directory using mirroring and compression.

# bash strict mode
set -eou pipefail

# the directory to synchronize
BACKUP_DIR=""

# the target directory
REMOTE_DIR=""

## Step 1)
##  Make the $REMOTE_DIR if it does not exist
if [ ! -d "$REMOTE_DIR" ]; then
  mkdir -p $REMOTE_DIR
fi

## Step 2)
##  recursively transfer the files in the folder with rsync.  The -u flag
##  tells rsync not to delete any pre-existing files in the directory.
rsync -auzv $BACKUP_DIR $REMOTE_DIR

echo "Synchronized $BACKUP_DIR to $REMOTE_DIR."
