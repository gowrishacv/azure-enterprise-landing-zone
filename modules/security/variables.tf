variable "scope" {
  description = "Scope (subscription or management group) for policy assignments. Defaults to current subscription."
  type        = string
  default     = null
}

variable "policy_assignment_prefix" {
  description = "Prefix used for policy and assignment names."
  type        = string
  default     = "lzsec"
}

variable "allowed_locations" {
  description = "List of Azure regions where deployments are permitted."
  type        = list(string)
  default     = ["eastus2", "centralus"]
}

variable "required_tags" {
  description = "Map of required tag names and their enforced values."
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "platform-team"
  }
}

variable "defender_plan_resource_types" {
  description = "Resource types to enable Microsoft Defender for Cloud at Standard tier."
  type        = list(string)
  default     = ["VirtualMachines", "AppServices", "StorageAccounts", "SqlServers", "KubernetesService", "ContainerRegistry"]
}

variable "security_contact_email" {
  description = "Email address that receives Microsoft Defender for Cloud alerts."
  type        = string
  default     = ""
}

variable "security_contact_phone" {
  description = "Phone number for Microsoft Defender for Cloud alerts (optional)."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for routing subscription activity logs (optional)."
  type        = string
  default     = null
}
