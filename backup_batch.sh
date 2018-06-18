#!/bin/bash

########
#
# This script backups all job that are defined in backup.d/ directory (*.conf)
# OR the specific job given in parameter $1 (with the name = the_corresponding_filename.conf in backup.d)
#

#Global shortcuts, don't touch
Script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Backup_dir="/absolute/path/to/backups/";

if [ ! -d "$Script_dir" ]
  then echo "Error: Script directory($Script_dir) does not exist";
  exit -1;
fi;


if [ ! -d "$Backup_dir" ];
  then echo "Error: Backup directory($Backup_dir) does not exist";
  exit -1;
fi;

if [ ! -d "$Script_dir/backup.d/" ];
  then echo "Error: '$Script_dir/backup.d/' directory is missing";
  exit -1;
fi;

echo "-- Starting backup script on date: $(date +%Y%m%d) --";

if [ "$1" != "" ] && [ -e "$Script_dir/backup.d/$1.conf" ]
then
  echo "Using given backup job $1.conf"
  Backup_jobs="$Script_dir/backup.d/$1.conf";
elif [ "$1" != "" ]
then
  echo "Error: $1.conf not found in backup.d/ directory"
  exit -1;
else
  Backup_jobs=$(ls $Script_dir/backup.d/*.conf 2>/dev/null);
fi

if [ "$Backup_jobs" = "" ]
then echo "Error: No jobs found in Script_dir/backup.d/*.conf";
  exit -1;
fi;

cleanVariables () {

  Project_name="";
  Config_dir="";
  DB_volume_name="";
  Files_volume_name="";
  Documents_volume_name="";
}

verifyVariables () {

  if [ "$Project_name" = "" ]
  then
    echo "Error: No project name set( var: Project_name)" 
    return -1;
  fi;

  if [ "${Config_dir:0:1}" != "/" ] || [ ! -d "$Config_dir" ]
  then
    echo "Error: Config_dir($Config_dir) variable must be an absolute path to the project directory"
    return -1;
  fi;

  return 0;
}


for job in $Backup_jobs
do

  echo "Handling backup job: $job"
  cleanVariables
  source $job;

  verifyVariables
  if [ "$?" != "0" ]
  then
    echo "Error in config => skipping the job $job"
    continue;
  fi;

  cd $Config_dir;

  if [ "$DB_volume_name $Files_volume_name $Documents_volume_name" != "  " ]
  then

    echo "Stopping containers..."
    #important for database for example 
    /usr/local/bin/docker-compose stop; 
    echo "Containers stopped"
    
    if [ "$DB_volume_name" != "" ] 
    then 
      echo "Backuping database volume $DB_volume_name ..." 
      $Script_dir/named_volume_backup.sh $DB_volume_name $Backup_dir 
    fi 
 
    if [ "$Files_volume_name" != "" ] 
    then 
      echo "Backuping file volume $Files_volume_name ..." 
      $Script_dir/named_volume_backup.sh $Files_volume_name $Backup_dir 
    fi

    if [ "$Documents_volume_name" != "" ]
    then
      echo "Backuping documents volume $Documents_volume_name ..."
      $Script_dir/named_volume_backup.sh $Documents_volume_name $Backup_dir
    fi

    cd $Config_dir;
    echo "Starting containers..."
    /usr/local/bin/docker-compose start;
    echo "Containers started"
  fi;

  echo "Backuping configuration directory..." 
  tar czf $Backup_dir/${Project_name}_config-dir_`date +%Y%m%d`.tar.gz *

  echo "Backup done for job $job"
done

echo "Backuping configuration directory..."
tar czf $Backup_dir/${Project_name}_config-dir_$(date +%Y%m%d).tar.gz *

echo "Encrypting archives..."
gpg --multifile -e $Backup_dir/*_$(date +%Y%m%d).tar.gz
if [ "$?" = "0" ]
then
  echo "Encription done, removing clear archives..."
  rm -rfv $Backup_dir/*_$(date +%Y%m%d).tar.gz
else
  echo "Error during archive encryption ! warning, archives left unencrypted !"
  echo "$(ls -l $Backup_dir/)" | mail -s "Encription error for date $(date +%Y%m%d)" "admin@website.com"
fi

echo "-- End of backup script --"
