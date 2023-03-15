
variable "az-subscription" {
  description = "Azure Subscription for CG Controller Reader"
  type        = string
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "sub" {
    subscription_id = var.az-subscription
}

# Create Azure AD App Registration
resource "azuread_application" "app" {
  display_name = "cg-reader1"
  #owners       = [data.azuread_client_config.current.object_id]
}

# Create Service Principal
resource "azuread_service_principal" "app" {
  application_id = azuread_application.app.application_id
  owners                       = [data.azuread_client_config.current.object_id]
}

# Create Service Principal password
resource "azuread_service_principal_password" "app" {
  service_principal_id = azuread_service_principal.app.id
}

# Output the Service Principal and password
output "cg-reader-app-id" {
  value     = azuread_service_principal.app.id
  sensitive = true
}

output "cg-reader-app-secret" {
  value     = azuread_service_principal_password.app.value
  sensitive = true
}

output "cg-reader-tenant" {
    value = azuread_service_principal.app.application_tenant_id 
}

resource "azurerm_role_assignment" "sub-dev-sg_az_sub_reader_01" {
  scope                = data.azurerm_subscription.sub.id
  role_definition_name = "Reader"
  principal_id       = azuread_service_principal.app.id
}