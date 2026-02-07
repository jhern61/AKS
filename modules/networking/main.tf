# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aks_subnet_cidr]
}

resource "azurerm_subnet" "aks_agents" {
  name                 = "snet-aks-agents-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aks_agents_subnet_cidr]
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "aks_agents" {
  name                = "nsg-aks-agents-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# NSG Associations
# -----------------------------------------------------------------------------
resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_subnet_network_security_group_association" "aks_agents" {
  subnet_id                 = azurerm_subnet.aks_agents.id
  network_security_group_id = azurerm_network_security_group.aks_agents.id
}
