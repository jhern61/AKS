terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  subscription_id = var.subscription_id
}

provider "azuread" {}

provider "kubernetes" {
  host                   = module.aks.kube_config.host
  client_certificate     = base64decode(module.aks.kube_config.client_certificate)
  client_key             = base64decode(module.aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config.host
    client_certificate     = base64decode(module.aks.kube_config.client_certificate)
    client_key             = base64decode(module.aks.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  }
}

# Note: The helm provider's 'kubernetes' block is valid syntax per the
# hashicorp/helm provider schema. IDE lint warnings can be safely ignored.

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${var.location_short}"
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------
locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })

  cluster_name = "aks-${var.project_name}-${var.environment}-${var.location_short}"
}

# -----------------------------------------------------------------------------
# Modules
# -----------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  location_short      = var.location_short

  vnet_address_space     = var.vnet_address_space
  aks_subnet_cidr        = var.aks_subnet_cidr
  aks_agents_subnet_cidr = var.aks_agents_subnet_cidr

  tags = local.common_tags
}

module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  cluster_name        = local.cluster_name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  # Networking
  vnet_subnet_id        = module.networking.aks_subnet_id
  agents_subnet_id      = module.networking.aks_agents_subnet_id
  network_plugin        = var.network_plugin
  network_policy        = var.network_policy
  service_cidr          = var.aks_service_cidr
  dns_service_ip        = var.aks_dns_service_ip

  # System node pool
  system_node_pool_vm_size    = var.system_node_pool_vm_size
  system_node_pool_min_count  = var.system_node_pool_min_count
  system_node_pool_max_count  = var.system_node_pool_max_count
  system_node_pool_node_count = var.system_node_pool_node_count

  # Application node pool
  app_node_pool_enabled    = var.app_node_pool_enabled
  app_node_pool_vm_size    = var.app_node_pool_vm_size
  app_node_pool_min_count  = var.app_node_pool_min_count
  app_node_pool_max_count  = var.app_node_pool_max_count
  app_node_pool_node_count = var.app_node_pool_node_count

  # Agents node pool (for ADO agents)
  agents_node_pool_vm_size    = var.agents_node_pool_vm_size
  agents_node_pool_min_count  = var.agents_node_pool_min_count
  agents_node_pool_max_count  = var.agents_node_pool_max_count
  agents_node_pool_node_count = var.agents_node_pool_node_count

  # Features
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  keda_enabled              = true
  azure_policy_enabled      = var.azure_policy_enabled
  sku_tier                  = var.aks_sku_tier
  private_cluster_enabled   = var.private_cluster_enabled

  # Monitoring
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = local.common_tags
}

module "workload_identity" {
  source = "./modules/workload-identity"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment

  aks_oidc_issuer_url = module.aks.oidc_issuer_url

  # Azure DevOps agent identity
  ado_agent_namespace          = var.ado_agent_namespace
  ado_agent_service_account    = var.ado_agent_service_account

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Application Workloads — for_each over the app_workloads map to onboard
# multiple applications onto the shared cluster.
# -----------------------------------------------------------------------------
module "app_workloads" {
  source   = "./modules/app-workload"
  for_each = var.app_workloads

  app_name            = each.key
  namespace           = each.value.namespace
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  aks_oidc_issuer_url = module.aks.oidc_issuer_url

  service_account_name = each.value.service_account_name
  namespace_labels     = each.value.namespace_labels

  resource_quota_enabled = each.value.resource_quota_enabled
  resource_quota         = each.value.resource_quota

  limit_range_enabled          = each.value.limit_range_enabled
  limit_range_defaults         = each.value.limit_range_defaults
  limit_range_default_requests = each.value.limit_range_default_requests

  network_policy_enabled = each.value.network_policy_enabled
  role_assignments       = each.value.role_assignments

  tags = local.common_tags

  depends_on = [module.aks]
}

module "ado_agents" {
  source = "./modules/ado-agents"

  aks_oidc_issuer_url       = module.aks.oidc_issuer_url
  ado_agent_client_id       = module.workload_identity.ado_agent_client_id
  ado_agent_namespace       = var.ado_agent_namespace
  ado_agent_service_account = var.ado_agent_service_account

  azure_tenant_id   = data.azurerm_client_config.current.tenant_id
  ado_org_url       = var.ado_org_url
  ado_pool_name     = var.ado_pool_name

  agent_replicas_min = var.ado_agent_min_replicas
  agent_replicas_max = var.ado_agent_max_replicas

  tags = local.common_tags

  depends_on = [module.aks, module.workload_identity]
}
