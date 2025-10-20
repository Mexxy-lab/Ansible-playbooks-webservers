###############################################################################
# Step 1 - Create Entra ID (Azure AD) Group
###############################################################################

resource "azuread_group" "intune_test_group" {
  display_name     = "Intune Windows 11 Compliance Group"
  security_enabled = true
  mail_enabled     = false
  description      = "Devices assigned to this group receive the Windows 11 compliance policy"
}


###############################################################################
# Step 2 - Create Intune Compliance Policy
###############################################################################

resource "microsoftgraph_device_compliance_policy_windows10" "win11_compliance" {
  display_name = "Windows 11 Baseline Compliance Policy"
  description  = "Ensures BitLocker, Defender, and Secure Boot are enabled."

  password_required                = true
  password_required_type            = "alphanumeric"
  password_required_to_unlock       = true
  password_expiration_days          = 90
  password_minimum_length           = 8
  os_minimum_version                = "10.0.22000.0"
  os_maximum_version                = "10.0.99999.999"
  defender_enabled                  = true
  defender_real_time_protection_enabled = true
  bit_locker_enabled                = true
  secure_boot_enabled               = true
  code_integrity_enabled            = true
}

###############################################################################
# Step 3 - Assign the Compliance Policy to the Group
###############################################################################

resource "microsoftgraph_device_compliance_policy_assignment" "win11_assignment" {
  policy_id = microsoftgraph_device_compliance_policy_windows10.win11_compliance.id
  target {
    group_id = azuread_group.intune_test_group.id
  }
}

###############################################################################
# Step 4 - Create Windows Autopilot Deployment Profile
###############################################################################

resource "microsoftgraph_windows_autopilot_deployment_profile" "win11_autopilot" {
  display_name       = "Windows 11 Hybrid Join Deployment Profile"
  description        = "Autopilot profile for hybrid-joined Windows 11 devices"
  language           = "en-US"
  out_of_box_experience_settings {
    user_type                     = "standard"    # 'administrator' or 'standard'
    hide_express_settings         = true
    hide_landing_page             = true
    hide_oem_registration_screen  = true
    hide_eula                     = true
    skip_keyboard_selection_page  = true
  }

  # If you're doing hybrid join, set this to "userDrivenAzureADJoin" or "userDrivenHybridAzureADJoin"
  deployment_mode = "userDrivenHybridAzureADJoin"

  # Optional advanced configuration
  enable_white_glove        = false
  allow_device_reset        = true
  allow_device_use_before_profile_assignment = false
  management_service_app_id = "0000000a-0000-0000-c000-000000000000" # Default Intune MDM app ID
}
###############################################################################
# Step 5 - Assign Autopilot Profile to the Group
###############################################################################
resource "microsoftgraph_windows_autopilot_deployment_profile_assignment" "autopilot_assignment" {
  deployment_profile_id = microsoftgraph_windows_autopilot_deployment_profile.win11_autopilot.id
  target {
    group_id = azuread_group.intune_test_group.id
  }
}

###############################################################################
# Step 6 - Dynamic Device Group for Windows 11 Autopilot Devices
###############################################################################

resource "azuread_group" "autopilot_dynamic_group" {
  display_name     = "Windows 11 Autopilot Devices"
  description      = "Automatically includes all Windows 11 devices enrolled via Autopilot"
  security_enabled = true
  mail_enabled     = false
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "((device.deviceOSType -eq \"Windows\") and (device.deviceOSVersion -startsWith \"10.0\"))"
  }
}
###############################################################################
# Step 7 - Assign Compliance Policy and Autopilot Profile to Dynamic Group
###############################################################################
# resource "microsoftgraph_device_management_compliance_policy_assignment" "assign_compliance" {
#   policy_id = microsoftgraph_device_management_compliance_policy.win11_policy.id
#   target {
#     group_id = azuread_group.autopilot_dynamic_group.id
#   }
# }

# resource "microsoftgraph_windows_autopilot_deployment_profile_assignment" "assign_autopilot" {
#   deployment_profile_id = microsoftgraph_windows_autopilot_deployment_profile.win11_autopilot.id
#   target {
#     group_id = azuread_group.autopilot_dynamic_group.id
#   }
# }
