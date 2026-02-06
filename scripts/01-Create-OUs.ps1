# =============================================================================
# 01-Create-OUs.ps1
# Liberty Bell Hospital - Active Directory OU Structure
# Creates parent and child Organizational Units for Hospital, Outpatient,
# and Administrative departments
# =============================================================================

# --- Step 1: Verify domain info ---
$domainInfo = Get-ADDomain
$trueDomainPath = $domainInfo.DistinguishedName
Write-Host "Using ACTUAL domain path: $trueDomainPath" -ForegroundColor Cyan

# --- Step 2: Create parent OUs ---
$parentOUs = @(
    "LibertyGroupHospital",
    "LibertyBellGroupOutpatient",
    "LibertyBellGroupAdmin"
)

foreach ($ou in $parentOUs) {
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $trueDomainPath -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $ou -Path $trueDomainPath -Description "Top-level OU" -ProtectedFromAccidentalDeletion $true
            Write-Host "Created parent OU [$ou]" -ForegroundColor Green
        } else {
            Write-Host "Parent OU [$ou] already exists" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "FAILED to create [$ou]: $_" -ForegroundColor Red
    }
}

# --- Step 3: Create Hospital child OUs ---
$hospitalOUs = @("ER", "ICU", "Inpatient Unit", "Labor & Delivery", "Surgical Services",
                  "MRI Technicians", "Phlebotomists", "XRay Technicians")
$hospitalPath = "OU=LibertyGroupHospital,$trueDomainPath"

foreach ($ou in $hospitalOUs) {
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $hospitalPath -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $ou -Path $hospitalPath -Description "Child of LibertyGroupHospital" -ProtectedFromAccidentalDeletion $true
            Write-Host "Created Hospital child OU [$ou]" -ForegroundColor Green
        } else {
            Write-Host "Hospital child OU [$ou] already exists" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "FAILED to create [$ou]: $_" -ForegroundColor Red
    }
}

# --- Step 4: Create ER sub-OUs ---
$erPath = "OU=ER,OU=LibertyGroupHospital,$trueDomainPath"
$erSubOUs = @("ER Nurses", "ER Physicians")

foreach ($ou in $erSubOUs) {
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $erPath -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $ou -Path $erPath -Description "ER Sub-OU"
            Write-Host "Created ER sub-OU [$ou]" -ForegroundColor Green
        }
    } catch {
        Write-Host "FAILED to create [$ou]: $_" -ForegroundColor Red
    }
}

# --- Step 5: Create Outpatient child OUs ---
$outpatientOUs = @("Diagnostics", "Pharmacy", "Primary Care", "Specialty Clinics", "Urgent Care")
$outpatientPath = "OU=LibertyBellGroupOutpatient,$trueDomainPath"

foreach ($ou in $outpatientOUs) {
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $outpatientPath -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $ou -Path $outpatientPath -Description "Child of LibertyBellGroupOutpatient"
            Write-Host "Created Outpatient child OU [$ou]" -ForegroundColor Green
        }
    } catch {
        Write-Host "FAILED to create [$ou]: $_" -ForegroundColor Red
    }
}

# --- Step 6: Create Admin child OUs ---
$adminOUs = @("Compliance", "Facilities", "Finance", "HealthAdmin", "HR", "IT")
$adminPath = "OU=LibertyBellGroupAdmin,$trueDomainPath"

foreach ($ou in $adminOUs) {
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $adminPath -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $ou -Path $adminPath -Description "Child of LibertyBellGroupAdmin"
            Write-Host "Created Admin child OU [$ou]" -ForegroundColor Green
        }
    } catch {
        Write-Host "FAILED to create [$ou]: $_" -ForegroundColor Red
    }
}

Write-Host "`nOU structure creation complete." -ForegroundColor Cyan
