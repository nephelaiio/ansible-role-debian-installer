# nephelaiio.debian-installer

[![Build Status](https://github.com/nephelaiio/ansible-role-debian-installer/workflows/molecule/badge.svg)](https://github.com/nephelaiio/ansible-role-debian-installer/actions)
[![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-nephelaiio.debian-installer-blue.svg)](https://galaxy.ansible.com/nephelaiio/debian-installer/)

An [ansible role](https://galaxy.ansible.com/nephelaiio/debian-installer) to generate unattended installation isos for Debian Linux.

## Role Variables

Please refer to the [defaults file](/defaults/main.yml) for a full list of input parameters.

## Example Playbook

The following example will create an unattended iso for deploying vm.nephelai.io with Debian Bookwork (Debian 12) pulled from cdimage.debian.org (default)

```
- hosts: localhost
  roles:
     - role: nephelaiio.debian_installer
  vars:
    debian_installer_hostname: vm.nephelai.io
    debian_installer_interface:
      static: true
      ipaddress: 10.40.0.22
      netmask: 255.255.255.0
      gateway: 10.40.0.254
      nameservers: 8.8.8.8 8.8.4.4
```

Images are tested by provisioning kvm guests on github actions large runners

## Testing

Role is tested from an Ansible controller running Ubuntu LTS. Target iso flavors are:
  * Debian 12

You can test the role directly from sources using command ` molecule test `. Note that this will reconfigure networking for network 192.168.255.0/24 which will be directly connected to a local bridge interface

## License

This project is licensed under the terms of the [MIT License](/LICENSE)
