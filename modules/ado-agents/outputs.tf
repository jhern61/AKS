output "namespace" {
  description = "Kubernetes namespace for ADO agents."
  value       = kubernetes_namespace.ado_agents.metadata[0].name
}

output "service_account_name" {
  description = "Service account name for ADO agents."
  value       = kubernetes_service_account.ado_agent.metadata[0].name
}
