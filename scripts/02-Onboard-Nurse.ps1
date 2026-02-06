# =============================================================================
# 02-Onboard-Nurse.ps1
# Liberty Bell Hospital - Automate New ER Nurse Onboarding
# Creates AD user account, sets password policy, assigns to OU and groups
# =============================================================================

# --- Define variables for the new user ---
$FirstName = "Delilah"
$LastName = "Johnson"
$Username = "$FirstName$LastName"
$Password = "Z3br4!#0t" | ConvertTo-SecureString -AsPlainText -Force
$OU = "OU=ERNurses,OU=LibertyBellGroupHospital,DC=libertybellmedicalgroup,DC=local"
$Group = "NewEmployeeGroup"
$HomeDrivePath = "\\FileServer\Home\$Username"

# --- Create the new user in Active Directory ---
New-ADUser -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $Username `
    -UserPrincipalName "$Username@libertybellmedicalgroup.local" `
    -Path $OU `
    -AccountPassword $Password `
    -Enabled $true `
    -ChangePasswordAtLogon $true

Write-Host "User $Username created successfully in $OU" -ForegroundColor Green

# --- Add user to NewEmployeeGroup security group ---
Add-ADGroupMember -Identity $Group -Members $Username
Write-Host "Added $Username to group: $Group" -ForegroundColor Green

Write-Host "`nOnboarding complete for $FirstName $LastName (ER Nurse)" -ForegroundColor Cyan
