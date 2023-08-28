#!/bin/bash

set -o pipefail

# my hostname
my_host=$(hostname --short)

# my PID
MY_PID=$$

# topdir location to write output files
LOGDIR="/home/unix/sa-ferrara/patch-info"

# host specific
HOSTLOGDIR="${LOGDIR}/${my_host}"

# tmpfile
TMP_FILE=$(mktemp /tmp/${my_host}.XXXX)

# HOSTLIST=${1:-"hostlist.txt"}
HOSTLIST="hostlist.txt"

write_state() {
  local now
  local state=$1
  local step=$2

  now=$(date +"%Y-%m-%d %H:%M:%S")
  echo "${now}:${state}:${step}" > ${HOSTLOGDIR}/${my_host}.state
}

log_msg() {
  local now
  local msg=$*

  now=$(date +"%Y-%m-%d %H:%M:%S")
  echo "${now}: ${msg}" >> ${HOSTLOGDIR}/${my_host}.log
}

# start up checks
if [ ! -d "${LOGDIR}" ]
then
  echo "ERROR: LOGDIR (${LOGDIR}) missing!! Exitting..."
  exit 1
fi

# create host log dir
if [ ! -d "${LOGDIR}/${my_host}" ]
then
  mkdir "${LOGDIR}/${my_host}" > ${TMP_FILE} 2>&1
  retcode=$?
  if [ ${retcode} -ne 0 ]
  then
    echo "ERROR: Unable to create host log directory (${LOGDIR}/${my_host})!! Exitting..."
    cat ${TMP_FILE}
    exit 1
  fi
fi

# ensure LOGDIR is writeable
TESTFILE=$(mktemp -q ${LOGDIR}/${my_host}/${my_host}.XXXXXX)
if [ $? -ne 0 ]; then
   log_msg "$0: Unable to write in LOGDIR (${LOGDIR}/${my_host}/${my_host}.XXXXXX), exiting..."
   write_state FAILED Initializing
   exit 1
fi
rm -f ${TESTFILE}

log_msg "Starting host run.."
write_state RUNNING Launch

# loop through

for i in  $(cat ${HOSTLIST})
do 
  log_msg "Running on host ${i}..."
  write_state RUNNING "Host: ${i}..."
 
  ping -c 1 -W 5 ${i} > /dev/null 2>&1
  retcode=$?
  if [[ "${retcode}" -ne 0 ]]
  then
    log_msg "Host ${i} - Ping timeout(${retcode})"
    write_state RUNNING "Host: ${i} timeout(${retcode})"
    continue
  else
    log_msg "Host ${i} - SSH Launch"
    write_state RUNNING "Host: ${i} ssh launch"
    ssh -n -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no -o ConnectTimeout=1 ${i} nohup /home/unix/sa-ferrara/Broad-repos/hjf-playground/linux/get-patch.sh &
    retcode=$?
    if [[ "${retcode}" -ne 0 ]]
    then
      log_msg "Host ${i} - SSH non-zero(${retcode})"
      write_state RUNNING "Host: ${i} ssh non-zero(${retcode})"
    else
      log_msg "Host ${i} - SSH Complete"
      write_state RUNNING "Host: ${i} ssh Complete"
    fi
  fi
done

