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
New-Item -Path WSMan:\Localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint "AE621965F7FA194140E87796E4238963F0ED282D" -Force

$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq "AE621965F7FA194140E87796E4238963F0ED282D"}
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

Test-WSMan -ComputerName Pumejlab -Port 5986 -UseSSL                    | Used to test SSL connection 

wsmid           : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd
ProtocolVersion : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
ProductVendor   : Microsoft Corporation
ProductVersion  : OS: 0.0.0 SP: 0.0 Stack: 3.0

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
