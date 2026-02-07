# -----------------------------------------------------------------------------
# Managed Identity for Azure DevOps Agents
# -----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "ado_agent" {
  name                = "id-ado-agent-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Federated Credential — binds the managed identity to a K8s service account
# via OIDC (workload identity federation)
# -----------------------------------------------------------------------------
resource "azurerm_federated_identity_credential" "ado_agent" {
  name                = "fc-ado-agent-${var.environment}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.ado_agent.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.aks_oidc_issuer_url
  subject             = "system:serviceaccount:${var.ado_agent_namespace}:${var.ado_agent_service_account}"
}
