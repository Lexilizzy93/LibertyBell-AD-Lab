# 🏥 Liberty Bell Hospital — Active Directory & Security Operations Lab

## Overview
A comprehensive Identity and Access Management (IAM) and Security Operations lab simulating a healthcare organization's migration from an outdated on-premises Active Directory to a cloud hybrid environment. Acting as the Security Analyst and IT Administrator, I built automation for the full identity lifecycle — onboarding, probationary access transitions, role-based access changes, and auto-deprovisioning — while monitoring the environment with a SIEM and testing defenses against simulated attacks.

**Environment:** Windows Server 2022 | Active Directory Domain Services | Azure AD (Entra ID) | PowerShell | Splunk (SIEM) | EMR System | VS Code

---

## Project Goals
- Migrate an outdated on-prem AD infrastructure to a cloud hybrid model (AD → Azure AD)
- Automate the full identity lifecycle with PowerShell:
  - Onboard new hires with role-appropriate access
  - Transition employees out of 90-day probationary period (limited → full access)
  - Increase/decrease user access rights using attribute-based access control (ABAC)
  - Auto-deprovision contractor/vendor accounts after a set number of days
  - Push bulk updates to accounts
- Deploy an EMR system with patient accounts to simulate real clinical data
- Deploy Splunk as a SIEM for log monitoring and alerting
- Simulate attacks to test detection, response, and mitigation

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
- Designed a three-tier OU structure (Hospital, Outpatient, Admin) mirroring real healthcare operations
- Automated OU creation with PowerShell including error handling to prevent duplicates
- Each parent OU contains department-specific child OUs for granular policy application

**Script:** [`scripts/01-Create-OUs.ps1`](scripts/01-Create-OUs.ps1)

### Phase 3: Automated User Provisioning
- Built PowerShell scripts using `New-ADUser` to automate employee onboarding
- Accounts created with:
  - Automatic username generation from first/last name
  - OU placement based on role and department
  - Generic password meeting complexity requirements
  - `ChangePasswordAtLogon $true` — enforces password change on first login
  - `Enabled $true` — account active immediately
- Used VS Code to write and validate scripts before execution, catching syntax errors in real time and reducing troubleshooting

**Script:** [`scripts/02-Onboard-Nurse.ps1`](scripts/02-Onboard-Nurse.ps1)  
**Script:** [`scripts/03-Onboard-Physician.ps1`](scripts/03-Onboard-Physician.ps1)

### Phase 4: Security Groups & Role-Based Access Control (RBAC)
- Created security groups using `New-ADGroup` for role-based access
- Implemented a `NewEmployeeGroup` with limited system access for the 90-day probationary period
- After probation, employees transition to department-specific groups with full role-appropriate access
- Configured group permissions using least-privilege principles (Read, Write, Create/Delete child objects)

**Script:** [`scripts/04-Create-SecurityGroups.ps1`](scripts/04-Create-SecurityGroups.ps1)

### Phase 5: Identity Lifecycle Automation
The core of this lab — automating the full identity lifecycle that an IAM Analyst manages daily:

**Probationary Access Transition**
- New hires start in `NewEmployeeGroup` with limited access to systems
- After 90 days, script automatically transitions them to their department-specific security group with full role-appropriate access
- Eliminates manual tracking and ensures no one stays on limited access longer than necessary

**Contractor/Vendor Auto-Deprovisioning**
- Contractor and vendor accounts are created with an expiration date
- Scripts automatically deprovision accounts after the set number of days
- Prevents stale accounts from remaining active — a common audit finding and security risk

**Attribute-Based Access Control (ABAC)**
- Scripts to increase or decrease user access rights based on role changes
- When an employee transfers departments or changes roles, access is adjusted automatically
- Supports principle of least privilege — users only have access they need for their current role

**Bulk Account Updates**
- Scripts to push updates across multiple accounts simultaneously
- Used for organization-wide changes like password policy updates or group membership modifications

### Phase 6: EMR System & Patient Accounts
- Installed an Electronic Medical Records (EMR) system in the lab environment
- Created simulated patient accounts to mirror real clinical data workflows
- Used to test access controls — verifying that only authorized roles (nurses, physicians) could access patient records
- Validated HIPAA-aligned access restrictions through the AD group structure

### Phase 7: SIEM Deployment (Splunk)
- Deployed Splunk as the SIEM for centralized log monitoring
- Ingested Active Directory logs, Windows Event Logs, and network traffic
- Built dashboards and alerts for:
  - Failed login attempts
  - Privilege escalation events
  - Account creation/deletion activity
  - Unauthorized access attempts to restricted systems

