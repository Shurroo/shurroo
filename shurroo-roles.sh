#!/bin/bash

CUSTOM_LOCATION="/Volumes/Shurroo"
DEFAULT_LOCATION="~/.shurroo"
CUSTOM_FILE="${CUSTOM_LOCATION}""/requirements.yml"
DEFAULT_FILE="${DEFAULT_LOCATION}""/requirements.yml"

cd "${DEFAULT_LOCATION}" >/dev/null
if [[ -f "${CUSTOM_FILE}" ]]
then
  REQUIREMENTS_FILE="${CUSTOM_FILE}"
else
  REQUIREMENTS_FILE="${DEFAULT_FILE}"
fi
ansible-galaxy install -f -r "${REQUIREMENTS_FILE}"
