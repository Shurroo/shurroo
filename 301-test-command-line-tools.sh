# Component of Shurroo https://github.com/shurroo/shurroo

# Tests installation of macOS Command Line Tools
# Applicable versions:
#   - 12.x Monterey

printf "Fetching package information\n"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
pkgutil --pkg-info=com.apple.pkg.CLTools_macOS_SDK
pkgutil --pkg-info=com.apple.pkg.CLTools_SDK_macOS110
pkgutil --pkg-info=com.apple.pkg.CLTools_SDK_macOS12