### Phase 8: Attack Simulation & Incident Response
Simulated real-world attacks against the environment to test detection and response:

- Launched attacks to observe how they manifest in network traffic and SIEM logs
- Analyzed Splunk alerts to identify indicators of compromise (IOCs)
- Practiced incident response workflows:
  - Detection → Investigation → Containment → Remediation
- Documented mitigation strategies for each attack vector

**Attack Vectors & Mitigations Studied:**

| Attack Vector | Risk | Mitigation |
|---|---|---|
| Kerberoasting | Cracking service account hashes | Strong AES encryption, regular SPN audits |
| GPO Abuse (MITRE ATT&CK T1484) | Policy manipulation via compromised admin accounts | Least-privilege access, change management |
| NTLM Relay | Credential theft via lateral movement | LAPS, restrict NTLM usage |
| Brute Force Login | Unauthorized access via password guessing | Account lockout policies, MFA |
| Privilege Escalation | Unauthorized elevation of access rights | Monitoring with Splunk, least-privilege groups |
| Stale Account Exploitation | Orphaned accounts used for unauthorized access | Auto-deprovisioning scripts, regular access reviews |

### Phase 9: Group Policy & Security Hardening
- Created GPOs for device-level security (hospital computers) and user-level settings (role-specific EMR access, printer mapping)
- Configured account lockout policies balancing security with clinical workflow needs
- Implemented network drive mapping via GPO for persistent access
- Explored NTFS vs. Share permissions for granular file-level access control
- Tested GPO propagation timing — discovered default delays up to 90 minutes, critical for incident response

---

## Key Scripts

| Script | Description |
|---|---|
| `01-Create-OUs.ps1` | Creates parent and child OUs with duplicate-checking |
| `02-Onboard-Nurse.ps1` | Provisions a new nurse account with role-based OU placement |
| `03-Onboard-Physician.ps1` | Provisions a physician with department group assignment |
| `04-Create-SecurityGroups.ps1` | Creates security groups for RBAC |

---

## Development Approach
- **VS Code** for script development — real-time syntax validation caught errors before execution, reducing troubleshooting time significantly
- **PowerShell ISE** for quick testing
- **Iterative development** — started with a basic tutorial, then expanded into a full environment with automation, SIEM, and attack simulation over multiple phases
- **Documentation-first mindset** — documented configurations and scripts in Notion and Obsidian for quick reference

---

## Lessons Learned
- **Automate everything possible** — manual provisioning doesn't scale and introduces human error
- **VS Code validation** catches script errors before they hit production, saving significant time
- **GPO application delays** can be up to 90 minutes by default — critical for incident response planning
- **OU placement matters** — misplaced objects lead to misapplied policies and access issues
- **Stale accounts are a real threat** — auto-deprovisioning is essential, not optional
- **SIEM tuning is ongoing** — too many alerts leads to fatigue, too few means missed threats
- **Simulated environments** are invaluable for testing security controls safely before production

---

## Tools & Technologies
- Windows Server 2022
- Active Directory Domain Services (AD DS)
- Azure AD / Entra ID (hybrid cloud sync)
- PowerShell (AD module cmdlets)
- VS Code (script development & validation)
- Splunk (SIEM)
- EMR System (clinical data simulation)
- Group Policy Management Console (GPMC)
- MITRE ATT&CK Framework (attack mapping)

---

## Future Plans
- [ ] Conditional Access Policies via Azure AD
- [ ] File Server Resource Manager (FSRM) for storage quotas
- [ ] Healthcare ticketing system integration
- [ ] Automated offboarding with manager approval workflow
- [ ] Splunk dashboard templates for AD monitoring
- [ ] Additional attack simulations (Pass-the-Hash, Golden Ticket)

---

## Resources
- [East Charmer's Windows Server Home Lab Playlist](https://www.youtube.com/playlist?list=PLs2A2ljU0Lq_n3VVB1rOQaVPMxiMGrqKo)
- [Microsoft PowerShell Cmdlet Reference](https://learn.microsoft.com/en-us/powershell/module/activedirectory/)
- [MITRE ATT&CK — Domain Policy Modification (T1484)](https://attack.mitre.org/techniques/T1484/)
- [Splunk Documentation](https://docs.splunk.com/)

---

## Author
**Alexis Armstrong**  
Cybersecurity Analyst | WGU BS Cybersecurity & Information Assurance  
Security+ | SSCP | Network+ | ITIL | ISC² CC | Project+
