#!/bin/bash
#
# Copyright (c) 2020 The Broad Institute, Inc. All rights reserved.
#

cd ..
panoply=`pwd`
cd hydrant
red='\033[0;31m'
grn='\033[0;32m'
reg='\033[0m'
err="${red}error.${reg}"
not="${grn}----->${reg}" ## notification

display_usage() {
  echo "usage: ./update.sh -t [task_name] -n [docker_namespace] [-h]"
  echo "-t | string | task name"
  echo "-n | string | Docker namespace for building and pushing"
  echo "-g | string | Docker tag"
  echo "-h | flag   | Print Usage"
  exit
}

while getopts ":t:n:g:h" opt; do
    case $opt in 
        t) task="$OPTARG";;
        n) docker_ns="$OPTARG";;
        h) display_usage;;
        g) docker_tag="$OPTARG";;
        \?) echo "Invalid Option -$OPTARG" >&2;;
    esac
done

if [[ -z "$task" ]]; then
  echo -e "$err Task not entered. Exiting."
  exit
fi
if [[ -z "$docker_ns" ]]; then
  echo -e "$err Docker namespace not entered. Exiting."
  exit
fi
if [[ -z "$docker_tag" ]]; then
  docker_tag=`git log -1 --pretty=%h`
fi


## create maps 
R CMD BATCH --vanilla "--args -p $panoply -t $task" map_dependency.r

## prune local docker images
echo -e "$not Pruning local docker images to ensure new build..."
yes | docker system prune --all;

## read targets for current task
ftarget=$panoply/hydrant/tasks/targets/$task-targets.txt
targets=`head -n 1 $ftarget`
IFS=';' read -ra targets <<< "$targets"


## build and push targets
base_url="https://registry.hub.docker.com/v2/repositories/"
for target in "${targets[@]}"
do
  ./setup.sh -t $target -n $docker_ns -y -b -g $docker_tag -x -u
  ./setup.sh -t $target -n $docker_ns -z
  sleep 60
done
./setup.sh -t $task -n $docker_ns -e
