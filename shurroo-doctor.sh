#!/bin/bash

abort() {
  printf "%s\n" "$@"
  exit 1
}

# Fail fast with a concise message when not using bash
# Single brackets are needed here for POSIX compatibility
# shellcheck disable=SC2292
if [ -z "${BASH_VERSION:-}" ]
then
  abort "Bash is required to interpret this script."
fi

# Line 0036
# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

MKDIR=("/bin/mkdir" "-p")

execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

check_dir() {
  if [ ! -d "$1" ]
  then
    warn "$(printf "%s directory not found at %s" "$2" "$1")"
  fi
}

check_file() {
  if [ ! -f "$1" ]
  then
    warn "$(printf "%s file not found at %s" "$2" "$1")"
  fi
}

USER_HOME=$(printf "%s" ~)
DOT_SHURROO="${USER_HOME}""/.shurroo"
SHURROO_REPO="${DOT_SHURROO}""/shurroo"
SHURROO_GIT="${SHURROO_REPO}""/.git"
SHURROO_GIT_REMOTE="https://github.com/shurroo/shurroo"
ANSIBLE_ROLES="${DOT_SHURROO}""/roles"
ANSIBLE_COLLECTIONS="${DOT_SHURROO}""/collections"
ANSIBLE_CONFIG="${DOT_SHURROO}""/ansible.cfg"
PYTHON_KEY="interpreter_python"

ohai "Checking directories ..."
check_dir "${SHURROO_REPO}" 'Shurroo repository'
check_dir "${ANSIBLE_ROLES}" 'Ansible roles'

ohai "Checking Ansible configuration ..."
check_file "${ANSIBLE_CONFIG}" 'Ansible configuration'

if [ -f "${ANSIBLE_CONFIG}" ]
then
  INTERPRETER=$(execute grep "${PYTHON_KEY}" "${ANSIBLE_CONFIG}")
  FILE_KEY=$(printf "${INTERPRETER}" | cut -f 1 -d " " -)
  PYTHON=$(printf "${INTERPRETER}" | cut -f 3 -d " " -)
  if [ "${FILE_KEY}" != "${PYTHON_KEY}" ]
  then
    warn "No Python specified in ansible.cfg"
  fi
  check_file "${PYTHON}" "Python in ansible.cfg"
fi

ohai "Checking Homebrew status ..."
BREW_DOCTOR=$(brew doctor)
if [ "${BREW_DOCTOR}" != "Your system is ready to brew." ]
then
  warn "$(printf "Homebrew shows warnings, run %s to see them" '`brew doctor`')"
fi

ohai "$(printf "All checks completed. Run %s to fix any warnings." '`shurroo update`')"
