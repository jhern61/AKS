output "ado_agent_client_id" {
  description = "Client ID of the ADO agent managed identity."
  value       = azurerm_user_assigned_identity.ado_agent.client_id
}

output "ado_agent_principal_id" {
  description = "Principal ID of the ADO agent managed identity."
  value       = azurerm_user_assigned_identity.ado_agent.principal_id
}

output "ado_agent_identity_id" {
  description = "Resource ID of the ADO agent managed identity."
  value       = azurerm_user_assigned_identity.ado_agent.id
}
