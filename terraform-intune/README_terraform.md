1️⃣ Terraform + Microsoft Entra ID (Azure AD)

Provider: hashicorp/azuread

You can automate and manage almost all identity-related resources, for example:

- Users, groups, and group memberships
- Applications (App registrations, service principals, API permissions)
- Conditional Access policies (Baseline security policies)
- Directory roles and assignments 
- Custom security attributes 

2️⃣ Terraform + Microsoft Intune:

Provider: microsoftgraph

Terraform also supports Intune — but not through the main Azure provider.

- Device configuration profiles (Windows, iOS, Android and linux)
- Compliance policies (Baseline policies also)
- Applications and app deployments
- Device categories
- Enrollment restrictions
- Autopilot profiles 
- Role assignments and scopes
- Intune policies and baselines

You must register an app in Entra ID that has Microsoft Graph API permissions (e.g., DeviceManagementConfiguration.ReadWrite.All) and then authenticate Terraform using its client ID/secret or certificate.

## Terraform usage with Intune and Entra ID. Below steps can be done using Terraform 

- Create a group in Entra ID using the azuread provider
- Create a Windows 11 compliance policy in Intune using the microsoftgraph provider
- Assign that policy to the created group
- Create an autopilot deployment profile 
- Assign it to a group also 

🔐 Authentication Setup Steps:

1️⃣ Register an app in Entra ID:

- Go to Entra ID → App registrations → New registration
- Name it “Terraform-Intune-Automation”
- Supported account type: Single tenant
- Redirect URI: leave blank

2️⃣ Under API permissions, add:

- Microsoft Graph → Application permissions:

    - DeviceManagementConfiguration.ReadWrite.All
    - DeviceManagementManagedDevices.ReadWrite.All
    - Directory.ReadWrite.All

- Click Grant admin consent

3️⃣ Under Certificates & secrets, create a new client secret and copy:

- Tenant ID
- Client ID
- Client Secret

4️⃣ Export them for Terraform:

    ```bash
    export AZURE_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    export AZURE_CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    export AZURE_CLIENT_SECRET="your-client-secret-here"
    ```
    
⚙️ Then run:

    ```bash
    terraform init
    terraform plan
    ```
    ```bash
    terraform apply -var="tenant_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    ```    