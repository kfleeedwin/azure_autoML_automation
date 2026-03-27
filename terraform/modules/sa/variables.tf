# Variable for Subscription ID > change as needed
variable "subscription_id" {
  type        = string
  description = "var.subscription_id"
}

# Variable for Resource Group name  > change as needed
variable "resource_group_name" {
  type    = string
  default = "replace-with-resource-group-name"
}

# Variable for Location > change as needed
variable "location" {
  type    = string
  default = "var.location"
}

# Tags variable
variable "tags" {
  type = map(string)
  default = {
    owner = "replace-with-owner"
    env   = "lab"
  }
}

# Storage Account variables
variable "enable_adls_gen2" {
  type        = bool
  description = "Enable ADLS Gen2 (Hierarchical Namespace)"
  default     = true
}

# Blob properties variables
variable "enable_versioning" {
  type    = bool
  default = false
}

# Blob properties variables
variable "enable_change_feed" {
  type    = bool
  default = false
}

variable "enable_blob_soft_delete" {
  type    = bool
  default = false
}

# Enable container soft delete
variable "blob_soft_delete_days" {
  type    = number
  default = 14
}

# Enable container soft delete
variable "container_soft_delete_days" {
  type    = number
  default = 14
}

# Network rules variables
variable "allowed_ips" {
  description = "Optional allowlist. Leave empty to deny all public network access (recommended)."
  type        = list(string)
  default     = []
}

# Public network access variable
variable "allow_public_network_access" {
  description = "If false, disables public network access (recommended)."
  type        = bool
  default     = true
}