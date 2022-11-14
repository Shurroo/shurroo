#!/bin/bash

USER_HOME=$(printf "%s" ~)
SCRIPT_LOCATION="${USER_HOME}""/.shurroo/shurroo"

function update() {
  source "$SCRIPT_LOCATION/shurroo-update.sh" $@
}

function roles() {
  source "$SCRIPT_LOCATION/shurroo-roles.sh" $@
}

function play() {
  source "$SCRIPT_LOCATION/shurroo-play.sh" $@
}

function log() {
  source "$SCRIPT_LOCATION/shurroo-log.sh" $@
}

function doctor() {
  source "$SCRIPT_LOCATION/shurroo-doctor.sh" $@
}

if [[ -z "$1" ]]
then
  printf "\nUsage: shurroo update | roles | play | log\n"
  printf "    install <role-name>\n\n"
  exit 2
fi

ACTION_LIST=$(declare -F)
# Do we know this action?
if [[ $ACTION_LIST != *"$1"* ]]
then
  printf "Unknown action '%s'\n" "$1"
  exit 1
fi
ACTION_SCRIPT="$SCRIPT_LOCATION/shurroo-$1.sh"
# Does the script file exist?
if [[ ! -e "$ACTION_SCRIPT" ]]
then
  printf "Cannot find action script for '%s'\n" "$1"
  exit 1
fi
# Can we execute the script file?
if [[ ! -x "$ACTION_SCRIPT" ]]
then
  printf "Cannot run action script for '%s'\n" "$1"
  exit 1
fi

ACTION_NAME="$1"
shift
$ACTION_NAME $@
exit 0
