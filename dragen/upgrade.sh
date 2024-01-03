#!/bin/bash
set -o pipefail

# set LOGDIR location
LOGDIR="/home/unix/sa-ferrara/aou-upgrade-378"
LOGDIR="/home/unix/sa-ferrara/komodo-upgrade"

# how long to wait between checking for slurm node to drain
SLEEP_TIME=300

# target version string
dragen_upgrade="4.2.4-4-gfc89cfd2"

# target puppet branch
# puppet_branch="hf_bond_ap"
puppet_branch="hf_komodo_20231213"

# Get hostname
my_host=$(hostname --short)

# my PID
MY_PID=$$

# functions

get_dragen() {
  local version=$(/opt/edico/bin/dragen --version |& awk '/^dragen Version/ {print $3}')
  echo $version
  return 0
}

write_state() {
  local now
  local state=$1
  local step=$2

  now=$(date +"%Y-%m-%d %H:%M:%S")
  echo "${now}:${state}:${step}" > ${LOGDIR}/${my_host}.state
}

log_msg() {
  local now
  local msg=$*

  now=$(date +"%Y-%m-%d %H:%M:%S")
  echo "${now}: ${msg}" >> ${LOGDIR}/${my_host}.log
}

get_node_state() {
  local state
  local retcode
  
  state=$(sinfo -N --noheader --nodes=${my_host} --format="%12T")
  retcode=$?
  echo ${state}
  return $retcode
}


# get dragen software version
dragen_version=$(get_dragen)

# make sure its not blank
if [ -z "${dragen_version}" ]
then
  log_msg "ERROR: unable to capture current dragen version (${dragen_version}). Exitting.."
  write_state FAILED Initializing
  exit 1
fi

# ensure LOGDIR is writeable 
TMPFILE=$(mktemp -q ${LOGDIR}/${my_host}.XXXXXX)
if [ $? -ne 0 ]; then
   log_msg "$0: Unable to write in LOGDIR (${LOGDIR}/${my_host}.XXXXXX), exiting..."
   write_state FAILED Initializing
   exit 1
fi
rm -f ${TMPFILE}

# write log msg
log_msg "${my_host}:${MY_PID}"

# if already upgraded exit 0
if [[ "${dragen_version}" == "${dragen_upgrade}" ]]
then
  log_msg "Node is up to date - complete.  Exitting"
   write_state END "Node already up to date"
  exit 0
fi 

# get slurm state
# slurm_state=$(scontrol show node=${my_host} | grep "State=" | awk ' { print $1 } ' |  cut -d "=" -f2)
slurm_state=$(get_node_state)
retcode=$?
if [ "${retcode}" -ne 0 ]
then
  log_msg "ERROR: unable to capture current slurm state(${slurm_state}). Exitting.."
  write_state FAILED Initializing
  exit 1
fi

# if not in drain or draining or drained state
#  exit in failed state
if [[ "${slurm_state}" != "drained" && "${slurm_state}" != "draining" && "${slurm_state}" != "down" && "${slurm_state}" != 'drained*' ]]
then
   # node is not in correct state
   log_msg "ERROR: Node is in wrong state to start upgrade (${slurm_state}). Exitting..."
   write_state FAILED Initializing
   exit 1
fi
   
# go in wait loop waiting for node to be in fully drained state
#  log each iteration and info about job running
while [[ "${slurm_state}" == "draining" ]]
do
   log_msg "Waiting for node to complete draining - sleeping (${SLEEP_TIME})"
   write_state BEGIN "Waiting to drain (${slurm_state})"
   sleep ${SLEEP_TIME}
   slurm_state=$(get_node_state)
   retcode=$?
   if [ "${retcode}" -ne 0 ]
   then
     log_msg "ERROR: unable to capture current slurm state(${slurm_state}). Exitting.."
     write_state FAILED "Waiting to drain..."
     exit 1
   fi
done

# log ready to upgrade
log_msg "Ready to upgrade: (${my_host}:${slurm_state})"
write_state BEGIN "Ready to upgrade"

# turn off puppet
log_msg "Turn off puppet during update"
write_state RUNNING "Turning off puppet"
cmd_output=$(systemctl stop puppet 2>&1)
retcode=$?
if [ "${retcode}" -ne 0 ]
then
   log_msg "disable puppet non-zero (${retcode}) status"
   log_msg "${cmd_output}"
   write_state FAILED "disable puppet returned non-zero status(${retcode)}"
   exit 1
fi
log_msg "Pupppet disabled"
write_state RUNNING "Pupppet disabled"

# yum remove current version of edico software
log_msg "Removing old dragen software"
write_state RUNNING "Removing old software"
cmd_output=$(yum remove -y edico edico_driver 2>&1)
retcode=$?
if [ "${retcode}" -ne 0 ]
then
   log_msg "yum erase returned non-zero (${retcode}) status"
   log_msg "${cmd_output}"
   write_state FAILED "yum removed returned non-zero status(${retcode)}"
   exit 1
