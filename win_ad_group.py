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
module: win_ad_group
version_added: "2.0"
short_description: Add AD Group
description:
     - Adds AD Group.
options:
  name:
    description: Group name
    required: yes
  state:
    description: create a new group if state is present. absent state, delete the group
    choices: ['absent', 'present']
    default: 'present'
author: Stanley Karunditu(stanley@linuxsimba.com)
'''

EXAMPLES = '''
# Add Group
$ ansible -i hosts -m win_ad_group -a "name=mygroup" windows
'''
