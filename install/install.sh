#!/bin/bash

# We don't need return codes for "$(command)", only stdout is needed.
# Allow `[[ -n "$(command)" ]]`, `func "$(command)"`, pipes, etc.
# shellcheck disable=SC2312

set -u
# Force unset these variables: we are only concerned with macOS, and only interactive installation.
unset HOMEBREW_ON_LINUX
unset NONINTERACTIVE

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

# Line 0110
if [[ -z "${HOMEBREW_ON_LINUX-}" ]]
then
  UNAME_MACHINE="$(/usr/bin/uname -m)"
  STAT_PRINTF=("stat" "-f")
  PERMISSION_FORMAT="%A"
  CHOWN=("/usr/sbin/chown")
  CHGRP=("/usr/bin/chgrp")
  GROUP="admin"
  TOUCH=("/usr/bin/touch")
else
  UNAME_MACHINE="$(uname -m)"
  STAT_PRINTF=("stat" "--printf")
  PERMISSION_FORMAT="%a"
  CHOWN=("/bin/chown")
  CHGRP=("/bin/chgrp")
  GROUP="$(id -gn)"
  TOUCH=("/bin/touch")
fi
CHMOD=("/bin/chmod")
MKDIR=("/bin/mkdir" "-p")

# Line 0166
# TODO: bump version when new macOS is released or announced
MACOS_NEWEST_UNSUPPORTED="13.0"
# TODO: bump version when new macOS is released
MACOS_OLDEST_SUPPORTED="10.15"

# Line 0181
unset HAVE_SUDO_ACCESS # unset this from the environment

have_sudo_access() {
  if [[ ! -x "/usr/bin/sudo" ]]
  then
    return 1
  fi

  local -a SUDO=("/usr/bin/sudo")
  if [[ -n "${SUDO_ASKPASS-}" ]]
  then
    SUDO+=("-A")
  elif [[ -n "${NONINTERACTIVE-}" ]]
  then
    SUDO+=("-n")
  fi

  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]
  then
    if [[ -n "${NONINTERACTIVE-}" ]]
    then
      "${SUDO[@]}" -l mkdir &>/dev/null
    else
      "${SUDO[@]}" -v && "${SUDO[@]}" -l mkdir &>/dev/null
    fi
    HAVE_SUDO_ACCESS="$?"
  fi

  if [[ -z "${HOMEBREW_ON_LINUX-}" ]] && [[ "${HAVE_SUDO_ACCESS}" -ne 0 ]]
  then
    abort "Need sudo access on macOS (e.g. the user ${USER} needs to be an Administrator)!"
  fi

  return "${HAVE_SUDO_ACCESS}"
}

execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

execute_sudo() {
  local -a args=("$@")
  if have_sudo_access
  then
    if [[ -n "${SUDO_ASKPASS-}" ]]
    then
      args=("-A" "${args[@]}")
    fi
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}

getc() {
  local save_state
  save_state="$(/bin/stty -g)"
  /bin/stty raw -echo
  IFS='' read -r -n 1 -d '' "$@"
  /bin/stty "${save_state}"
}

ring_bell() {
  # Use the shell's audible bell.
  if [[ -t 1 ]]
  then
    printf "\a"
  fi
}

wait_for_user() {
  local c
  echo
  echo "Press ${tty_bold}RETURN${tty_reset} to continue or any other key to abort:"
  getc c
  # we test for \r and \n because some stuff does \r instead
  if ! [[ "${c}" == $'\r' || "${c}" == $'\n' ]]
  then
    exit 1
  fi
}

major_minor() {
  echo "${1%%.*}.$(
    x="${1#*.}"
    echo "${x%%.*}"
  )"
}

version_gt() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -gt "${2#*.}" ]]
}
version_ge() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -ge "${2#*.}" ]]
}
version_lt() {
  [[ "${1%.*}" -lt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -lt "${2#*.}" ]]
}

# Line 0285
should_install_command_line_tools() {
  if [[ -n "${HOMEBREW_ON_LINUX-}" ]]
  then
    return 1
  fi

  if version_gt "${macos_version}" "10.13"
  then
    ! [[ -e "/Library/Developer/CommandLineTools/usr/bin/git" ]]
  else
    ! [[ -e "/Library/Developer/CommandLineTools/usr/bin/git" ]] ||
      ! [[ -e "/usr/include/iconv.h" ]]
  fi
}

# Line 0412
# USER isn't always set so provide a fall back for the installer and subprocesses.
if [[ -z "${USER-}" ]]
then
  USER="$(chomp "$(id -un)")"
  export USER
fi

# Line 0489
# shellcheck disable=SC2016
ohai 'Checking for `sudo` access (which may request your password)...'
have_sudo_access

# Line 0576
if [[ -z "${HOMEBREW_ON_LINUX-}" ]]
then
  macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"
  if version_lt "${macos_version}" "10.7"
  then
    abort "$(
      cat <<EOABORT
Your Mac OS X version is too old. See:
  ${tty_underline}https://github.com/mistydemeo/tigerbrew${tty_reset}
