#!/bin/bash

# This script cleans the backup directory of old backups

#Global shortcuts, don't touch
Script_dir=$(realpath -e $(dirname "$0"));
Backup_dir="/absolute/paths/to/backups/";

if [ ! -d "$Script_dir" ]
  then echo "Error: Script directory($Script_dir) does not exist";
  exit -1;
fi;

if [ ! -d "$Backup_dir" ];
  then echo "Error: Backup directory($Backup_dir) does not exist";
  exit -1;
fi;

echo "-- starting cleaning script on date: $(date +%Y%m%d) --"

cd $Backup_dir;

DAYS_AGO_8="$(date -d '8 days ago' +%Y%m%d)";
DAYS_AGO_8_dow="$(date -d '8 days ago' +%u)";
DAYS_AGO_8_dom="$(date -d '8 days ago' +%d)";
DAYS_AGO_8_doy="$(date -d '8 days ago' +%j)";

echo "looking for deleting 8 days-old backups (date: $DAYS_AGO_8)"

if [ "$DAYS_AGO_8_dow" = "1" ] || [ "$DAYS_AGO_8_dom" = "01" ]  || [ "$DAYS_AGO_8_doy" = "001" ]
then
  echo "No deletion, it was the first day of the week/month/year"
else
  echo "Deleting backup because it wasn't the first of the week/month/year"
  rm -v *${DAYS_AGO_8}.tar.gz.gpg
fi

echo "now, depending of today, check if we should delete other backups"

Today_dow="$(date +%u)";
Today_dom="$(date +%d)";
Today_doy="$(date +%j)";

echo "Looking if we should delete the monday-backup made 5 weeks ago";

if [ "$Today_dow" = "1" ] && [ "$(date -d '5 weeks ago' +%d)" != "01" ]  && [ "$(date -d '5 weeks ago' +%j)" != "001" ]
then
  echo "We're monday, deleting the last monday backuped 5 weeks ago";
  rm -v *$(date -d '5 weeks ago' +%Y%m%d).tar.gz.gpg
else
  echo "=> Nope.";
fi

echo "Looking if we should delete the first-day-of-month-backup made 13 months ago";
if [ "$Today_dom" = "01" ] && [ "$(date -d '13 months ago' +%j)" != "001" ] 
then
  echo "We're first day of month, deleting the backup made 13 months ago";
  rm -v *$(date -d '13 months ago' +%Y%m%d).tar.gz.gpg
else
  echo "=> Nope.";
fi

echo "--clean done--";
