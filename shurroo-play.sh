#!/bin/bash

CUSTOM_LOCATION="/Volumes/Shurroo"
DEFAULT_LOCATION="~/.shurroo"

function run_playbook() {
  CUSTOM_FILE="${CUSTOM_LOCATION}""/${1}/${1}.yml"
  DEFAULT_FILE="${DEFAULT_LOCATION}""/shurroo/${1}.yml"


  if [[ -f "${CUSTOM_FILE}" ]]
  then
    PLAYBOOK_FILE="${CUSTOM_FILE}"
  elif [[ -f "${DEFAULT_FILE}" ]]
  then
    PLAYBOOK_FILE="${DEFAULT_LFILE}"
  else
    printf "Missing action playbook for '%s'\n" "${1}"
    exit 1
  fi
  cd "${DEFAULT_LOCATION}" >/dev/null
  ansible-playbook -i "localhost," "${PLAYBOOK_FILE}"
}

for role in "${@}"
do
  run_playbook "$role"
done
