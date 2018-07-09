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
module: win_hostname
version_added: "2.0"
short_description: Hostname setting
description:
     - |
        Change a window server hostname, before it is bound to Active directory.
        The module is inspired by a more comprehensive solution called
        win_host by github.com/schwartzmx.
        His module failed to work on this setup. Long term should fix his module
        and just use that. This is a workaround for now.
options:
  name:
    description: desired computer name
    required: yes
author: Stanley Karunditu(stanley@linuxsimba.com)
'''

EXAMPLES = '''
# Change Hostname
$ ansible -i hosts -m win_host -a "name=MyNewComp"
'''
