# Component of Shurroo https://github.com/shurroo/shurroo

# Tests installation of Ansible and key dependencies
# Applicable versions:
#   - 12.x Monterey

printf "Checking Ansible status\n"
ansible --version


# END

# More detail

# We could also check the Python version, but we need to extract the Ansible Python module location
# from the Ansible version information.

# This is a hardcoded example:
#   - printf "Checking Python status\n"
#   - /usr/local/Cellar/ansible/5.2.0/libexec/bin/python --version
