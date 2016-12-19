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



function GroupMembership ($member, $groupname) {
  # Check if the $member is a user or group
  # If not fail.
  $membertype = 'user'
  # Check if the member exists
  $memberisuser = get-aduser -filter {(name -eq $member)}
  if ($memberisuser -eq $null) {
    $membertype = 'group'
    $memberisgroup = get-adgroup -filter {(name -eq $member)}
    if ( $memberisgroup -eq $null ) {
      Fail-Json $result "member $member is not a user or group"
    }
  }

  # Check if Group to add the member to exists. If it does
  # not exist then fail.
  $foundgroup = get-adgroup -filter {(name -eq $groupname)}

  if ($foundgroup) {
    $groupname = $foundgroup.name
  } else {
    Fail-Json $result "Group $groupname.name does not exist. Cannot proceed with group membership"
  }

  $gmembers = Get-AdGroupMember -Identity "$groupname" | Select -ExpandProperty Name

  Set-Attr $result "group-members" $gmembers

  if ($state -eq 'present') {
    # If the state is present and the member is in the group
    # no change. otherwise add the member to the group and
    # change the $result.changed var.
    if ($gmembers -contains $member) {
      $result.msg = "Member $member already exist in Group $groupname"
    } else {
      Add-ADGroupMember "$groupname" "$member"
      $result.msg = "$membertype $member added to group $groupname"
      $result.changed = $true
    }

  } else {

    if ($gmembers -contains $member){
      Remove-ADGroupMember "$groupname" "$member" -confirm:$false
      $result.changed = $true
      $result.msg = "Removed $member from Group $groupname"
    } else {
      $result.msg = "Member $member is already deleted from Group $groupname"
    }
  }

}


$params = Parse-Args $args;

$result = New-Object psobject;
Set-Attr $result "changed" $false;
Set-Attr $result "msg" "";

$groupname = Get-Attr $params "group" -failifempty $true
$members = Get-Attr $params "members" -failifempty $true
if ($members -is [System.String]) {
  [string[]]$members = $members.Split(",")
} elseif ($members -isnot [System.Collections.IList]) {
  Fail-Json $result "members must be a string or array"
}

$state = Get-Attr $params "state" "present"
$state = $state.ToString().ToLower()
If (($state -ne "present") -and ($state -ne "absent")) {
      Fail-Json $result "state is '$state'; must be 'present' or 'absent'"
}
# check if AD is active
try {
  $domain = get-addomain
} catch {
  $errormsg = $_.Exception.Message
  Fail-Json $result "AD Domain not active: $errormsg"
}

$members = $members | ForEach { ([string]$_).Trim() } |  Where { $_ }
foreach ($member in $members) {
  GroupMembership -member $member -groupname $groupname
}
Exit-Json $result;
