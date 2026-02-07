# =============================================================================
# UAT Environment Configuration
# =============================================================================
subscription_id = "__REPLACE_WITH_UAT_SUBSCRIPTION_ID__"
project_name    = "myapp"
environment     = "uat"
location        = "eastus2"
location_short  = "eus2"

tags = {
  CostCenter = "quality-assurance"
  Owner      = "platform-team"
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
vnet_address_space     = ["10.20.0.0/16"]
aks_subnet_cidr        = "10.20.0.0/20"
aks_agents_subnet_cidr = "10.20.16.0/22"

# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------
kubernetes_version      = "1.30"
aks_sku_tier            = "Standard"
private_cluster_enabled = false
azure_policy_enabled    = true

# Monitoring — provide a Log Analytics workspace ID for UAT observability
log_analytics_workspace_id = null

# -----------------------------------------------------------------------------
# System Node Pool
# -----------------------------------------------------------------------------
system_node_pool_vm_size    = "Standard_D4s_v5"
system_node_pool_min_count  = 2
system_node_pool_max_count  = 5
system_node_pool_node_count = 2

# -----------------------------------------------------------------------------
# Application Node Pool
# -----------------------------------------------------------------------------
app_node_pool_enabled    = true
app_node_pool_vm_size    = "Standard_D4s_v5"
app_node_pool_min_count  = 2
app_node_pool_max_count  = 6
app_node_pool_node_count = 2

# -----------------------------------------------------------------------------
# Agents Node Pool
# -----------------------------------------------------------------------------
agents_node_pool_vm_size    = "Standard_D4s_v5"
agents_node_pool_min_count  = 0
agents_node_pool_max_count  = 5
agents_node_pool_node_count = 0

# -----------------------------------------------------------------------------
# Application Workloads — add apps to onboard onto the shared cluster
# -----------------------------------------------------------------------------
app_workloads = {
  api = {
    namespace              = "api"
    service_account_name   = "api-sa"
    resource_quota_enabled = true
    network_policy_enabled = true
  }
  web = {
    namespace              = "web-frontend"
    service_account_name   = "web-sa"
    resource_quota_enabled = true
    network_policy_enabled = true
  }
}

# -----------------------------------------------------------------------------
# Azure DevOps Agents
# -----------------------------------------------------------------------------
# Tenant ID is auto-detected from the current Azure CLI session (data.azurerm_client_config)
ado_org_url            = "https://dev.azure.com/__YOUR_ORG__"
ado_pool_name          = "aks-agents-uat"
ado_agent_namespace    = "ado-agents"
ado_agent_min_replicas = 0
ado_agent_max_replicas = 5
