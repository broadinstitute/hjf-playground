#!/bin/bash

# This script will scan log dir and report the status of the upgrade
# outputing dragen host list in the following states
#  - failed upgrade
#  - successful upgrade
#  - in-progress upgrade
#  
LOGDIR="/home/unix/sa-ferrara/aou-upgrade-378"

declare -A state_array=()

# loop through all state files
for statefile in ${LOGDIR}/*.state
do
   host=$(basename ${statefile} | sed -e 's/\.state//')
   state_value=$(cut -d ':' -f4 ${statefile})
   state_str=$(cut -d ':' -f5- ${statefile} | tr " " "_")
   key_value="${state_value}_${state_str}"
   state_array[${key_value}]+=" ${host}"
done

for key in "${!state_array[@]}"
do
   echo "${key}: ${state_array[${key}]}"
done

# output counts and list 
