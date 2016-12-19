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

$domain = $false
$workgroup = $false
$creds = $false

$params = Parse-Args $args;

$result = New-Object psobject;
Set-Attr $result "changed" $false;

$hostname = Get-Attr $params "name" -failifempty $true
$restart = Get-Attr $params "restart" $FALSE

$currentname = [System.Net.Dns]::GetHostByName(($env:computerName))|FL HostName | Out-String | %{ "{0}" -f $_.Split(":")[1].Trim() };

# Delete the domain name stuff if this is an ad server
# Example: ad.example.local, only print 'ad'
$currentname = $currentname.split('.')[0]

Set-Attr $result "currentname" $currentname
Set-Attr $result "desiredname" $hostname

If ($currentname -eq $hostname) {
   Set-Attr $result "msg" "Desired Hostname $hostname is the same as the current hostname"
}
Else
{
  if ($restart) {
    Rename-Computer -NewName $hostname
    Restart-Computer -Force
    Set-Attr $result "msg" "Changed hostname to $hostname. Restarting the Host"
    $result.changed = $TRUE
  }
  else
  {
    Rename-Computer -NewName $hostname
    Set-Attr $result "msg" "Changed hostname to $hostname. Make sure to restart to effect the change"
    $result.changed = $TRUE
  }
}

Exit-Json $result
