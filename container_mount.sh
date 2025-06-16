#!/bin/bash
CONTAINER=$1
USAGE(){
  echo "You need to pass a containername"
  basename=$0
  echo "usage: $basename [CONTAINERNAME]"
  exit 1
}

LOG () {
  local MESSAGE="${@}"
  echo "$MESSAGE"
}

if [[ $# -lt 1 ]] || [[ $# -gt 1 ]]
then
  USAGE
fi

if [[ ! -d /mnt/blobfusetmp/$CONTAINER ]]; then
mkdir -p /mnt/blobfusetmp/$CONTAINER
    if [ $? == 0 ]; then
    chmod 777 /mnt/blobfusetmp/$CONTAINER
    fi
fi
if [[ ! -d /opt/stgcontainer/$CONTAINER ]]; then
mkdir -p /opt/stgcontainer/$CONTAINER
fi

blobfuse2 mount /opt/stgcontainer/$CONTAINER --config-file=/azconfig.yaml --tmp-path=/mnt/blobfusetmp/$CONTAINER -o allow_other,rw --container-name=$CONTAINER

mountpoint -q /opt/stgcontainer/$CONTAINER
if [ $? == 0 ]; then
LOG "/opt/stgcontainer/$CONTAINER is MOUNTED"
else
LOG "/opt/stgcontainer/$CONTAINER is NOT MOUNTED"
fi
