##############################################################################
# Azure Machine Learning  (Workspace + dependancies) Terraform Configuration #
##############################################################################

data "azurerm_client_config" "current" {}

# Unique suffix for globally-unique storage account name
resource "random_string" "ml_suffix" {
  length  = 6
  upper   = false
  special = false
}

# New Storage Account for AML
resource "azurerm_storage_account" "ml_sa" {
  name                = "azmlsa${random_string.ml_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = var.allow_public_network_access
  tags = var.tags
}

# New Application Insights for AML
resource "azurerm_application_insights" "ml_ai" {
  name                = "azmlai${random_string.ml_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags = var.tags
}

# New Key Vault for AML
resource "azurerm_key_vault" "ml_kv" {
  name                = "azmlkv${random_string.ml_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  public_network_access_enabled = var.allow_public_network_access
  tags = var.tags
}

# New Container Registry for AML
resource "azurerm_container_registry" "ml_acr" {
  name                = "azmlcr${random_string.ml_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku           = "Basic"
  admin_enabled = false
  public_network_access_enabled = var.allow_public_network_access
  tags = var.tags
}

# resource "azurerm_role_assignment" "mlw_acr_pull" {
#  scope                = azurerm_container_registry.ml_acr.id
#  role_definition_name = "AcrPull"
#  principal_id         = azurerm_machine_learning_workspace.mlw.identity[0].principal_id
# }

# Azure Machine Learning Workspace
resource "azurerm_machine_learning_workspace" "ml_ws" {
  name                = "azmlws${random_string.ml_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id      = azurerm_storage_account.ml_sa.id
  key_vault_id            = azurerm_key_vault.ml_kv.id
  application_insights_id = azurerm_application_insights.ml_ai.id
  container_registry_id   = azurerm_container_registry.ml_acr.id
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = var.allow_public_network_access
  tags = var.tags
}