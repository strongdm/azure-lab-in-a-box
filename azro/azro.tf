data "azuread_client_config" "current" {}

# Create an Azure AD application
resource "azuread_application" "sdm" {
  display_name = "${var.name}-SDM-ReadOnly"
  owners       = [data.azuread_client_config.current.object_id,"bc6eb41d-f638-47f8-aa5f-f9fa4eb226f6"]
  feature_tags {
    enterprise = false
    gallery    = false
    custom_single_sign_on = false
    hide = false
  }

}



# Create the service principal
resource "azuread_service_principal" "sdm" {
  client_id                    = azuread_application.sdm.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id,"bc6eb41d-f638-47f8-aa5f-f9fa4eb226f6"]

  feature_tags {
    enterprise = false
    gallery    = false
    custom_single_sign_on = false
    hide = false
  }
}

#resource "tls_private_key" "sdm" {
#  algorithm = "RSA"
#  rsa_bits  = 2048
#}

#resource "tls_self_signed_cert" "sdm" {
#  private_key_pem = tls_private_key.sdm.private_key_pem
#
#  subject {
#    common_name  = "StrongDM Client"
#  }

#  allowed_uses = ["digital_signature"]

  # 5 years
#  validity_period_hours = 24 * 365 * 5
  # Renew every year
#  early_renewal_hours = 24 * 365 * 4
#}


#resource "azuread_service_principal_certificate" "sdm" {
#  service_principal_id = azuread_service_principal.sdm.id
#  type                 = "AsymmetricX509Cert"
#  value                = tls_self_signed_cert.sdm.cert_pem
#  end_date             = "2027-01-01T00:00:00Z"
#}

resource "time_rotating" "sdm" {
  rotation_days = 10
}

resource "azuread_service_principal_password" "sdm" {
  service_principal_id = azuread_service_principal.sdm.id
  rotate_when_changed = {
    rotation = time_rotating.sdm.id
  }  
}

# Assign the Reader role to the service principal (read-only permissions)
resource "azurerm_role_assignment" "sdm" {
  principal_id   = azuread_service_principal.sdm.object_id
  role_definition_name = "Reader"  # Built-in Read-only role
  scope           = "${var.subscription}/resourceGroups/${var.rg}"
}
