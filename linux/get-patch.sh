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

# string for final status msg
final_state=""

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

log_msg "Check patches to apply"
write_state RUNNING Patch-check
# get list of packages that need to be applied

# run yum check update for list 
yum check-update --exclude=${EXCLUDE} --skip-broken > ${TMP_FILE} 2> ${TMP_FILE}.err
retcode=$?
log_msg "Check complete"
write_state RUNNING "Patch-check complete"

case ${retcode} in
  100) log_msg "Needs PATCHING"
       final_state="${final_state} Needs-Patching"
     
       # get just list of patches
       log_msg "Building patch list"
       write_state RUNNING "Building-patchlist"
       sed -n -e '/^$/,$p' < ${TMP_FILE}  | sed '/^[[:space:]]*$/d' > ${LOGDIR}/${my_host}/patch-list.txt
  ;;
  0) log_msg "Fully PATCHED"
     final_state="${final_state} Fully-Patched"
     # clean out any left over patch list files
     cat /dev/null > ${LOGDIR}/${my_host}/patch-list.txt
  ;;
  *) log_msg "Unknown yum check-update return code (${retcode})"
     write_state COMPLETE "Unknown-Error"
     cp ${TMP_FILE} ${TMP_FILE}.err ${LOGDIR}/${my_host}/
     exit 0
  ;;
esac

# alwasys check if reboot required in case previous patch never rebooted
log_msg "Checking if reboot required"
write_state RUNNING "Checking-if-reboot-required"
needs-restarting -r > ${TMP_FILE} 2> ${TMP_FILE}.err
retcode=$?
if [ "${retcode}" -ne 0 ]
then
  log_msg "COMPLETE - Reboot required"
  write_state COMPLETE "Reboot-Required"
  cp ${TMP_FILE} ${LOGDIR}/${my_host}/reboot-list.txt
  final_state="${final_state} Reboot-Required"
else
  rm -f ${LOGDIR}/${my_host}/reboot-list.txt
fi

rm -f ${TMP_FILE} ${TMP_FILE}.err

log_msg "run COMPLETE"
write_state COMPLETE "${final_state}"
exit 0
