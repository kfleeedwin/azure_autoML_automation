output "resource_group_name" {
  value = var.resource_group_name
}

    output "storage_accounts" {
      value = {
        blob = {
          name = azurerm_storage_account.sa_blob.name
          id   = azurerm_storage_account.sa_blob.id
        }
      }
    } 
#        dlgen2 = {
#          name = azurerm_storage_account.sa_dlgen2.name
#          id   = azurerm_storage_account.sa_dlgen2.id
#        }
#      }
#    }
