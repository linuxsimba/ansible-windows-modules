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
module: win_ad_group_membership
version_added: "2.0"
short_description: Add AD Group Membership
description:
  - Add AD Group Membership
options:
  group:
    description: name of the group to add to
    required: yes
  member:
    description: name of the group or user to the group mentioned in the group attribute
    required: yes
  state:
    description: if present then add the membership. if absent the delete the membership
    choices: ['present', 'absent']
    default: 'present'

author: Stanley Karunditu(stanley@linuxsimba.com)
'''

EXAMPLES = '''
# Add Group
$ ansible -i hosts -m win_ad_group_membership -a "group=mastergroup member=user1" windows
'''
