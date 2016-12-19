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
Set-Attr $result "msg" "";

$hostname = Get-Attr $params "hostname" -failifempty $true
$zone = Get-Attr $params "zone" -failifempty $true
$ipaddr = Get-Attr $params "ipaddr" -failifempty $true

$state = Get-Attr $params "state" "present"
$state = $state.ToString().ToLower()
If (($state -ne "present") -and ($state -ne "absent")) {
      Fail-Json $result "state is '$state'; must be 'present' or 'absent'"
}

# Check if DNS is covered
try {
  $domain = get-addomain
} catch {
  $errormsg = $_.Exception.Message
  Fail-Json $result "AD Domain not active: $errormsg"
}


$dnsresult = get-dnsserverresourcerecord -zonename $zone -name $hostname
if ($state -eq 'present') {
  if ($dnsresult) {
    Set-Attr $result "dnsresult" $dnsresult
    $result.msg = "DNS entry exists"
  } else {
    add-dnsserverresourcerecordA -name "$hostname"  `
        -zonename "$zone" -allowupdateany  `
        -ipv4address "$ipaddr" `
        -timetolive 01:00:00
    $result.changed = $true
    $result.msg = "Added DNS A Record: $ipaddr to $hostname"
  }
} else {
  if ($dnsresult) {
    get-dnsserverresourcerecord -zonename $zone -name $hostname
    Remove-DnsServerResourceRecord -zonename $zone -RRType "A" -Name $hostname
    $result.changed = $true
    $result.msg = "Removed DNS A Record: $ipaddr to $hostname"
  } else {
    $result.msg = "DNS A Record Already Removed: $hostname -> $ipaddr"
  }
}

Exit-Json $result
