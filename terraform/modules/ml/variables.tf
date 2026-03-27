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

# Public network access variable
variable "allow_public_network_access" {
  description = "If false, disables public network access (recommended)."
  type        = bool
  default     = true
}

# Tags variable
variable "tags" {
  type = map(string)
  default = {
    owner = "replace-with-owner"
    env   = "lab"
  }
}