fi
log_msg "Old Dragen software removed"
write_state RUNNING "Yum removal successful"

# begin_branch=$(puppet node find ${my_host} 2> /dev/null | grep "r10k_environment" | awk ' { print $2}')
log_msg "Beginning puppet apply (${puppet_branch}) for new software"
write_state RUNNING "Applying puppet branch (${puppet_branch})"

# run puppet putting dragen on new special puppet branch for upgraded software
cmd_output=$(puppet agent --test --environment=${puppet_branch} 2>&1 )
retcode=$?
if [[ "${retcode}" -ne 0 && "${retcode}" -ne 2 ]]
then
   log_msg "puppet apply returned non-zero (${retcode}) status"
   log_msg "${cmd_output}"
   write_state FAILED "puppet apply returned non-zero status(${retcode})"
   exit 1
fi
log_msg "Puppet apply succeeded"
write_state RUNNING "puppet apply successful"

# get dragen software to ensure upgraded to correct version
dragen_version=$(get_dragen)
if [[ "${dragen_version}" != "${dragen_upgrade}" ]]
then
    #  - wrong version exit FAILED
   log_msg "Wrong software version installed (${dragen_version} != ${dragen_upgrade})"
   write_state FAILED "Wrong software version installed (${dragen_version})"
   exit 1
fi

log_msg "Running sosreport boot up test"
write_state RUNNING "Running sosreport"
# run sosreport
cmd_output=$(systemctl restart sosreport 2>&1)
retcode=$?
if [ "${retcode}" -ne 0 ]
then
   #  - failed - exist FAILED
   log_msg "sosreport returned non-zero (${retcode}) status"
   log_msg "${cmd_output}"
   write_state FAILED "sosreport returned non-zero status(${retcode)}"
   exit 1
fi
log_msg "sosreport succeeded"
write_state RUNNING "sosreport successful"

# run self_test
log_msg "Running self_test boot up test"
write_state RUNNING "Running self_test"
cmd_output=$(systemctl restart self_test 2>&1)
retcode=$?
if [ "${retcode}" -ne 0 ]
then
   #  - failed - exist FAILED
   log_msg "self_test returned non-zero (${retcode}) status"
   log_msg "${cmd_output}"
   write_state FAILED "self_test returned non-zero status(${retcode)}"
   exit 1
fi
# grab status to get logfile paths
cmd_output=$(systemctl status self_test 2>&1)
log_msg "${cmd_output}"
log_msg "self_test succeeded"
write_state RUNNING "self_test successful"

# run smoke_test
log_msg "Running smoke_test boot up test"
write_state RUNNING "Running smoke_test"
# cmd_output=$(/home/unix/sa-ferrara/Broad-repos/bits-puppet/dist/broad_misc/files/misc_scripts/dragen/smoke_test.sh --force 2>&1)
cmd_output=$(systemctl restart smoke_test 2>&1)
retcode=$?
if [ "${retcode}" -ne 0 ]
then
   #  - failed - exist FAILED
   log_msg "smoke_test returned non-zero (${retcode}) status"
   log_msg "${cmd_output}"
   write_state FAILED "smoke_test returned non-zero status(${retcode)}"
   exit 1
fi
# grab status to get logfile paths
cmd_output=$(systemctl status smoke_test 2>&1)
log_msg "${cmd_output}"
log_msg "smoke_test succeeded"
write_state RUNNING "smoke_test successful"

# put node back into idle state
# log_msg "Putting node back into idle state"
# write_state RUNNING "Putting node in idle state"
# cmd_output=$(scontrol update node=${my_host} state=idle reason=SoftwareUpgradeComplete 2>&1)
# retcode=$?
# if [ "${retcode}" -ne 0 ]
# then
#    #  - failed - exist FAILED
#    log_msg "scontrol command returned non-zero (${retcode}) status"
#    log_msg "${cmd_output}"
#    write_state FAILED "scontrol command returned non-zero status(${retcode)}"
#    exit 1
# fi

# log_msg "Scontrol successful"
# write_state RUNNING "Scontrol successful"

slurm_state=$(get_node_state)
retcode=$?
if [ "${retcode}" -ne 0 ]
then
  log_msg "ERROR: unable to capture current slurm state(${slurm_state}). Exitting.."
  write_state WARNING "Node updated and tested but could not get node state (${retcode})"
  exit 1
fi

# if [[ "${slurm_state}" != "idle" ]]
# then
#   # node is not in correct state
#   log_msg "WARNING: Node updated and tested but could not put in idle state (${slurm_state}). Exitting..."
#   write_state WARNING "Node updated and tested but node not in correct state (${slurm_state})"
#   exit 1
#fi

#log_msg "Node (${my_host}) back in idle state"
#write_state SUCCESS "Node back in idle state"

dragen_version=$(get_dragen)

log_msg "Node (${my_host}) upgrade complete ready for production use running version (${dragen_version})"
write_state SUCCESS "Node in state (${slurm_state}) Running (${dragen_version})"

# exit success
exit 0
