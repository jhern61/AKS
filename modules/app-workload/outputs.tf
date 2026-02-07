output "namespace" {
  description = "Kubernetes namespace for the application."
  value       = kubernetes_namespace.app.metadata[0].name
}

output "service_account_name" {
  description = "Kubernetes service account name."
  value       = kubernetes_service_account.app.metadata[0].name
}

output "identity_client_id" {
  description = "Client ID of the app's managed identity."
  value       = azurerm_user_assigned_identity.app.client_id
}

output "identity_principal_id" {
  description = "Principal ID of the app's managed identity."
  value       = azurerm_user_assigned_identity.app.principal_id
}

output "identity_id" {
  description = "Resource ID of the app's managed identity."
  value       = azurerm_user_assigned_identity.app.id
}
