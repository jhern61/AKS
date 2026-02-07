variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL from the AKS cluster."
  type        = string
}

variable "ado_agent_namespace" {
  description = "Kubernetes namespace for ADO agents."
  type        = string
}

variable "ado_agent_service_account" {
  description = "Kubernetes service account name for ADO agents."
  type        = string
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
