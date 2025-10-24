## Ansible set up for Managing on premise AD DS domain controllers 

- Ansible is an agentless automation tool that connects to Windows systems (like your Domain Controller) via WinRM.
- With windows modules you can: 

    - Create or delete AD users, groups, and OUs
    - Manage GPOs
    - Install Windows features
    - Configure DNS, DHCP, file servers, etc.
    - Execute PowerShell scripts remotely

# Requirements 

- Linux or Windows host with Ansible installed: see command to install ansible. A Linux machine (Ubuntu, CentOS, WSL, or even a small VM). This is where you run the playbook.
- Windows target (managed node). Your Windows Server 2019 DC (for example Pumejlab.pumej.com). 
- WinRM configured. The DC must allow WinRM connections from your Ansible host.
- Ansible WinRM dependencies, Install pywinrm on your control node. pip install pywinrm

```bash
sudo apt install ansible -y
sudo yum install ansible -y
pip install pywinrm
ansible-playbook -i inventory.yml create_ad_user.yml
```

## Enable winrm on DC server - would set up HTTP connection on port 5985

```bash 
winrm quickconfig
winrm --% set winrm/config/service/auth @{Basic="true"}                 | Run from powershell - set basic auth
winrm --% set winrm/config/service @{AllowUnencrypted="true"}           | Run from powershell - Allow unencrypted traffic
Port 5986 is the default port for WinRM over HTTPS.
Port 5985 is the default port for WinRM over HTTP.
```
## Enable winrm on DC server - would set up HTTP connection on port 5986

```bash
$cert = New-SelfSignedCertificate -DnsName "Pumejlab" -CertStoreLocation Cert:\LocalMachine\My              | Used to create the Certificate
$cert.Thumbprint
New-Item -Path WSMan:\Localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint "48C1DA81F81191DEE26759A98094E420757B0DBE" -Force
netsh advfirewall firewall add rule name="WinRM" dir=in action=allow protocol=TCP localport=5985            | Used to allow port over firewall
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986      | Used to allow port over firewall

$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq "48C1DA81F81191DEE26759A98094E420757B0DBE"}
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

Test-WSMan -ComputerName Win11vm2 -Port 5986 -UseSSL                    | Used to test SSL connection. Sample output is shown below. 

wsmid           : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd
ProtocolVersion : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
ProductVendor   : Microsoft Corporation
ProductVersion  : OS: 0.0.0 SP: 0.0 Stack: 3.0
```

OR 

```bash
# Generate a self-signed cert
$cert = New-SelfSignedCertificate -DnsName "<hostname or IP>" -CertStoreLocation "Cert:\LocalMachine\My"

# Create the WinRM listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname='Win11vm2'; CertificateThumbprint='$($cert.Thumbprint)'}"

# Enable WinRM service and open firewall
Set-Service WinRM -StartMode Automatic
Start-Service WinRM
Enable-PSRemoting -Force
New-NetFirewallRule -DisplayName "WinRM HTTPS" -Name "WinRM-HTTPS" -Protocol TCP -LocalPort 5986 -Action Allow

winrm enumerate winrm/config/Listener                                   | Would output the listener ports with certificates 
```

## Now you can run basic playbook commands 

```bash
ansible all -i inventory.yml -m win_ping                                | Used to test connectivity
ansible-playbook -i inventory.yml get_system_info.yml                   | Used to test connectivity

ansible-playbook -i inventory.yml create_ou.yml
ansible-playbook -i inventory.yml create_group.yml
ansible-playbook -i inventory.yml configure_dns.yml
ansible-playbook -i inventory.yml configure_dhcp.yml
ansible-playbook -i inventory.yml configure_file_server.yml
ansible-playbook -i inventory.yml domain_join.yml

ansible -i inventory.yml win_clients -m win_ping                        | Should return ping for each clients 
ansible -i inventory.yml win_clients -m win_command -a "hostname"       | Should return valid hostnames 
```
## Implementing Ansible vault for secrete management

- First create the vault.yml file using below command 
- Populate the file with your username and passwords and create a secret password when prompted 
- Update your inventory file with the right variables 
- Run your playbook using the vault pass command

```bash
ansible-vault create vault.yml
ansible-vault edit vault.yml                                             | Used to edit or view the vault later.
ansible-playbook -i inventory.yml get_system_info.yml --ask-vault-pass
ansible -i inventory.yml win_clients -m win_ping --ask-vault-pass
```







## Using Ansible to manage Exchange Admin Center on premise AD or Hybrid 

- Ansible can automate and manage Exchange (on-prem or hybrid) using PowerShell commands that the Exchange Admin Center itself uses under the hood.

- You can manage:

    - Mailboxes (create, disable, set quotas, move)
    - Distribution and security groups
    - Mailbox permissions and send-as rights
    - Transport rules
    - Send/Receive connectors
    - Accepted domains
    - Retention policies, mailbox features
    - Mail flow settings (forwarding, automatic replies, etc.)

    Get-Mailbox
    New-Mailbox
    Set-Mailbox
    New-DistributionGroup
    Add-DistributionGroupMember
    Set-TransportRule

| Task Type                               | Possible via Ansible? | Method                                   |
| --------------------------------------- | --------------------- | ---------------------------------------- |
| Manage mailboxes, groups, connectors    | ✅ Yes                 | PowerShell cmdlets                       |
| Access via EAC web interface            | ❌ No                  | Not supported                            |
| Apply policies, quotas, transport rules | ✅ Yes                 | PowerShell                               |
| Query mailbox stats                     | ✅ Yes                 | `Get-MailboxStatistics`                  |
| Remote Exchange Online (M365 Hybrid)    | ✅ Yes                 | PowerShell with ExchangeOnlineManagement |


