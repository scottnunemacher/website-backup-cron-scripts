#!/usr/bin/env bash

# prune_daily.sh
# Can be run attended or unattended (crontab).
# Crontab entry could look like:
# 30 0 * * * /path/to/website.com_prune_daily.sh > /dev/null 2>&1
# Ref: https://unix.stackexchange.com/a/678296/501914

# !!! IMPORTANT: Must read through all comments and adjust script as necessary. !!!

# Script Purpose
# To prune (remove extras) of a folder of backups in order to keep the backup count to a managable size.
# Script keeps all first-of-the-month backups as well as the last X number of backups no matter 
# how old the last backup is.

# Change the variables below to suit your needs.

# ===========================
# Variables
# ===========================
# Modify these:
# Domain name without the TLD.:
BACKUPDOMAIN='website'
# User and home dir name:
BACKUPUSER='user'
# Name of the root of your backup dir:
BACKUPDIRNAME="backups"
# Backups to retain (backups with a day of 01 (first-of-month) will always be kept as well):
RETAIN=15

# This is a shell glob (with no wildcards):
BASEPATH="/home/$BACKUPUSER/$BACKUPDIRNAME/$BACKUPDOMAIN.com/"

# This is an extended regex pattern:
BASEREGEX="/home/$BACKUPUSER/$BACKUPDIRNAME/$BACKUPDOMAIN\.com/$BACKUPDOMAIN\.com-([0-9]{8}-[0-9]{6}Z)-$BACKUPUSER"

# This is a printf spec to printf a date-time to a full directory name:
PRINTFSPEC="/home/$BACKUPUSER/$BACKUPDIRNAME/$BACKUPDOMAIN.com/$BACKUPDOMAIN.com-%q-$BACKUPUSER"

# ===========================
# Script
# ===========================
# STEP: Find the base backup dir and list every backup dir in it.
find "$BASEPATH" -maxdepth 1 -mindepth 1 \
    -type d \
    -regextype posix-extended \
    -regex "${BASEREGEX}" |

# STEP: Find all backup dirs but ignore the first-of-the-month ones.
sed -Ee "s~^${BASEREGEX}$~\1~" |
grep -Ev '^[0-9]{6}01-' |

# STEP: List out all backups to be deleted (and if happy after testing, change comments below to send to a delete shell)
sort -r |
tail -n +$(($RETAIN+1)) |
while IFS= read line
do
    # TESTING: First a test, this will only print intended items to delete. 
    printf "This would remove \"${PRINTFSPEC}\"\n" "$line"

    # AFTER TESTING: If happy with results, comment the above printf and uncomment the below printf. Save and re-run to do it.
    # printf "rm -rf \"${PRINTFSPEC}\"\n" "$line" | sh
done

### !!! IMPORTANT !!! ###
# STEP: Unsets all script variables.
unset BACKUPDOMAIN BACKUPUSER BACKUPDIRNAME RETAIN BASEPATH BASEREGEX PRINTFSPEC

# Done.
