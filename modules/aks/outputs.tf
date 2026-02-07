output "cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity."
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "kube_config" {
  description = "Kube config object for provider configuration."
  value = {
    host                   = azurerm_kubernetes_cluster.main.kube_config[0].host
    client_certificate     = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
    client_key             = azurerm_kubernetes_cluster.main.kube_config[0].client_key
    cluster_ca_certificate = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  }
  sensitive = true
}

output "kube_config_raw" {
  description = "Raw kubeconfig."
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "cluster_identity_principal_id" {
  description = "Principal ID of the cluster managed identity."
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

output "node_resource_group" {
  description = "Auto-generated resource group for AKS nodes."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}