EOABORT
    )"
  elif version_lt "${macos_version}" "10.10"
  then
    abort "Your OS X version is too old."
  elif version_ge "${macos_version}" "${MACOS_NEWEST_UNSUPPORTED}" ||
       version_lt "${macos_version}" "${MACOS_OLDEST_SUPPORTED}"
  then
    who="We"
    what=""
    if version_ge "${macos_version}" "${MACOS_NEWEST_UNSUPPORTED}"
    then
      what="pre-release version"
    else
      who+=" (and Apple)"
      what="old version"
    fi
    ohai "You are using macOS ${macos_version}."
    ohai "${who} do not provide support for this ${what}."

    echo "$(
      cat <<EOS
This installation may not succeed.
After installation, you will encounter build failures with some formulae.
Please create pull requests instead of asking f\or help on Homebrew\'s GitHub,
Twitter or any other official channels. You are responsible f\or resolving any
issues you experience w\hile you are running this ${what}.
EOS
    )
" | tr -d "\\"
  fi
fi

# Line 0739
if should_install_command_line_tools
then
  ohai "The Xcode Command Line Tools will be installed."
fi

# ~~ Shurroo ~~ BEGIN
if should_install_command_line_tools
then
  # Save our first answer
  INSTALL_COMMAND_LINE_TOOLS=1
fi
USER_HOME=$(printf "%s" ~)
DOT_SHURROO="${USER_HOME}""/.shurroo"
SHURROO_REPO="${DOT_SHURROO}""/shurroo"
SHURROO_GIT="${SHURROO_REPO}""/.git"
SHURROO_GIT_REMOTE="https://github.com/shurroo/shurroo"

should_install_shurroo() {
  ! [[ -d "${SHURROO_GIT}" ]]
}

if should_install_shurroo
then
  ohai "The Shurroo repository will be installed."
else
  ohai "The Shurroo repository will be upgraded."
fi

wait_for_user
# ~~ Shurroo ~~ END

# Line 0844
if should_install_command_line_tools && version_ge "${macos_version}" "10.13"
then
  ohai "Searching online for the Command Line Tools"
  # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
  clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  execute_sudo "${TOUCH[@]}" "${clt_placeholder}"

  clt_label_command="/usr/sbin/softwareupdate -l |
                      grep -B 1 -E 'Command Line Tools' |
                      awk -F'*' '/^ *\\*/ {print \$2}' |
                      sed -e 's/^ *Label: //' -e 's/^ *//' |
                      sort -V |
                      tail -n1"
  clt_label="$(chomp "$(/bin/bash -c "${clt_label_command}")")"

  if [[ -n "${clt_label}" ]]
  then
    ohai "Installing ${clt_label}"
    execute_sudo "/usr/sbin/softwareupdate" "-i" "${clt_label}"
    execute_sudo "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools"
  fi
  execute_sudo "/bin/rm" "-f" "${clt_placeholder}"
fi

# Headless install may have failed, so fallback to original 'xcode-select' method
if should_install_command_line_tools && test -t 0
then
  ohai "Installing the Command Line Tools (expect a GUI popup):"
  execute_sudo "/usr/bin/xcode-select" "--install"
  echo "Press any key when the installation has completed."
  getc
  execute_sudo "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools"
fi

if [[ -z "${HOMEBREW_ON_LINUX-}" ]] && ! output="$(/usr/bin/xcrun clang 2>&1)" && [[ "${output}" == *"license"* ]]
then
  abort "$(
    cat <<EOABORT
You have not agreed to the Xcode license.
Before running the installer again please agree to the license by opening
Xcode.app or running:
    sudo xcodebuild -license
EOABORT
  )"
fi

# ~~ Shurroo ~~ BEGIN
if [[ -n "${INSTALL_COMMAND_LINE_TOOLS-}" ]]
then
  ohai "Command Line Tools installation successful."
fi

# We always want to install shurroo, unless we have a valid git repo.
# If .git exists, but is not a valid git repo, remove it and install again.
INSTALL_SHURROO=1;

if [[ -d "${SHURROO_GIT}" ]]
then
  cd "${SHURROO_REPO}" >/dev/null
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1
  then
    unset INSTALL_SHURROO
  else
    ohai "Repairing the Shurroo repository - your password may be necessary"
    execute_sudo "rm" "-rf" ".git"
  fi
fi

if [[ -n "${INSTALL_SHURROO-}" ]]
then
  ohai "Installing the Shurroo repository"
else
  ohai "Upgrading the Shurroo repository"
fi

if [[ -n "${INSTALL_SHURROO-}" ]]
then
  cd "${USER_HOME}" >/dev/null
  execute "${MKDIR[@]}" "${SHURROO_REPO}"
  cd "${SHURROO_REPO}" >/dev/null
  # Do this in stages, like Homebrew install script: initialise first
  execute "git" "init" "-q"
else
  cd "${SHURROO_REPO}" >/dev/null
fi

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

if [[ -n "${INSTALL_SHURROO-}" ]]
then
  ohai "Shurroo repository installation successful!"
else
  ohai "Shurroo repository upgrade successful!"
fi
# ~~ Shurroo ~~ END


# END