## Patching of Linux Servers key steps 

- List all packages in the OS 
- Check or confirm packages to be updated

```bash
rpm -qa                                             | Used to list all packages in the OS 
yum list installed                                  | List all installed packages with there version

cat /etc/os-release                                 | To get the OS vendor or flavor 
yum repolist                                        | Used to output repository lists
yum check-update                                    | It would check the repos for available packages 
yum update                                          | To see number of packages that would be upgradred, would also tell the size needed 
yum check-update                                    | Run to confirm updates were successful, there should be no available updates 
```
## Checking disk usage on linux

| Command                 | Purpose                   | Example Use               |
| ----------------------- | ------------------------- | ------------------------- |
| `df -h`                 | Disk usage overview       | Check available space     |
| `lsblk`                 | View disks and partitions | See mount points          |
| `du -h --max-depth=1 /` | Folder size breakdown     | Find large folders        |
| `df -Th`                | Filesystem details        | See FS type (ext4, xfs)   |
| `lvs / vgs / pvs`       | LVM info                  | Logical volume management |

## Reports you can run on Entra ID:

| **Report Type**                | **Purpose**                 | **Example Use Case**                |
| ------------------------------ | --------------------------- | ----------------------------------- |
| **Sign-in Reports**            | Track logins and failures   | Investigate login anomalies         |
| **Audit Logs**                 | Track configuration changes | Identify who modified group roles   |
| **Risky Sign-ins/Users**       | Detect compromised accounts | Block high-risk users automatically |
| **User/Group Reports**         | Manage access & memberships | Review inactive accounts            |
| **Conditional Access Reports** | Analyze access policies     | Tune MFA & location rules           |
| **Sentinel/Log Analytics**     | Centralized monitoring      | SIEM integration                    |
| **License/App Usage Reports**  | Optimize resources          | Identify unused licenses            |

Patch management tools 

- Heimdal 
- ESET
- Kapersky
- goto resolve
- Tenable-io

## Enterprise Baseline Security checklist 

| **Category**                           | **Baseline Item**            | **Details / Best Practice**                                                    |
| -------------------------------------- | ---------------------------- | ------------------------------------------------------------------------------ |
| **Server OS**                          | Rename default admin account | Prevents brute-force attacks on known accounts                                 |
|                                        | Password policy              | Min. 12 chars, complexity enabled, lockout after 5 attempts                    |
|                                        | Disable unused services      | Telnet, SMBv1, FTP if not needed                                               |
|                                        | Time sync                    | Configure NTP to domain or external trusted source                             |
|                                        | Updates                      | Enable WSUS/SCCM or cloud patch manager (AWS SSM, Azure Update Mgmt)           |
|  --------------------------------------| ---------------------------- | ------------------------------------------------------------------------------ |
| **Monitoring & Logging**               | Event logs                   | Forward to SIEM (Splunk, Azure Sentinel, CloudWatch)                           |
|                                        | Performance counters         | Track CPU, memory, disk I/O, network throughput                                |
|                                        | Alerts                       | Configure thresholds for CPU >80%, disk >85%, failed logins                    |

| **Networking**                         | Firewall                     | Default deny-all, allow only required ports (RDP 3389 restricted)              |
|                                        | IP config                    | Use static IP/DHCP reservation, DNS set to enterprise standard                 |
|                                        | Segmentation                 | Separate prod/test/dev VLANs or VPCs                                           |
|  --------------------------------------| ---------------------------- | ------------------------------------------------------------------------------ |
| **Application (IIS / Enterprise App)** | TLS                          | Enforce TLS 1.2+, disable SSLv3/TLS1.0                                         |
|                                        | SSL certificate              | Use trusted CA, renew before expiry                                            |
|                                        | App pools                    | Run under least-privileged service accounts                                    |
|                                        | Logging                      | Enable detailed access/error logging, ship to central log system               |
|  --------------------------------------| ---------------------------- | ------------------------------------------------------------------------------ |
| **Security**                           | MFA                          | Enforce MFA for all admin accounts                                             |
|                                        | RBAC                         | Apply least privilege access for users/groups                                  |
|                                        | Vulnerability scanning       | Run Nessus/Qualys monthly, remediate findings                                  |
|                                        | Audit policy                 | Logon success/failure, privilege use, object access                            |
|                                        | Encryption                   | Encrypt data at rest (BitLocker, EBS/Azure Disk Encryption) & in transit (TLS) |
|  --------------------------------------| ---------------------------- | ------------------------------------------------------------------------------ |
| **Patch & Upgrade**                    | Patch cycle                  | Apply critical patches within 7 days, monthly patch window                     |
|                                        | Staging                      | Test all upgrades/patches in staging before production                         |
|                                        | Rollback plan                | Documented restore/rollback procedures (snapshots, backups)                    |
|  --------------------------------------| ---------------------------- | ------------------------------------------------------------------------------ |
| **Backups & Recovery**                 | Backup schedule              | Daily incremental, weekly full, retain min. 30 days                            |
|                                        | Recovery testing             | Quarterly restore drills to validate backup integrity                          |
|                                        | Offsite/Cloud backups        | Store encrypted backups offsite or in DR region                                |
|  --------------------------------------| ---------------------------- | ------------------------------------------------------------------------------ |
| **Compliance & Documentation**         | Change management            | All changes logged in ServiceNow/Jira with CAB approval                        |
|                                        | CMDB updates                 | Keep server/app configurations updated in CMDB                                 |
|                                        | Baseline compliance          | Use SCCM/Azure Policy/AWS Config to enforce standards                          |
|  --------------------------------------| ---------------------------- | ------------------------------------------------------------------------------ |