#!/bin/bash

#First check if the user provided all needed arguments
if [ "$1" = "" ]
then
        echo "Please provide a source tarball archive"
        exit
fi

if [ "$2" = "" ]
then
        echo "Please provide a target volume name to create"
        exit
fi

if [ ! -f "$1" ]
then
       echo "The archive does not exist"
       exit
fi

ARCHIVE_PATH=$(realpath -e "$1");

#Check if the target volume name does exist
docker volume inspect $2 > /dev/null 2>&1
if [ "$?" = "0" ]
then
        echo "The target volume \"$2\" already exists"
        exit
fi


echo "Creating destination volume \"$2\"..."
docker volume create --name $2
echo "Copying data from archive \"$ARCHIVE_PATH\" to destination volume \"$2\"..."

docker run --rm -v $ARCHIVE_PATH:/backup.tar.gz:ro -v $2:/backupto:rw debian:jessie bash -c "cd /backupto && tar -zxf /backup.tar.gz"
