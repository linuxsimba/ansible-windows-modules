#!powershell
#
# Copyright 2016, Stanley Karunditu <stanley@linuxsimba.com>
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

# WANT_JSON
# POWERSHELL_COMMON

$params = Parse-Args $args;

$result = New-Object psobject;
Set-Attr $result "changed" $false;


$current_dhcp_int = Get-NetIPAddress | Where-Object {$_.Prefixorigin -eq 'Dhcp'}

if ($current_dhcp_int){
  $result.changed = $TRUE
  $defaultgw = get-netroute -destinationprefix "0.0.0.0/0"
  $nexthop = $defaultgw.nexthop
  $ipaddr = $current_dhcp_int.ipv4address
  $ipprefix = $current_dhcp_int.prefixlength
  $intindex = $current_dhcp_int.interfaceindex
  $intalias = $current_dhcp_int.interfacealias

  $netadapter = Get-NetAdapter -Name $intalias
  $netadapter |Set-NetIPInterface -DHCP Disabled
  $netadapter | New-NetIPAddress -IPAddress $ipaddr -PrefixLength $ipprefix -DefaultGateway $nexthop
  Set-Attr $result "msg" "Hard Coding DHCP Address to IP: $ipaddr / $ipprefix. Gateway $nexthop. Restart PC for change to take effect"

} else {
  Set-Attr $result "msg" "No DHCP Address Found"
}

Exit-Json $result
