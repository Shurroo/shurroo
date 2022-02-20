#!/bin/bash

USER_HOME=$(printf "%s" ~)
LOG_LOCATION="${USER_HOME}""/.shurroo/log"

function log_playbook() {
  LOG_FILES=()
  while IFS=  read -r -d $'\0'; do
    LOG_FILES+=("$REPLY")
  done < <(find "${LOG_LOCATION}" -regex ".*$1.*log" -print0)
  if (( ${#LOG_FILES[@]} == 0 ))
  then
    printf "Found no log files for %s\n" "$1"
    return 1
  fi
  # We expect each log file to be short: usually < 15 lines
  # If the log files get longer, we may switch to using less instead of cat
  if (( ${#LOG_FILES[@]} == 1 ))
  then
    printf "%s\n\n" "${LOG_FILES[0]}"
    cat "${LOG_FILES[0]}"
    printf "\n"
  else
    IFS=$'\n' LOG_SORTED=($(sort <<<"${LOG_FILES[*]}"))
    unset IFS
    LATEST=${#LOG_SORTED[@]}-1
    printf "%s\n\n" "${LOG_SORTED[$LATEST]}"
    cat "${LOG_SORTED[$LATEST]}"
    printf "\n"
  fi
}

for role in "${@}"
do
  log_playbook "$role"
done
