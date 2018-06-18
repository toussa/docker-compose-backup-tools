#!/bin/bash

#First check if the user provided all needed arguments
if [ "$1" = "" ]
then
        echo "Please provide a source volume name"
        exit
fi

if [ "$2" = "" ]
then
        echo "Please provide a path to store the backup archive"
        exit
fi

BACKUP_PATH=$(realpath -e "$2") 
if [ ! -d "$BACKUP_PATH" ]
then
       echo "The target path does not exist"
       exit
fi



#Check if the source volume name does exist
docker volume inspect $1 > /dev/null 2>&1
if [ "$?" != "0" ]
then
        echo "The source volume \"$1\" does not exist"
        exit
fi


echo "Launching a container to tar volume into archive $1_$(date +%Y%m%d).tar.gz";

docker run --rm -v $1:/backupfrom:ro -v $BACKUP_PATH:/backupto:rw debian:jessie bash -c "cd /backupfrom && tar czf /backupto/$1_`date +%Y%m%d`.tar.gz *"
