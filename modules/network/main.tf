locals {
  subnets_with_nsg = {
    for key, subnet in var.subnets : key => subnet
    if try(subnet.nsg_key, "") != "" && contains(keys(var.network_security_groups), subnet.nsg_key)
  }

  subnets_with_route_table = {
    for key, subnet in var.subnets : key => subnet
    if try(subnet.route_table_key, "") != "" && contains(keys(var.route_tables), subnet.route_table_key)
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id == null ? [] : [var.ddos_protection_plan_id]
    content {
      id     = ddos_protection_plan.value
      enable = true
    }
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
  for_each = var.network_security_groups

  name                = coalesce(try(each.value.name, null), "${var.vnet_name}-${each.key}-nsg")
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = try(each.value.rules, [])
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = try(security_rule.value.description, null)
    }
  }

  tags = var.tags
}

resource "azurerm_route_table" "rt" {
  for_each = var.route_tables

  name                          = coalesce(try(each.value.name, null), "${var.vnet_name}-${each.key}-rt")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = try(each.value.disable_bgp_route_propagation, false)

  dynamic "route" {
    for_each = try(each.value.routes, [])
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
    }
  }

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                                          = coalesce(try(each.value.name, null), each.key)
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = try(each.value.service_endpoints, [])
  private_endpoint_network_policies_enabled     = try(each.value.private_endpoint_network_policies_enabled, true)
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)

  dynamic "delegation" {
    for_each = try(each.value.delegation, null) == null ? [] : [each.value.delegation]
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each = local.subnets_with_nsg

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_key].id
}

resource "azurerm_subnet_route_table_association" "assoc" {
  for_each = local.subnets_with_route_table

  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.rt[each.value.route_table_key].id
}
