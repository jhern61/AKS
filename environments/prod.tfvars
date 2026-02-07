# =============================================================================
# Production Environment Configuration
# =============================================================================
subscription_id = "__REPLACE_WITH_PROD_SUBSCRIPTION_ID__"
project_name    = "myapp"
environment     = "prod"
location        = "eastus2"
location_short  = "eus2"

tags = {
  CostCenter = "production"
  Owner      = "platform-team"
  Compliance = "soc2"
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
vnet_address_space     = ["10.30.0.0/16"]
aks_subnet_cidr        = "10.30.0.0/20"
aks_agents_subnet_cidr = "10.30.16.0/22"

# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------
kubernetes_version      = "1.30"
aks_sku_tier            = "Standard"
private_cluster_enabled = true
azure_policy_enabled    = true

# Monitoring — REQUIRED for production
log_analytics_workspace_id = "__REPLACE_WITH_LOG_ANALYTICS_WORKSPACE_ID__"

# -----------------------------------------------------------------------------
# System Node Pool (production-grade sizing)
# -----------------------------------------------------------------------------
system_node_pool_vm_size    = "Standard_D4s_v5"
system_node_pool_min_count  = 3
system_node_pool_max_count  = 6
system_node_pool_node_count = 3

# -----------------------------------------------------------------------------
# Application Node Pool (production-grade sizing)
# -----------------------------------------------------------------------------
app_node_pool_enabled    = true
app_node_pool_vm_size    = "Standard_D8s_v5"
app_node_pool_min_count  = 3
app_node_pool_max_count  = 20
app_node_pool_node_count = 3

# -----------------------------------------------------------------------------
# Agents Node Pool
# -----------------------------------------------------------------------------
agents_node_pool_vm_size    = "Standard_D4s_v5"
agents_node_pool_min_count  = 0
agents_node_pool_max_count  = 10
agents_node_pool_node_count = 0

# -----------------------------------------------------------------------------
# Application Workloads — add apps to onboard onto the shared cluster
# -----------------------------------------------------------------------------
app_workloads = {
  api = {
    namespace              = "api"
    service_account_name   = "api-sa"
    resource_quota_enabled = true
    resource_quota = {
      "requests.cpu"    = "8"
      "requests.memory" = "16Gi"
      "limits.cpu"      = "16"
      "limits.memory"   = "32Gi"
      "pods"            = "50"
    }
    limit_range_enabled = true
    network_policy_enabled = true
  }
  web = {
    namespace              = "web-frontend"
    service_account_name   = "web-sa"
    resource_quota_enabled = true
    resource_quota = {
      "requests.cpu"    = "4"
      "requests.memory" = "8Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "16Gi"
      "pods"            = "30"
    }
    limit_range_enabled = true
    network_policy_enabled = true
  }
}

# -----------------------------------------------------------------------------
# Azure DevOps Agents
# -----------------------------------------------------------------------------
# Tenant ID is auto-detected from the current Azure CLI session (data.azurerm_client_config)
ado_org_url            = "https://dev.azure.com/__YOUR_ORG__"
ado_pool_name          = "aks-agents-prod"
ado_agent_namespace    = "ado-agents"
ado_agent_min_replicas = 0
ado_agent_max_replicas = 10
