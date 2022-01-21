# Component of Shurroo https://github.com/shurroo/shurroo

# Uninstalls macOS Command Line Tools
# Applicable versions:
#   - 12.x Monterey

printf "Moving package receipts"
sudo mv /Library/Apple/System/Library/Receipts/com.apple.pkg.CLTools* /var/db/receipts/

printf "Removing installed tools"
sudo rm -rf /Library/Developer

printf "Forgetting packages"
sudo pkgutil --forget=com.apple.pkg.CLTools_Executables
sudo pkgutil --forget=com.apple.pkg.CLTools_macOS_SDK
sudo pkgutil --forget=com.apple.pkg.CLTools_SDK_macOS110
sudo pkgutil --forget=com.apple.pkg.CLTools_SDK_macOS12

printf "Resetting software update list"
softwareupdate --list

printf "Checking packages are removed"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
pkgutil --pkg-info=com.apple.pkg.CLTools_macOS_SDK
pkgutil --pkg-info=com.apple.pkg.CLTools_SDK_macOS110
pkgutil --pkg-info=com.apple.pkg.CLTools_SDK_macOS12
