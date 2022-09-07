# Role execution is in three parts:

  - The `shurroo` script looks for a `yml` playbook
  - If no custom playbook is found, the default playbook is used
  - The playbook runs the Ansible role

The examples in this document assume we are running a `git` role and playbook.

# Shurroo script usage

Play the `git` role with Shurroo with the following command:
```shell
shurroo play git
```

The `shurroo` script will look for a custom playbook first, then the default playbook, and then exit with an error. The custom location is on any volume mounted at `/Volumes/Shurroo/`. This can be a local disk image, or a flash drive. The Shurroo volume will usually contain user details, credentials or other sensitive information, so should be properly secured at all times. 

The locations searched are:

**Custom Playbook** in `/Volumes/Shurroo/git/git.yml`

**Default Playbook** in `~/.shurroo/git.yml`

If `git.yml` is not found in either of these locations, the script exits with an error. If you expect the default role to be present, you can install all the roles again with `shurroo roles`.

# Example playbook for git
Here is an example playbook for the `git` role:
```yaml
- hosts: localhost
  connection: local
  roles:
    - role: Shurroo.git
      git_user_name: Groot
      git_user_email: groot@galaxyguardians.org
  vars:
    write_log_file: false
    overwrite_gitconfig: false
    overwrite_private_key: false
```

The default playbook contains no user details. If required, user details must be added to a custom playbook.

# Ansible role
We expect the Ansible role to be in the Shurroo `roles` directory, at `~/.shurroo/roles`. If you are expecting a role, but it appears to be missing, you can reinstall all roles with `shurroo roles`.

You can also override the default `requirements.yml` by including a custom file in the Shurroo volume, at `/Volumes/Shurroo/requirements.yml`. This allows you to specify additional roles that are not included in the default Shurroo repository.

All custom roles installed will also require a custom playbook in the Shurroo volume, as described above in the `git` example. They will then be discovered simply by using `shurroo play [ custom_role ]`.
