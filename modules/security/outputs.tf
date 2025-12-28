output "policy_assignment_ids" {
  value = {
    allowed_locations = azurerm_policy_assignment.allowed_locations.id
    required_tags     = { for k, v in local.sanitized_required_tag_ns : v.key => azurerm_policy_assignment.required_tags[k].id }
  }
}

output "defender_plan_ids" {
  value = { for k, v in azurerm_security_center_subscription_pricing.defender : k => v.id }
}

output "security_contact_id" {
  value = try(azurerm_security_center_contact.contact[0].id, null)
}

output "diagnostic_setting_id" {
  value = try(azurerm_monitor_diagnostic_setting.security_activity[0].id, null)
}
