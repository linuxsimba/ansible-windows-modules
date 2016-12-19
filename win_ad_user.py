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
module: win_ad_user
version_added: "2.0"
short_description: Add AD User
description:
     - Adds AD User .
options:
  name:
    description: Users name
    required: yes
  fullname:
    description: User Full name
    required: yes
  password:
    description: Clear Text password.
    required: yes
  state:
    description: if present then a user is created. absent, delete the user
    choices: ['present', 'absent']
    default: 'present'
  path:
    description:  Object where users will be installed.
author: Stanley Karunditu(stanley@linuxsimba.com)
'''

EXAMPLES = '''
#  Add Active Directory User
$ ansible -i hosts -m win_ad_user -a "name=myname fullname='My Name' password='mypass'" windows
'''
