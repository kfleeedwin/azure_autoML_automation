# Variable for Subscription ID  > change as needed
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID used by the root module and providers."
}

# Variable for Resource Group name  > change as needed
variable "resource_group_name" {
  type    = string
  default = "Azure Resource Groups"
}

# Variable for Location > change as needed
variable "location" {
  type        = string
  description = "Azure region for resources."
}

# Whether to allow public network access to resources
variable "allow_public_network_access" {
  type        = bool
  description = "Whether to allow public network access to resources."
}
