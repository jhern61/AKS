# -----------------------------------------------------------------------------
# AKS Cluster Outputs
# -----------------------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.cluster_id
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity federation."
  value       = module.aks.oidc_issuer_url
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster."
  value       = module.aks.kube_config_raw
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Networking Outputs
# -----------------------------------------------------------------------------
output "vnet_id" {
  description = "Resource ID of the VNet."
  value       = module.networking.vnet_id
}

output "aks_subnet_id" {
  description = "Resource ID of the AKS subnet."
  value       = module.networking.aks_subnet_id
}

# -----------------------------------------------------------------------------
# Workload Identity Outputs
# -----------------------------------------------------------------------------
output "ado_agent_client_id" {
  description = "Client ID of the managed identity for ADO agents."
  value       = module.workload_identity.ado_agent_client_id
}

output "ado_agent_principal_id" {
  description = "Principal ID of the managed identity for ADO agents."
  value       = module.workload_identity.ado_agent_principal_id
}

# -----------------------------------------------------------------------------
# Application Workload Outputs
# -----------------------------------------------------------------------------
output "app_workloads" {
  description = "Map of onboarded application details (namespace, identity client ID, service account)."
  value = {
    for key, mod in module.app_workloads : key => {
      namespace            = mod.namespace
      service_account_name = mod.service_account_name
      identity_client_id   = mod.identity_client_id
      identity_principal_id = mod.identity_principal_id
    }
  }
}
