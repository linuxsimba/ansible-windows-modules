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

$username = Get-Attr $params "name" -failifempty $true

# Configure the state attribute. Default is "present"
# Check that only "present" and "absent" are allowed
$state = Get-Attr $params "state" "present"
$state = $state.ToString().ToLower()
If (($state -ne "present") -and ($state -ne "absent")) {
      Fail-Json $result "state is '$state'; must be 'present' or 'absent'"
}

# Only care about the full name if the user needs to be created
if ($state -eq 'present') {
  $fullname = Get-Attr $params "fullname" -failifempty $true
}
$domain = ""
# Check if AD Domain exists
try {
  $domain = get-addomain
} catch {
  $errormsg = $_.Exception.Message
  Fail-Json $result "AD Domain not active: $errormsg"
}


$defaultpath = "CN=Users,$domain"
$path = Get-Attr $params "path" $defaultpath
# Check if the path exists. If it does not, create it.
$user_ou = get-adobject -filter { (distinguishedname -eq  $path) }
if (! $user_ou) {
  CreateOU($path)
}

$founduser = get-aduser -filter {(name -eq $username)}
if ($state -eq 'present') {
  # From stackoverflow
  # http://stackoverflow.com/questions/26274361/powershell-new-aduser-error-handling-password-complexity-activedirectory-module
  #
  $ExistingEAP = $ErrorActionPreference
  $ErrorActionPreference = "Stop"
  $password = Get-Attr $params "password" -failifempty $true
  # Check if Username exists
  try {
    if ($founduser) {
      $result.msg = "User '$username' exists."
    } else {
      $domainname = $domain.dnsroot
      $newacct = new-aduser -displayname "$fullname" `
        -name "$username" `
        -userprincipalname "$username@$domainname" `
        -path $path `
        -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
        -ErrorAction Stop `
        -PasswordNeverExpires:$true -passthru
      $newacct | Enable-ADAccount
      $result.changed = $true
      $result.msg = "Created User $username"
    }
  } catch {
      $errormsg = $_.Exception.Message
      $newuser = get-aduser -filter { (name -eq $username) }
      if ($newuser) {
          $newuser | remove-aduser -confirm:$false
      }
      Fail-Json $result "Failed to add user $username $errormsg"
  }
  $ErrorActionPreference = $ExistingEAP
} else {
  if ($founduser) {
    $founduser | remove-aduser -confirm:$false
    $result.changed = $true
    $result.msg = "User deleted $username"
  } else {
    $result.msg = "User is already deleted"
  }
}

Exit-Json $result
