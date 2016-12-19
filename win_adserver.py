#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2016, Stanley Karunditu <stanley@linuxsimba.com>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

DOCUMENTATION = '''
---
module: win_adserver
version_added: "2.0"
short_description: Install AD Server
description:
     - |
        Adds idempotent behaviour around the Install-ADDSForest command.
options:
  domain_name:
    description: Domain Name
    required: yes
  netbios_name:
    description: Netbios Name
    required: yes
  safemode_passwd:
    description: Safe mode password. Right now only accepts cleartext. In the future it will allow for  encrypted only
    required: yes
  forest_mode:
      description: Not sure what this does
      defaults: "Win2012R2"
  domain_mode:
      description: Not sure what this does
      defaults: "Win2012R2"

author: Stanley Karunditu(stanley@linuxsimba.com)
'''

EXAMPLES = '''
# Install AD .
$ ansible -i hosts -m win_adserver -a "domain_name=example.local netbios_name=EXAMPLE safemode_passwd='blah'"  windows
'''
