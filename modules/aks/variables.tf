variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
}

variable "sku_tier" {
  description = "SKU tier (Free, Standard, Premium)."
  type        = string
  default     = "Standard"
}

variable "private_cluster_enabled" {
  description = "Enable private cluster."
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer for workload identity."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable workload identity."
  type        = bool
  default     = true
}

variable "keda_enabled" {
  description = "Enable KEDA workload autoscaler."
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy addon."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
variable "vnet_subnet_id" {
  description = "Subnet ID for system and app node pools."
  type        = string
}

variable "agents_subnet_id" {
  description = "Subnet ID for the agents node pool."
  type        = string
}

variable "network_plugin" {
  description = "Network plugin (azure or kubenet)."
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy (azure, calico, cilium)."
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "Service CIDR for the cluster."
  type        = string
}

variable "dns_service_ip" {
  description = "DNS service IP."
  type        = string
}

# -----------------------------------------------------------------------------
# System Node Pool
# -----------------------------------------------------------------------------
variable "system_node_pool_vm_size" {
  description = "VM size for system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "system_node_pool_min_count" {
  description = "Min nodes for system pool autoscaler."
  type        = number
  default     = 2
}

variable "system_node_pool_max_count" {
  description = "Max nodes for system pool autoscaler."
  type        = number
  default     = 5
}

variable "system_node_pool_node_count" {
  description = "Initial node count for system pool."
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Application Node Pool
# -----------------------------------------------------------------------------
variable "app_node_pool_enabled" {
  description = "Whether to create an application node pool."
  type        = bool
  default     = true
}

variable "app_node_pool_vm_size" {
  description = "VM size for application node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "app_node_pool_min_count" {
  description = "Min nodes for app pool autoscaler."
  type        = number
  default     = 2
}

variable "app_node_pool_max_count" {
  description = "Max nodes for app pool autoscaler."
  type        = number
  default     = 10
}

variable "app_node_pool_node_count" {
  description = "Initial node count for app pool."
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Agents Node Pool
# -----------------------------------------------------------------------------
variable "agents_node_pool_vm_size" {
  description = "VM size for agents node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "agents_node_pool_min_count" {
  description = "Min nodes for agents pool autoscaler."
  type        = number
  default     = 0
}

variable "agents_node_pool_max_count" {
  description = "Max nodes for agents pool autoscaler."
  type        = number
  default     = 10
}

variable "agents_node_pool_node_count" {
  description = "Initial node count for agents pool."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Monitoring
# -----------------------------------------------------------------------------
variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
