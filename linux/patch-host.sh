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

# exclude list
EXCLUDE='apptainer*,docker*,facter,foreman*,puppet*,slurm*,vault*,edico*,containerd*'

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

log_msg "Launching yum update..."
write_state RUNNING Patching

# run yum update 
yum -y update --exclude=${EXCLUDE} --skip-broken > ${TMP_FILE} 2> ${TMP_FILE}.err
retcode=$?
log_msg "Yum update complete"
write_state RUNNING "yum update complete"

case ${retcode} in
  0) log_msg "Patching successful"
     write_state RUNNING "Patching successful"
    ;;
  *) log_msg "Yum update exitted nonzero (${retcode})"
     write_state COMPLETE "Yum-Update-Error"
     cp ${TMP_FILE} ${TMP_FILE}.err ${LOGDIR}/${my_host}/
     exit 1
    ;;
esac

log_msg "Checking if reboot required"
write_state RUNNING "Checking-if-reboot-required"
needs-restarting -r > ${TMP_FILE} 2> ${TMP_FILE}.err
retcode=$?
if [ "${retcode}" -ne 0 ]
then
  log_msg "COMPLETE - Reboot required"
  write_state COMPLETE "Reboot-Required"
  cp ${TMP_FILE} ${LOGDIR}/${my_host}/reboot-list.txt
else
  log_msg "run COMPLETE"
  write_state COMPLETE "Patch-complete"
fi

exit 0
