#!/usr/bin/env bash

# backup_daily.sh
# Can be run attended or unattended (crontab).
# Crontab entry could look like:
# 0 0 * * * /path/to/website.com_backup_daily.sh > /dev/null 2>&1
# Ref: https://www.namecheap.com/support/knowledgebase/article.aspx/10094/2194/how-to-create-and-download-website-backup-automatically

# !!! IMPORTANT: Must read through all comments and adjust script as necessary. !!!

# Script Purpose
# To backup a shared-hosting php-based site; both DB and Files 
# in a folder structure system that allows for pruning (cleaning later on).
# This script is tested and works for Wordpress.
# When completed, backups will be located:
# /home/user/backups/website.com/website.com-20211101-040523Z-user/
# and contain:
# ├─ website.com-20211101-040523Z-user-db.sql.gz
# └─ website.com-20211101-040523Z-user-files.tar.gz

# Change the variables below to suit your needs.

# ===========================
# Variables
# ===========================
# Modify these:
# Name of your site:
SITE='website.com'
# Location of your home dir (leave off trailing forward slash):
HOMEDIR="/home/user"
# Name of the root of your backup dir:
BACKUPDIRNAME="backups"
# Location of the root dir of the website (this suit me, change as needed):
WEBROOT="public_$SITE"
# Database name:
DB='changeme'
# Database username:
DBUSER='changeme'
# Database password:
DBPASS='changeme'

# Backup name:
BACKUPNAME=$SITE-$(date -u +"%Y%m%d-%H%M%SZ")-`whoami`
# will produce db and file backup names like:
# website.com-20211101-040523Z-user-db.sql.gz
# website.com-20211101-040523Z-user-files.tar.gz

# Backup directory where the backups will be placed.
BACKUPDIR="$HOMEDIR/$BACKUPDIRNAME/$SITE/$BACKUPNAME"
# will create a directory named:
# /home/user/backups/website.com/website.com-20211101-040523Z-user/

# ===========================
# Functions
# ===========================
# Check for error each step. If error found; print specific error message for step.
check_errors()
{
  # Parameter 1 is the return code.
  # Parameter 2 is text to display on failure.
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # ${1} : ${2}"
    # script will exit with matching error code.
    exit ${1}
  fi
}

# ===========================
# Script
# ===========================
# STEP: Create the backup dirs for backups:
# /home/user/backups/website.com/website.com-20211101-040523Z-user
mkdir -p $BACKUPDIR -m 0755
check_errors $? 'Could not create backup directory. Check mkdir step.'

# STEP: Create the backup of database in backup dir:
mysqldump -u $DBUSER -p"$DBPASS" $DB | gzip > $BACKUPDIR/$BACKUPNAME-db.sql.gz
check_errors $? 'Could not create database backup. Check mysqldump step.'

# STEP: Create and compresses the backup of files in backup dir:
tar -czf $BACKUPDIR/$BACKUPNAME-files.tar.gz -C $HOMEDIR $WEBROOT
check_errors $? 'Could not create files backup. Check tar step.'

### !!! IMPORTANT !!! ###
# STEP: Unset all variables to be reset for next script.
unset SITE HOMEDIR BACKUPDIRNAME WEBROOT DB DBUSER DBPASS BACKUPNAME BACKUPDIR

# Done.
