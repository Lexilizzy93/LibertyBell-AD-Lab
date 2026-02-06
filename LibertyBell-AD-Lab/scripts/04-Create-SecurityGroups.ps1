# =============================================================================
# 04-Create-SecurityGroups.ps1
# Liberty Bell Hospital - Create Security Groups for RBAC
# Establishes role-based security groups for onboarding and department access
# =============================================================================

$hospitalPath = "OU=LibertyBellGroupHospital,DC=libertybellmedicalgroup,DC=local"

# --- Create NewEmployeeGroup ---
# This group is for all new hires during their 90-day probation period.
# After probation, users are transitioned to department-specific groups.
New-ADGroup -Name "NewEmployeeGroup" `
    -SamAccountName "NewEmployeeGroup" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path $hospitalPath `
    -Description "Group for newly hired employees"

Write-Host "Created security group: NewEmployeeGroup" -ForegroundColor Green

# --- Create department-specific groups ---
$groups = @(
    @{ Name = "GRP-ERNurses";       Path = "OU=ER,$hospitalPath";              Desc = "ER Nursing staff" },
    @{ Name = "GRP-ERPhysicians";   Path = "OU=ER,$hospitalPath";              Desc = "ER Physicians" },
    @{ Name = "ER_Staff";           Path = "OU=ER,$hospitalPath";              Desc = "All ER staff" },
    @{ Name = "GRP-ICU";            Path = "OU=ICU,$hospitalPath";             Desc = "ICU staff" },
    @{ Name = "GRP-SurgServices";   Path = "OU=Surgical Services,$hospitalPath"; Desc = "Surgical Services staff" },
    @{ Name = "GRP-LaborDelivery";  Path = "OU=Labor & Delivery,$hospitalPath";  Desc = "Labor & Delivery staff" }
)

foreach ($group in $groups) {
    try {
        if (-not (Get-ADGroup -Filter "Name -eq '$($group.Name)'" -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $group.Name `
                -GroupScope Global `
                -GroupCategory Security `
                -Path $group.Path `
                -Description $group.Desc
            Write-Host "Created group: $($group.Name)" -ForegroundColor Green
        } else {
            Write-Host "Group already exists: $($group.Name)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "FAILED to create $($group.Name): $_" -ForegroundColor Red
    }
}

Write-Host "`nSecurity group creation complete." -ForegroundColor Cyan
