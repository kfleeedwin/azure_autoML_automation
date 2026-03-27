output "resource_group_name" {
  value = module.sa.resource_group_name
}

output "storage_accounts" {
  value = merge(
    module.sa.storage_accounts,
    module.ml.storage_accounts
  )
}

output "ml_workspace" {
  value = module.ml.ml_workspace
}

output "key_vault" {
  value = module.ml.key_vault
}

output "application_insights" {
  value = module.ml.application_insights
}

output "container_registry" {
  value = module.ml.container_registry
}
