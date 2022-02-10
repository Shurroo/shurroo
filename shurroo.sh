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

if [[ -z "$1" ]]
then
  printf "\nUsage: shurroo update | roles | play \n"
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

ACTION_FILE="$SCRIPT_LOCATION/shurroo-$1.sh"

printf "Looking for '%s'\n" "$ACTION_FILE"
ls -al "$ACTION_FILE"
if [[ -f "$ACTION_FILE" ]]
then
  printf "File is a regular file\n"
else
  printf "File is NOT a regular file\n"
fi
if [[ -e "$ACTION_FILE" ]]
then
  printf "File exists\n"
else
  printf "File does NOT exist\n"
fi
if [[ -x "$ACTION_FILE" ]]
then
  printf "File is executable\n"
else
  printf "File is NOT executable\n"
fi

# Does the script file exist?
if [[ ! -e "$SCRIPT_LOCATION/shurroo-$1.sh" ]]
then
  printf "Cannot find action script for '%s'\n" "$1"
  exit 1
fi

# Can we execute the script file?
if [[ ! -x "$SCRIPT_LOCATION/shurroo-$1.sh" ]]
then
  printf "Cannot run action script for '%s'\n" "$1"
  exit 1
fi

action_name="$1"
shift
$action_name $@
exit 0
