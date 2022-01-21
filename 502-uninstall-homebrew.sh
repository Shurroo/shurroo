# Component of Shurroo https://github.com/shurroo/shurroo

# Uninstalls macOS Homebrew package manager
# Applicable versions:
#   - 12.x Monterey

printf "Uninstalling Homebrew\n"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
