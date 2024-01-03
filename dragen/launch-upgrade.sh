#!/bin/bash

# DRAGEN_LIST="21 31 30"
# DRAGEN_LIST="05 06 07 10 11 12 13 14 15 16 17 18 19 20 22 23 24 25 28 29 32 33 34 35 36 37"
DRAGEN_LIST="07 08 10 11 12 28 29 32 33 34 35 36 37 41 42 43 44"

# loop through

for i in ${DRAGEN_LIST}
do 
  echo -n "Running dragen${i} ... "
  ping -c 1 -W 5 dragen${i} 2>&1 > /dev/null
  retcode=$?
  if [[ "${retcode}" -ne 0 ]]
  then
     echo "FAILED"
     continue
  else
    ssh -n -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no -o ConnectTimeout=1 dragen${i} nohup /home/unix/sa-ferrara/Broad-repos/hjf-playground/dragen/upgrade.sh & 
  fi
  echo "Launched"

done

