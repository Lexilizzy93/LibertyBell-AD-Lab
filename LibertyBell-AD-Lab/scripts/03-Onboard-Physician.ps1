# =============================================================================
# 03-Onboard-Physician.ps1
# Liberty Bell Hospital - Automate Physician Onboarding
# Creates AD user account with role-specific attributes and group assignment
# =============================================================================

$domain = "libertybellmedicalgroup.local"
$erOU = "OU=ER,OU=LibertyGroupHospital,DC=LibertyBellMedicalGroup,DC=local"

# --- Create user ---
New-ADUser -Name "Doc McStuffins" `
    -GivenName "Doc" `
    -Surname "McStuffins" `
    -SamAccountName "dmcstuffins" `
    -UserPrincipalName "dmcstuffins@$domain" `
    -DisplayName "Dr. Doc McStuffins" `
    -Description "ER Physician" `
    -Path $erOU `
    -AccountPassword (ConvertTo-SecureString "P@ssW0rd123!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true `
    -Title "Attending Physician" `
    -Department "Emergency Medicine"

Write-Host "Physician account created: dmcstuffins" -ForegroundColor Green

# --- Create ER_Staff group if it doesn't exist, then assign ---
if (-not (Get-ADGroup -Filter "Name -eq 'ER_Staff'")) {
    New-ADGroup -Name "ER_Staff" -GroupScope Global -Path $erOU
    Write-Host "Created security group: ER_Staff" -ForegroundColor Green
}

Add-ADGroupMember -Identity "ER_Staff" -Members "dmcstuffins"
Write-Host "Added dmcstuffins to ER_Staff group" -ForegroundColor Green

Write-Host "`nPhysician onboarding complete." -ForegroundColor Cyan
