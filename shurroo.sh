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

printf "Looking for '%s'\n" "$script_location/shurroo-$1.sh"
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
