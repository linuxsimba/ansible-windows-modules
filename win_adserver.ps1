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

$domainname = Get-Attr $params "domain_name" -failifempty $true
$domainmode = Get-Attr $params "domain_mode" "Win2012R2"
$netbiosname = Get-Attr $params "netbios_name" -failifempty $true
$safemodepasswd = Get-Attr $params "safemode_passwd" -failifempty $true
$forestmode = Get-Attr $params "forest_mode" "WIN2012R2"

# check if AD feature is enabled
$adfeature = get-windowsfeature -name AD*
if ([string]::IsNullorEmpty($adfeature)) {
  Fail-Json $result "AD Feature is not installed. Use win_feature using the name 'ad-domain-services' to get it installed"
}

# First check if domain is created
try {
  $domain = Get-ADDomain
  $domainroot = $domain.dnsroot
  Set-Attr $result "msg" "Domain Exists. Domain Root is $domainroot"
  Exit-Json $result
}
Catch
{
  try {
   Import-Module ADDSDeployment
   Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "$domainmode" `
        -DomainName "$domainname" `
        -DomainNetbiosName "$netbiosname" `
        -ForestMode "$forestmode" `
        -InstallDns:$true `
        -safemodeadministratorpassword (convertto-securestring $safemodepasswd -asplaintext -force) `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$false `
        -SysvolPath "C:\Windows\SYSVOL" `
        -Force:$true
    $result.changed = $true
    Set-Attr $result "msg" "New Domain Created. Domain Root is $domainname"

  }
  Catch
  {
    Fail-Json $result $_.Exception.Message
  }
}
Exit-Json $result
