output "vnet_id" {
  description = "Resource ID of the VNet."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the VNet."
  value       = azurerm_virtual_network.main.name
}

output "aks_subnet_id" {
  description = "Resource ID of the AKS workloads subnet."
  value       = azurerm_subnet.aks.id
}

output "aks_agents_subnet_id" {
  description = "Resource ID of the AKS agents subnet."
  value       = azurerm_subnet.aks_agents.id
}
