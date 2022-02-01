# Component of Shurroo https://github.com/shurroo/shurroo

# Uninstalls macOS Homebrew package manager
# Applicable versions:
#   - 12.x Monterey

printf "Uninstalling Homebrew\n"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# These folders apply to Intel Macs only
# We are not yet handling Apple Silicon Macs
printf "Removing Homebrew folders - your password may be necessary\n"
sudo rm -rf /usr/local/Homebrew/
sudo rm -rf /usr/local/etc/
sudo rm -rf /usr/local/share/
sudo rm -rf /usr/local/var/
