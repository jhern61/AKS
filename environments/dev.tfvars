# =============================================================================
# Dev Environment Configuration
# =============================================================================
subscription_id = "__REPLACE_WITH_DEV_SUBSCRIPTION_ID__"
project_name    = "myapp"
environment     = "dev"
location        = "eastus2"
location_short  = "eus2"

tags = {
  CostCenter = "development"
  Owner      = "platform-team"
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
vnet_address_space     = ["10.10.0.0/16"]
aks_subnet_cidr        = "10.10.0.0/20"
aks_agents_subnet_cidr = "10.10.16.0/22"

# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------
kubernetes_version      = "1.30"
aks_sku_tier            = "Free"
private_cluster_enabled = false
azure_policy_enabled    = false

# Monitoring — set to null to disable, or provide a workspace ID
log_analytics_workspace_id = null

# -----------------------------------------------------------------------------
# System Node Pool (smaller for dev)
# -----------------------------------------------------------------------------
system_node_pool_vm_size    = "Standard_D2s_v5"
system_node_pool_min_count  = 1
system_node_pool_max_count  = 3
system_node_pool_node_count = 1

# -----------------------------------------------------------------------------
# Application Node Pool (smaller for dev)
# -----------------------------------------------------------------------------
app_node_pool_enabled    = true
app_node_pool_vm_size    = "Standard_D2s_v5"
app_node_pool_min_count  = 1
app_node_pool_max_count  = 3
app_node_pool_node_count = 1

# -----------------------------------------------------------------------------
# Agents Node Pool (minimal for dev)
# -----------------------------------------------------------------------------
agents_node_pool_vm_size    = "Standard_D2s_v5"
agents_node_pool_min_count  = 0
agents_node_pool_max_count  = 3
agents_node_pool_node_count = 0

# -----------------------------------------------------------------------------
# Application Workloads — add apps to onboard onto the shared cluster
# -----------------------------------------------------------------------------
app_workloads = {
  api = {
    namespace            = "api"
    service_account_name = "api-sa"
  }
  web = {
    namespace            = "web-frontend"
    service_account_name = "web-sa"
  }
}

# -----------------------------------------------------------------------------
# Azure DevOps Agents
# -----------------------------------------------------------------------------
# Tenant ID is auto-detected from the current Azure CLI session (data.azurerm_client_config)
ado_org_url            = "https://dev.azure.com/__YOUR_ORG__"
ado_pool_name          = "aks-agents-dev"
ado_agent_namespace    = "ado-agents"
ado_agent_min_replicas = 0
ado_agent_max_replicas = 3
