output "storage_accounts" {
  value = {
    ml = {
      name = azurerm_storage_account.ml_sa.name
      id   = azurerm_storage_account.ml_sa.id
    }
  }
}

output "application_insights" {
  value = {
    name = azurerm_application_insights.ml_ai.name
    id   = azurerm_application_insights.ml_ai.id
  }
}

output "key_vault" {
  value = {
    name = azurerm_key_vault.ml_kv.name
    id   = azurerm_key_vault.ml_kv.id
  }
}

output "container_registry" {
  value = {
    name         = azurerm_container_registry.ml_acr.name
    id           = azurerm_container_registry.ml_acr.id
    login_server = azurerm_container_registry.ml_acr.login_server
  }
}

output "ml_workspace" {
  value = {
    name = azurerm_machine_learning_workspace.ml_ws.name
    id   = azurerm_machine_learning_workspace.ml_ws.id
  }
}