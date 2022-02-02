# Component of Shurroo https://github.com/shurroo/shurroo

# Tests installation of Meslo LG Nerd Font
# Applicable versions:
#   - 12.x Monterey

printf "Checking Meslo LG Nerd Font status\n"
system_profiler SPFontsDataType | grep "Meslo LG S Regular Nerd Font Complete Mono.ttf"


# END

# More detail

# We can't display the special characters in the terminal until we configure the font into the program.
# So we just list the entry in the Font Book.
