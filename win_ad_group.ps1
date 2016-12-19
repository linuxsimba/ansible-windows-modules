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

# Create OU based on a path
# Example CreateOU("OU=blah, dc=example, dc=com")
# will create the OU=blah in the dc=example,dc=com directory space
# To do it does not check that the DC components exist.
function CreateOU($path) {
  $ua = $path.split(',')
  $searchpath = ""
  $ou = ""
  $searchlength = $ua.length
  for ($i=$searchlength-1; $i -ge 0; $i--) {
    $entry = $ua[$i]
    if ($i -eq ($searchlength-1)) {
      $ou = $entry
    } elseif ($entry -like "dc=*") {
       $ou = $entry + "," + $ou
    } else {
      $newou = $entry + "," + $ou
      $foundou = get-adobject -filter { (distinguishedname -eq  $newou) }
      if (! $foundou) {
        $ouname = $entry.split('=')
        if ($ouname[0].ToLower() -ne 'ou') {
          Fail-Json $result "Path name can only contain OU - $newou"
          return
        }
        new-ADOrganizationalUnit -name $ouname[1] -path $ou
      }
      $ou = $newou
    }
  }

}

$params = Parse-Args $args;

$result = New-Object psobject;
Set-Attr $result "changed" $false;
Set-Attr $result "msg" "";

$groupname = Get-Attr $params "name" -failifempty $true

$state = Get-Attr $params "state" "present"
$state = $state.ToString().ToLower()
if (($state -ne "present") -and ($state -ne "absent")) {
      Fail-Json $result "state is '$state'; must be 'present' or 'absent'"
}

# check if AD is active
try {
  $domain = get-addomain
} catch {
  $errormsg = $_.Exception.Message
  Fail-Json $result "AD Domain not active: $errormsg"
}

$defaultpath = "CN=Users,$domain"
$path = Get-Attr $params "path" $defaultpath
# Check if the path exists. If it does not exist, create it
$group_ou = get-adobject -filter { (distinguishedname -eq  $path) }
if (! $group_ou) {
  CreateOU($path)
}

# Check if Group exists exists
$foundgroup = get-adgroup -filter {(name -eq $groupname)}
if ($state -eq 'present') {
  if ($foundgroup) {
    $result.msg = "Group '$groupname' exists."
  } else {
    new-adgroup -name $groupname -groupscope 1 -path $path
    $result.changed = $true
    $result.msg = "Created group $groupname"
  }
} else {
  if ($foundgroup) {
    $foundgroup | remove-adgroup -confirm:$false
    $result.changed = $true
    $result.msg = "Deleted group $groupname"
  } else {
    $result.msg = "Group $groupname is deleted"
  }
}
Exit-Json $result
