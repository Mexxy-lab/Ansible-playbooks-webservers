###############################################################################
# Providers
###############################################################################
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    microsoftgraph = {
      source  = "hashicorp/microsoftgraph"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azuread" {
  # Automatically picks up credentials from az login or environment variables
}

provider "microsoftgraph" {
  # Same tenant as Entra ID
  tenant_id = var.tenant_id
  # The Graph API permissions your registered app must have:
  # DeviceManagementConfiguration.ReadWrite.All
  # DeviceManagementManagedDevices.ReadWrite.All
  # Directory.ReadWrite.All
  scopes = [
    "DeviceManagementConfiguration.ReadWrite.All",
    "DeviceManagementManagedDevices.ReadWrite.All",
    "Directory.ReadWrite.All"
  ]
}