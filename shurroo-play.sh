#!/bin/bash

USER_HOME=$(printf "%s" ~)
CUSTOM_LOCATION="/Volumes/Shurroo"
DEFAULT_LOCATION="${USER_HOME}""/.shurroo"

declare -a ANSIBLE_OPTS
for arg in "${@}"
do
  if [[ "$arg" =~ \-.* ]]
  then
    ANSIBLE_OPTS+="$arg"
    shift
  fi
done

function run_playbook() {
  CUSTOM_FILE="${CUSTOM_LOCATION}""/${1}/${1}.yml"
  DEFAULT_FILE="${DEFAULT_LOCATION}""/shurroo/${1}.yml"

  if [[ -f "${CUSTOM_FILE}" ]]
  then
    FILE_SOURCE="custom"
    PLAYBOOK_FILE="${CUSTOM_FILE}"
  elif [[ -f "${DEFAULT_FILE}" ]]
  then
    FILE_SOURCE="default"
    PLAYBOOK_FILE="${DEFAULT_FILE}"
  else
    printf "Missing action playbook for '%s'\n" "${1}"
    exit 1
  fi
  cd "${DEFAULT_LOCATION}" >/dev/null
  printf "Using %s playbook file at %s\n" "$FILE_SOURCE" "$PLAYBOOK_FILE"
  ansible-playbook --ask-become-pass -i "localhost," "${ANSIBLE_OPTS[@]}"  "${PLAYBOOK_FILE}"
}

for role in "${@}"
do
  run_playbook "$role"
done
