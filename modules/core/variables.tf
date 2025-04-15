variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}
variable "location" {
  description = "Location of the resource group"
  type        = string
}
variable "storage_name" {
  description = "value of the storage account name"
  type        = string
  default     = "azweutfstateen001"
  validation {
    condition     = length(var.storage_name) >= 3 && length(var.storage_name) <= 24
    error_message = "Storage name must be between 3 and 24 characters."
  }

  validation {
    condition     = length(var.storage_name) > 0
    error_message = "Storage name must not be empty."
  }
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
