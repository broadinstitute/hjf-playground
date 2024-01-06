#!/bin/bash

# data gather script to track what NFS shares are mounted and what
#  ESTABLISHED communications happen to/from node

# it is intended to run on all seqprod gridengine compute nodes
#  currently in use - both base-calling and operations nodes

# the data is intended to determine the ACLs required for a new single VLAN
#  that would host all seqprod gridengine compute nodes

LOGDIR="/home/unix/sa-ferrara/seqprod-singlevlan"

my_host=$(hostname --short)

TMP_DIR=$(mktemp -d /tmp/tracker-XXXX)

echo "Begin capture: $(date)"

if [ ! -d ${LOGDIR}/${my_host} ]
then
   echo "Create host dir (${LOGDIR}/${my_host}) ..."
   mkdir ${LOGDIR}/${my_host}
fi

#
# netstat -an
echo "Begin capturing network communications..."

# capture current conns
netstat -n | gawk '$NF == "ESTABLISHED" { split($5,remote,":"); print remote[2] " " remote[1] } ' | while read port ip
do
   echo $ip >> ${TMP_DIR}/port-${port}.txt
done

# sort files
for portfile in ${TMP_DIR}/port-*.txt
do
   sort ${portfile} > ${portfile}.new
   mv ${portfile}.new ${portfile}
done

# check if current list have any new ips from previous runs
for portfile in ${TMP_DIR}/port-*.txt
do
  justfile=$(basename $portfile)
  # previous run does not exist so new port
  if [ ! -e ${LOGDIR}/${my_host}/${justfile} ]
  then
     cp ${portfile} ${LOGDIR}/${my_host}/${justfile}
  else
     # see if there is any new ips for port
     comm -13 ${LOGDIR}/${my_host}/${justfile} ${portfile} > ${TMP_DIR}/conns-add
     if [ -s ${TMP_DIR}/conns-add ]
     then
        # new ips add to capture
        cat ${TMP_DIR}/conns-add ${LOGDIR}/${my_host}/${justfile} | sort > ${TMP_DIR}/conns-new
        cp ${TMP_DIR}/conns-new ${LOGDIR}/${my_host}/${justfile}
     fi
  fi
done

#
# nfs mounts
# get current mounted shares
echo "Begin capturing NFS shares..."
mount -t nfs | gawk '{ print $1","$3 }' | sort > ${TMP_DIR}/shares

if [ ! -e ${LOGDIR}/${my_host}/shares.txt ]
then
   cp ${TMP_DIR}/shares ${LOGDIR}/${my_host}/shares.txt
else
   # see if anything new
   comm -13 ${LOGDIR}/${my_host}/shares.txt ${TMP_DIR}/shares > ${TMP_DIR}/shares-add

   if [ -s ${TMP_DIR}/shares-add ]
   then
      # update main tracking
      # regen updated sorted list
      cat ${TMP_DIR}/shares-add ${LOGDIR}/${my_host}/shares.txt | sort > ${TMP_DIR}/shares-new
      cp ${TMP_DIR}/shares-new ${LOGDIR}/${my_host}/shares.txt
   fi
fi

# clean up
rm -f ${TMP_DIR}/shares ${TMP_DIR}/shares-add ${TMP_DIR}/shares-new
rm -f ${TMP_DIR}/port-*.txt ${TMP_DIR}/conns-add ${TMP_DIR}/conns-new

rmdir ${TMP_DIR}

echo "End capture: $(date)"
