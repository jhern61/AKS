variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL from the AKS cluster."
  type        = string
}

variable "ado_agent_client_id" {
  description = "Client ID of the managed identity for ADO agents."
  type        = string
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

variable "azure_tenant_id" {
  description = "Azure AD tenant ID for workload identity federation."
  type        = string
}

variable "ado_org_url" {
  description = "Azure DevOps organization URL."
  type        = string
}

variable "ado_pool_name" {
  description = "Azure DevOps agent pool name."
  type        = string
  default     = "aks-agents"
}

variable "agent_replicas_min" {
  description = "Minimum number of agent replicas (KEDA)."
  type        = number
  default     = 0
}

variable "agent_replicas_max" {
  description = "Maximum number of agent replicas (KEDA)."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
