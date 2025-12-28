data "azurerm_subscription" "current" {}

locals {
  scope                     = coalesce(var.scope, data.azurerm_subscription.current.id)
  policy_assignment_prefix  = var.policy_assignment_prefix != "" ? var.policy_assignment_prefix : "lzsec"
  sanitized_required_tag_ns = { for k, v in var.required_tags : replace(lower(k), " ", "-") => { key = k, value = v } }
}

# Restrict deployments to approved Azure regions
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "${local.policy_assignment_prefix}-allowed-locations"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed locations (landing zone)"
  description  = "Restrict deployments to the approved Azure regions for this landing zone."

  metadata = jsonencode({
    category = "Governance"
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field = "location"
      notIn = "[parameters('allowedLocations')]"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_assignment" "allowed_locations" {
  name                 = "${local.policy_assignment_prefix}-allowed-locations"
  scope                = local.scope
  display_name         = "Allowed locations"
  description          = "Ensures resources are created only in approved Azure regions."
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
  })
}

# Enforce required tags (name/value) on all resources
resource "azurerm_policy_definition" "require_tag" {
  name         = "${local.policy_assignment_prefix}-require-tag"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require tag with specific value"
  description  = "Deny resources missing required tags (name/value)."

  metadata = jsonencode({
    category = "Governance"
  })

  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag Name"
      }
    }
    tagValue = {
      type = "String"
      metadata = {
        displayName = "Tag Value"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field     = "[concat('tags[', parameters('tagName'), ']')]"
      notEquals = "[parameters('tagValue')]"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_assignment" "required_tags" {
  for_each             = local.sanitized_required_tag_ns
  name                 = "${local.policy_assignment_prefix}-tag-${each.key}"
  scope                = local.scope
  display_name         = "Enforce tag ${each.value.key}"
  description          = "Ensures the tag ${each.value.key} is set to ${each.value.value}."
  policy_definition_id = azurerm_policy_definition.require_tag.id
  parameters = jsonencode({
    tagName  = { value = each.value.key }
    tagValue = { value = each.value.value }
  })
}

# Microsoft Defender for Cloud baseline (Standard pricing)
resource "azurerm_security_center_subscription_pricing" "defender" {
  for_each      = toset(var.defender_plan_resource_types)
  tier          = "Standard"
  resource_type = each.value
}

# Security contact for alerts and notifications
resource "azurerm_security_center_contact" "contact" {
  count = var.security_contact_email == "" ? 0 : 1

  email               = var.security_contact_email
  phone               = var.security_contact_phone
  alert_notifications = true
  alerts_to_admins    = true
}

# Forward subscription activity (security-relevant) to Log Analytics when provided
resource "azurerm_monitor_diagnostic_setting" "security_activity" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "${local.policy_assignment_prefix}-activity"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "Administrative"
    enabled  = true
  }

  log {
    category = "Security"
    enabled  = true
  }

  log {
    category = "Policy"
    enabled  = true
  }

  log {
    category = "Alert"
    enabled  = true
  }
}
