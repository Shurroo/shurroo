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

USER_HOME=$(printf "%s" ~)
DOT_SHURROO="${USER_HOME}""/.shurroo"
SHURROO_REPO="${DOT_SHURROO}""/shurroo"
SHURROO_GIT="${SHURROO_REPO}""/.git"
SHURROO_GIT_REMOTE="https://github.com/shurroo/shurroo"
ANSIBLE_ROLES="${DOT_SHURROO}""/roles"
ANSIBLE_COLLECTIONS="${DOT_SHURROO}""/collections"

cd "${SHURROO_REPO}" >/dev/null

# The discrete steps will work even if the repository is damaged
# Add remote manually
execute "git" "config" "remote.origin.url" "${SHURROO_GIT_REMOTE}"
execute "git" "config" "remote.origin.fetch" "+refs/heads/*:refs/remotes/origin/*"
# Ensure line endings ok
execute "git" "config" "core.autocrlf" "false"
# Fetch
execute "git" "fetch" "--force" "origin"
execute "git" "fetch" "--force" "--tags" "origin"
# Reset
execute "git" "reset" "--hard" "origin/master"

# Create working directories
cd "${DOT_SHURROO}" >/dev/null
execute "${MKDIR[@]}" "${ANSIBLE_ROLES}"
execute "${MKDIR[@]}" "${ANSIBLE_COLLECTIONS}"

# Create working copy of ansible configuration and role requirements
execute cp "${SHURROO_REPO}""/files/ansible.cfg" "${DOT_SHURROO}" >/dev/null 2>&1
execute cp "${SHURROO_REPO}""/files/requirements.yml" "${DOT_SHURROO}" >/dev/null 2>&1

ohai "Shurroo repository update successful!"
