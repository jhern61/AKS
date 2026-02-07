variable "app_name" {
  description = "Application name, used in resource naming."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the application."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL from the AKS cluster."
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name for the app."
  type        = string
  default     = "app-sa"
}

variable "namespace_labels" {
  description = "Additional labels to apply to the namespace."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Resource Quotas
# -----------------------------------------------------------------------------
variable "resource_quota_enabled" {
  description = "Whether to create a resource quota for the namespace."
  type        = bool
  default     = false
}

variable "resource_quota" {
  description = "Hard resource quota limits (e.g. requests.cpu, requests.memory, pods)."
  type        = map(string)
  default = {
    "requests.cpu"    = "4"
    "requests.memory" = "8Gi"
    "limits.cpu"      = "8"
    "limits.memory"   = "16Gi"
    "pods"            = "20"
  }
}

# -----------------------------------------------------------------------------
# Limit Ranges
# -----------------------------------------------------------------------------
variable "limit_range_enabled" {
  description = "Whether to create a limit range with default requests/limits."
  type        = bool
  default     = false
}

variable "limit_range_defaults" {
  description = "Default container limits."
  type        = map(string)
  default = {
    cpu    = "500m"
    memory = "512Mi"
  }
}

variable "limit_range_default_requests" {
  description = "Default container requests."
  type        = map(string)
  default = {
    cpu    = "100m"
    memory = "128Mi"
  }
}

# -----------------------------------------------------------------------------
# Network Policy
# -----------------------------------------------------------------------------
variable "network_policy_enabled" {
  description = "Whether to create default-deny + allow-same-namespace network policies."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Role Assignments
# -----------------------------------------------------------------------------
variable "role_assignments" {
  description = "Map of Azure role assignments for the app managed identity."
  type = map(object({
    scope = string
    role  = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
