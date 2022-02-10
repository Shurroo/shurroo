#!/bin/bash

script_location="~/.shurroo/shurroo"

function update() {
  source "$script_location/shurroo-update.sh" $@
}

function roles() {
  source "$script_location/shurroo-roles.sh" $@
}

function play() {
  source "$script_location/shurroo-play.sh" $@
}

if [[ -z "$1" ]]
then
  printf "\nUsage: shurroo update | roles | play \n"
  printf "    install <role-name>\n\n"
  exit 2
fi

action_list=$(declare -F)
# Do we know this action?
if [[ $action_list != *"$1"* ]]
then
  printf "Unknown action '%s'\n" "$1"
  exit 1
fi

action_file="$script_location/shurroo-$1.sh"

printf "Looking for '%s'\n" "$action_file"
ls -al "$action_file"
if [[ -f "$action_file" ]]
then
  printf "File is a regular file\n"
else
  printf "File is NOT a regular file\n"
fi
if [[ -e "$action_file" ]]
then
  printf "File exists\n"
else
  printf "File does NOT exist\n"
fi
if [[ -x "$action_file" ]]
then
  printf "File is executable\n"
else
  printf "File is NOT executable\n"
fi

# Can we execute the script file?
if [[ ! -x "$script_location/shurroo-$1.sh" ]]
then
  printf "Cannot run action script for '%s'\n" "$1"
  exit 1
else
  action_name="$1"
  shift
  $action_name $@
fi
exit 0
