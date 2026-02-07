# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  private_cluster_enabled = var.private_cluster_enabled

  # Workload Identity & OIDC
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  # Network profile
  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  # System identity for the cluster
  identity {
    type = "SystemAssigned"
  }

  # System node pool
  default_node_pool {
    name                 = "system"
    vm_size              = var.system_node_pool_vm_size
    vnet_subnet_id       = var.vnet_subnet_id
    min_count            = var.system_node_pool_min_count
    max_count            = var.system_node_pool_max_count
    node_count           = var.system_node_pool_node_count
    auto_scaling_enabled = true
    os_disk_type         = "Managed"
    os_sku               = "AzureLinux"
    zones                = ["1", "2", "3"]

    node_labels = {
      "nodepool-type" = "system"
    }

    upgrade_settings {
      max_surge = "33%"
    }
  }

  # KEDA addon
  dynamic "workload_autoscaler_profile" {
    for_each = var.keda_enabled ? [1] : []
    content {
      keda_enabled = true
    }
  }

  # Azure Policy addon
  azure_policy_enabled = var.azure_policy_enabled

  # Monitoring
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Auto-upgrade channel
  automatic_upgrade_channel = "patch"

  # Maintenance window for patches
  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "-06:00"
    duration    = 4
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

# -----------------------------------------------------------------------------
# Application Node Pool
# -----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "app" {
  count = var.app_node_pool_enabled ? 1 : 0

  name                  = "app"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.app_node_pool_vm_size
  vnet_subnet_id        = var.vnet_subnet_id
  min_count             = var.app_node_pool_min_count
  max_count             = var.app_node_pool_max_count
  node_count            = var.app_node_pool_node_count
  auto_scaling_enabled  = true
  os_disk_type          = "Managed"
  os_sku                = "AzureLinux"
  zones                 = ["1", "2", "3"]
  mode                  = "User"

  node_labels = {
    "nodepool-type" = "application"
    "workload"      = "app"
  }

  node_taints = []

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}

# -----------------------------------------------------------------------------
# Agents Node Pool (Azure DevOps build agents — scales to zero via KEDA)
# -----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "agents" {
  name                  = "agents"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.agents_node_pool_vm_size
  vnet_subnet_id        = var.agents_subnet_id
  min_count             = var.agents_node_pool_min_count
  max_count             = var.agents_node_pool_max_count
  node_count            = var.agents_node_pool_node_count
  auto_scaling_enabled  = true
  os_disk_type          = "Managed"
  os_sku                = "AzureLinux"
  zones                 = ["1", "2", "3"]
  mode                  = "User"

  node_labels = {
    "nodepool-type" = "agents"
    "workload"      = "ado-agent"
  }

  node_taints = ["workload=ado-agent:NoSchedule"]

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}

# -----------------------------------------------------------------------------
# Role assignment: AKS cluster identity → Network Contributor on subnets
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_network_contributor_agents" {
  scope                = var.agents_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}
