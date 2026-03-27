###################################################
# Azure Storage Account Terraform Configuration   #
###################################################

# Unique suffix for globally-unique storage account name
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "sa_blob" {
  name                              = "azsablob${random_string.suffix.result}"
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  account_kind                      = "StorageV2"
  # Primary service selection:
  # - Blob Storage (default): is_hns_enabled = false
  # - Azure Data Lake Storage Gen2: is_hns_enabled = true
  is_hns_enabled                    = false
  # Security-focused defaults
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = true
  public_network_access_enabled     = var.allow_public_network_access
  infrastructure_encryption_enabled = true
  network_rules {
    default_action                  = "Allow"
    bypass                          = ["AzureServices"]
  }
  # Data protection / recovery options (disabled)
  # No delete_retention_policy and no container_delete_retention_policy => soft delete OFF
  blob_properties {
    versioning_enabled              = false
    change_feed_enabled             = false
  }
  tags                              = var.tags
}
