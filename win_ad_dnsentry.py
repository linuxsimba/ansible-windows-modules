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
module: win_ad_dnsentry
version_added: "2.0"
short_description: Manages DNS A Record on Windows DNS Server
description:
     - Manages DNS A Record on MS DNS Server
options:
  hostname:
    description:  Hostname to use in the DNS A Record
    required: yes
  zone:
    description:  DNS Zone. otherwise known as the domain name
    required: yes
  state:
    description: if present then a DNS record is created. If deleted the DNS record is deleted
    choices: ['present', 'absent']
    default: 'present'
author: Stanley Karunditu(stanley@linuxsimba.com)
'''

EXAMPLES = '''
#  Add DNS A Record
$ ansible -i hosts -m win_ad_dnsentry -a "hostname=myhost zone='example.local'" windows
'''
