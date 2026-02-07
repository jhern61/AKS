# -----------------------------------------------------------------------------
# Namespace for the application
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/name"       = var.app_name
        "environment"                  = var.environment
      },
      var.namespace_labels,
    )
  }
}

# -----------------------------------------------------------------------------
# Managed Identity for the application (workload identity)
# -----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.app_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Federated Credential — binds managed identity to K8s service account via OIDC
# -----------------------------------------------------------------------------
resource "azurerm_federated_identity_credential" "app" {
  name                = "fc-${var.app_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.app.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.aks_oidc_issuer_url
  subject             = "system:serviceaccount:${kubernetes_namespace.app.metadata[0].name}:${var.service_account_name}"
}

# -----------------------------------------------------------------------------
# Service Account with workload identity annotations
# -----------------------------------------------------------------------------
resource "kubernetes_service_account" "app" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.app.client_id
    }
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

# -----------------------------------------------------------------------------
# Resource Quota (optional — enforces CPU/memory/pod limits per namespace)
# -----------------------------------------------------------------------------
resource "kubernetes_resource_quota" "app" {
  count = var.resource_quota_enabled ? 1 : 0

  metadata {
    name      = "${var.app_name}-quota"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    hard = var.resource_quota
  }
}

# -----------------------------------------------------------------------------
# Limit Range (optional — sets default requests/limits for containers)
# -----------------------------------------------------------------------------
resource "kubernetes_limit_range" "app" {
  count = var.limit_range_enabled ? 1 : 0

  metadata {
    name      = "${var.app_name}-limits"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default = var.limit_range_defaults

      default_request = var.limit_range_default_requests
    }
  }
}

# -----------------------------------------------------------------------------
# Network Policy (optional — default-deny ingress, allow only within namespace)
# -----------------------------------------------------------------------------
resource "kubernetes_network_policy" "default_deny" {
  count = var.network_policy_enabled ? 1 : 0

  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {}

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_same_namespace" {
  count = var.network_policy_enabled ? 1 : 0

  metadata {
    name      = "allow-same-namespace"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {}

    ingress {
      from {
        pod_selector {}
      }
    }

    policy_types = ["Ingress"]
  }
}

# -----------------------------------------------------------------------------
# Role assignments (optional — grant the app identity access to Azure resources)
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "app" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
