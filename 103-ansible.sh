# Component of Shurroo https://github.com/shurroo/shurroo

# Installs Ansible and collects the required roles
# Applicable versions:
#   - 12.x Monterey

printf "Installing Ansible\n"
brew install ansible
cd ~/.shurroo
if [[ -f "/Volumes/Shurroo/requirements.yml" ]]
then
  printf "Installing Ansible roles from custom requirements file\n"
  ansible-galaxy install -f -r /Volumes/Shurroo/requirements.yml
else
  printf "Installing Ansible roles from Shurroo default requirements file\n"
  ansible-galaxy install -f -r requirements.yml
fi

# No '[' or 'test' needed because we are using the return code of the check
if ls -1qA ~/.shurroo/shurroo/modules/ | grep -q \.py
then
  printf "Installing Ansible modules\n"
  mkdir -p ~/.ansible/plugins/modules/
  cp ~/.shurroo/shurroo/modules/*.py ~/.ansible/plugins/modules/
fi

# END

# More detail

# Brew creates a virtual environment and installs the dependent packages, including Python, to the environment.
# Actual package versions will depend on the Ansible version current at the time of install
# System packages
#   - ca-certificates
#   - gdbm
#   - libyaml
#   - mpdecimal
#   - openssl@1.1
#   - readline
#   - sqlite
#   - xz
# Python and pip
#   - python@3.10
#   - six
# It's tempting to install each of these packages with brew, because we need them generally available.
# However, installing Ansible with a virtual environment means we can cleanly install our Python environments
# later. It also links the ansible binaries into the path.

# These are the packages we would need to install:
#   - brew install ca-certificates
#   - brew install gdbm
#   - brew install libyaml
#   - brew install mpdecimal
#   - brew install openssl@1.1
#   - brew install readline
#   - brew install sqlite
#   - brew install xz

# Then install Python, upgrade pip, and install six and ansible:
#   - brew install python@3.10
#   - /usr/local/opt/python@3.10/bin/pip3 install --upgrade pip
#   - /usr/local/opt/python@3.10/bin/pip3 install six
#   - /usr/local/opt/python@3.10/bin/pip3 install ansible
