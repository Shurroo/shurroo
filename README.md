Shurroo Project
---------------

Motivation
----------
For reasons of security and transparency, we wanted a Mac setup workflow that was fully open source and standalone, with no dependencies on opaque device provisioning systems.

The project was originally inspired from the Superlumic project (see "Project Name" below) but although the Superlumic principles of simplicity matched our own, our project needs diverged from the minimal approach of the Superlumic project. In particular, we wanted:

* Ability to start with "bare metal"
* Improved error handling, especially for new macOS releases
* Simplified, single-layer user configuration
* Tighter coupling between app install and associated user config items
* Greater clarity and transparency of dependencies and defaults
* Ability to apply app settings into plist (Apple property list) files
* Simple syntax for enhanced memorisation and recall
* Minimise manual post-flight steps

Implementation
--------------
We retained the simplicity of "shell scripts, Ansible and nothing else" from Superlumic. We removed the multi-tier user configuration, and instead of a single "user config" file, we split the configuration into parts tied to roles. The "bare metal" requirement was problematic, since "package1" requires "package2" to run, but "package2" requires "package1" to install. Homebrew has the same problem, so we shamelessly borrowed relevant parts of the Homebrew [install](https://brew.sh/) script, on the grounds that it is a proven pattern and also includes extensive error checking, which is vital for the foundational bare metal phase. Having a separate  `install` script overcame the bare metal package deadlock issues. 

Installation Phase
------------------
The `install` script overcomes the problems associate with a bare metal machine, that is, a brand-new Mac with freshly-installed macOS, with nothing installed. It follows the same pattern as the Homebrew [install](https://brew.sh/) script.

```shell
/bin/bash -c "$(curl -fsSL https://https://raw.githubusercontent.com/Shurroo/install/master/install.sh)"
```


Bootstrap Phase
---------------
This part remains a work in progress. It may be merged into the `install` script.
Once this Shurroo repository is installed, run the following bootstrap scripts in sequence:
```shell
~/.shurroo/shurroo/102-homebrew.sh
~/.shurroo/shurroo/103-ansible.sh
~/.shurroo/shurroo/104-meslo-lg-nerd-font.sh
```

In a future release, these will be combined into a single script, with error checking added.

For now, just run the scripts in sequence:
* 1xx scripts perform installations
* 3xx scripts perform testing
* 5xx scripts perform removals

Note that `101-command-line-tools.sh` is no longer required, because the `install` script installs the command line tools (CLT). It will be removed in a later release.

Usage Phase
-----------
Once the bootstrap scripts have been run, Ansible roles may be run in any order, for example:
```shell
shurroo play zsh
shurroo play git
shurroo play iterm2
```

If you need to update the Shurroo repository, run
```shell
shurroo update
```

If you need to update the roles, run
```shell
shurroo roles
```

To see the most recent log file for a role, run
```shell
shurroo log git
```


Project Name
------------

The project was originally inspired from the [Superlumic](https://github.com/superlumic/superlumic) project by [Roderik van der Veer](https://github.com/roderik). When I started on a replacement, I searched for a name with some meaning like "launch", "fire up", "bootstrap" or similar. I eventually settled on Hindi "shurroo" (शुरू). [Google Translate](https://translate.google.com/?sl=en&tl=hi&text=begin&op=translate) tells me "shurroo" means "begin", so this works nicely. Note that the official latin spelling has only one "r", but that name was already taken on GitHub, so I added a second "r".

License
-------

[BSD-3-Clause](https://spdx.org/licenses/BSD-3-Clause.html)

Author Information
------------------

Ian Taylor ([IanTaylorFB](https://github.com/IanTaylorFB)), Co-Founder and CTO at [FlyingBinary Ltd](https://flyingbinary.com).
