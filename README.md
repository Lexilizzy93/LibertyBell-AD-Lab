# 🏥 Liberty Bell Hospital — Active Directory IAM Lab

## Overview
A hands-on Identity and Access Management (IAM) lab simulating a healthcare organization's Active Directory infrastructure. This project demonstrates user provisioning, role-based access control (RBAC), security group management, Group Policy configuration, and PowerShell automation — all modeled after a hospital environment with clinical, outpatient, and administrative departments.

**Environment:** Windows Server 2022 | Active Directory Domain Services | PowerShell | Azure AD (Entra ID)

---

## Project Goals
- Design and deploy an Active Directory structure for a multi-department healthcare organization
- Automate user onboarding/offboarding with PowerShell
- Implement role-based access control (RBAC) through security groups and OUs
- Enforce password policies and account security controls
- Apply Group Policies for device-level and user-level security
- Explore AD attack vectors and mitigation strategies (Kerberoasting, GPO abuse, NTLM relay)

---

## Architecture

### Domain: `LibertyBellMedicalGroup.local`

```
LibertyBellMedicalGroup.local
├── LibertyBellGroupHospital        (Hospital Parent OU)
│   ├── ER
│   │   ├── ER Nurses
│   │   └── ER Physicians
│   ├── ICU
│   ├── Inpatient Unit
│   ├── Labor & Delivery
│   ├── Surgical Services
│   ├── MRI Technicians
│   ├── Phlebotomists
│   └── XRay Technicians
├── LibertyBellGroupOutpatient      (Outpatient Parent OU)
│   ├── Diagnostics
│   ├── Pharmacy
│   ├── Primary Care
│   ├── Specialty Clinics
│   └── Urgent Care
├── LibertyBellGroupAdmin           (Admin Parent OU)
│   ├── Compliance
│   ├── Facilities
│   ├── Finance
│   ├── HealthAdmin
│   ├── HR
│   └── IT
```

### Network Configuration
| Component | Value |
|---|---|
| Domain Controller IP | 192.168.109.25 (Static) |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 192.168.109.2 |
| DNS (Primary) | 8.8.8.8 |
| DNS (Alternate) | 8.8.4.4 |
| DHCP | Disabled |

---

## What I Built

### Phase 1: Infrastructure Setup
- Deployed Windows Server 2022 as the domain controller
- Configured static IP addressing and DNS
- Used `arp -a` to identify available IP ranges before assigning the DC's address
- Verified configuration with `ipconfig /all`
- Promoted server to domain controller for `LibertyBellMedicalGroup.local`

### Phase 2: Organizational Unit Design
- Created a three-tier OU structure (Hospital, Outpatient, Admin) to mirror real healthcare operations
- Automated OU creation with PowerShell, including error handling to check for existing OUs before creating new ones
- Each parent OU contains department-specific child OUs for granular policy application

**Script:** [`scripts/01-Create-OUs.ps1`](scripts/01-Create-OUs.ps1)

### Phase 3: Automated User Provisioning
- Built PowerShell scripts using `New-ADUser` to automate employee onboarding
- Variables handle first name, last name, username, OU path, department, and title
- Accounts are created with:
  - `Enabled $true` — account active immediately
  - `ChangePasswordAtLogon $true` — enforces password change on first login
  - Generic password meeting complexity requirements assigned at creation
  - User placed in the correct OU based on their role

**Script:** [`scripts/02-Onboard-Nurse.ps1`](scripts/02-Onboard-Nurse.ps1)  
**Script:** [`scripts/03-Onboard-Physician.ps1`](scripts/03-Onboard-Physician.ps1)

### Phase 4: Security Groups & RBAC
- Created security groups using `New-ADGroup` for role-based access control
- Implemented a `NewEmployeeGroup` for onboarding with a 90-day auto-expiration, transitioning to permanent employee access after probation
- Assigned users to groups with `Add-ADGroupMember`
- Configured group permissions (Read, Write, Create/Delete child objects) per the principle of least privilege

**Script:** [`scripts/04-Create-SecurityGroups.ps1`](scripts/04-Create-SecurityGroups.ps1)

### Phase 5: Group Policy & Security Hardening
- Created GPOs for both computer-level (device-wide security) and user-level (role-specific settings like EMR access and printer mapping)
- Configured account lockout policies balancing security with clinical workflow needs
- Implemented network drive mapping via GPO for persistent access after reboot
- Explored NTFS vs. Share permissions for granular file-level access control

### Phase 6: Security Analysis & Attack Mitigation
Studied and documented AD attack vectors relevant to healthcare environments:

| Attack Vector | Risk | Mitigation |
|---|---|---|
| Kerberoasting | Cracking service account hashes | Strong AES encryption, regular SPN audits |
| GPO Abuse (MITRE ATT&CK T1484) | Compromised admin accounts modifying policies | Least-privilege access, change management |
| NTLM Relay | Credential theft via lateral movement | LAPS, restrict NTLM usage |
| Stale Accounts | Orphaned accounts with active access | Regular access reviews, automated deprovisioning |

---

## Key Scripts

| Script | Description |
|---|---|
| `01-Create-OUs.ps1` | Creates parent and child OUs with error handling |
| `02-Onboard-Nurse.ps1` | Provisions a new nurse account in the ER Nurses OU |
| `03-Onboard-Physician.ps1` | Provisions a physician with role-based group assignment |
| `04-Create-SecurityGroups.ps1` | Creates security groups for new employees |

---

## Lessons Learned
- **PowerShell validation in VS Code** catches errors before they hit production — saving significant troubleshooting time
- **GPO application delays** can be up to 90 minutes by default — critical to understand for incident response timing
- **OU placement matters** — misplaced computer/user objects lead to misapplied policies
- **Simulated environments** are invaluable for testing security controls before production deployment
- **Documentation is essential** — building a knowledge base of successful scripts and configurations pays dividends

---

## Tools & Technologies
- Windows Server 2022
- Active Directory Domain Services (AD DS)
- PowerShell (AD module cmdlets)
- VS Code
- Azure AD / Entra ID (hybrid sync)
- Group Policy Management Console (GPMC)

---

## Future Plans
- [ ] Azure AD (Entra ID) hybrid sync for cloud identity management
- [ ] File Server Resource Manager (FSRM) for storage quotas and file screening
- [ ] Healthcare ticketing system integration
- [ ] Conditional Access Policies via Azure AD
- [ ] Automated offboarding/deprovisioning scripts
- [ ] SIEM integration for AD log monitoring

---

## Resources
- [East Charmer's Windows Server Home Lab Playlist](https://www.youtube.com/playlist?list=PLs2A2ljU0Lq_n3VVB1rOQaVPMxiMGrqKo)
- [Microsoft PowerShell Cmdlet Reference](https://learn.microsoft.com/en-us/powershell/module/activedirectory/)
- [MITRE ATT&CK — Domain Policy Modification (T1484)](https://attack.mitre.org/techniques/T1484/)

---

## Author
**Alexis Armstrong**  
Cybersecurity Analyst | WGU BS Cybersecurity & Information Assurance  
Security+ | SSCP | Network+ | ITIL | ISC² CC | Project+
