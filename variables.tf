# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, uat, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, uat, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus2"
}

variable "location_short" {
  description = "Short code for Azure region (e.g. eus2)."
  type        = string
  default     = "eus2"
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS system/app workloads subnet."
  type        = string
  default     = "10.0.0.0/20"
}

variable "aks_agents_subnet_cidr" {
  description = "CIDR for the AKS agents (ADO build agents) subnet."
  type        = string
  default     = "10.0.16.0/22"
}

# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------
variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.30"
}

variable "network_plugin" {
  description = "Network plugin for AKS (azure or kubenet)."
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy for AKS (azure, calico, or cilium)."
  type        = string
  default     = "azure"
}

variable "aks_service_cidr" {
  description = "Service CIDR for AKS cluster."
  type        = string
  default     = "172.16.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS service IP for AKS cluster (must be within service_cidr)."
  type        = string
  default     = "172.16.0.10"
}

variable "aks_sku_tier" {
  description = "SKU tier for AKS cluster (Free, Standard, Premium)."
  type        = string
  default     = "Standard"
}

variable "private_cluster_enabled" {
  description = "Enable private cluster (API server not exposed to internet)."
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy addon for the AKS cluster."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of Log Analytics workspace for monitoring. Set to null to disable."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# System Node Pool
# -----------------------------------------------------------------------------
variable "system_node_pool_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "system_node_pool_min_count" {
  description = "Minimum node count for system node pool autoscaler."
  type        = number
  default     = 2
}

variable "system_node_pool_max_count" {
  description = "Maximum node count for system node pool autoscaler."
  type        = number
  default     = 5
}

variable "system_node_pool_node_count" {
  description = "Initial node count for the system node pool."
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Application Node Pool
# -----------------------------------------------------------------------------
variable "app_node_pool_enabled" {
  description = "Whether to create a dedicated application node pool."
  type        = bool
  default     = true
}

variable "app_node_pool_vm_size" {
  description = "VM size for the application node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "app_node_pool_min_count" {
  description = "Minimum node count for app node pool autoscaler."
  type        = number
  default     = 2
}

variable "app_node_pool_max_count" {
  description = "Maximum node count for app node pool autoscaler."
  type        = number
  default     = 10
}

variable "app_node_pool_node_count" {
  description = "Initial node count for the application node pool."
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Agents Node Pool (Azure DevOps)
# -----------------------------------------------------------------------------
variable "agents_node_pool_vm_size" {
  description = "VM size for the ADO agents node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "agents_node_pool_min_count" {
  description = "Minimum node count for agents node pool autoscaler."
  type        = number
  default     = 0
}

variable "agents_node_pool_max_count" {
  description = "Maximum node count for agents node pool autoscaler."
  type        = number
  default     = 10
}

variable "agents_node_pool_node_count" {
  description = "Initial node count for the agents node pool."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Application Workloads (shared cluster onboarding)
# -----------------------------------------------------------------------------
variable "app_workloads" {
  description = <<-EOT
    Map of applications to onboard onto the shared cluster. Each entry creates:
    - Kubernetes namespace
    - Managed identity with workload identity federation
    - Service account annotated for workload identity
    - Optional: resource quotas, limit ranges, network policies, Azure role assignments

    Example:
      app_workloads = {
        api = {
          namespace            = "api"
          service_account_name = "api-sa"
        }
        web = {
          namespace              = "web-frontend"
          service_account_name   = "web-sa"
          resource_quota_enabled = true
          network_policy_enabled = true
        }
      }
  EOT

  type = map(object({
    namespace              = string
    service_account_name   = optional(string, "app-sa")
    namespace_labels       = optional(map(string), {})
    resource_quota_enabled = optional(bool, false)
    resource_quota         = optional(map(string), {
      "requests.cpu"    = "4"
      "requests.memory" = "8Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "16Gi"
      "pods"            = "20"
    })
    limit_range_enabled          = optional(bool, false)
    limit_range_defaults         = optional(map(string), { cpu = "500m", memory = "512Mi" })
    limit_range_default_requests = optional(map(string), { cpu = "100m", memory = "128Mi" })
    network_policy_enabled       = optional(bool, false)
    role_assignments             = optional(map(object({
      scope = string
      role  = string
    })), {})
  }))

  default = {}
}

# -----------------------------------------------------------------------------
# Azure DevOps Agents
# -----------------------------------------------------------------------------
variable "ado_org_url" {
  description = "Azure DevOps organization URL (e.g. https://dev.azure.com/myorg)."
  type        = string
}

variable "ado_pool_name" {
  description = "Azure DevOps agent pool name."
  type        = string
  default     = "aks-agents"
}

variable "ado_agent_namespace" {
  description = "Kubernetes namespace for ADO agents."
  type        = string
  default     = "ado-agents"
}

variable "ado_agent_service_account" {
  description = "Kubernetes service account name for ADO agents."
  type        = string
  default     = "ado-agent-sa"
}

variable "ado_agent_min_replicas" {
  description = "Minimum number of ADO agent replicas (KEDA scaled)."
  type        = number
  default     = 0
}

variable "ado_agent_max_replicas" {
  description = "Maximum number of ADO agent replicas (KEDA scaled)."
  type        = number
  default     = 10
}
