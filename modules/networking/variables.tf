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

variable "location_short" {
  description = "Short location code."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = list(string)
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS workloads subnet."
  type        = string
}

variable "aks_agents_subnet_cidr" {
  description = "CIDR for the AKS agents subnet."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
