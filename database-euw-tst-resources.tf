# RG Network
resource "azurerm_resource_group" "resourceGroupNetwork" {
  tags     = var.tagsNetwork
  name     = "rg-${var.subscriptionName}-network-${var.region}-${var.environment}"
  location = var.location
}

# Network Watcher
resource "azurerm_network_watcher" "networkWatcher" {
  tags                = var.tagsNetwork
  name                = "nw-${var.subscriptionName}-${var.region}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourceGroupNetwork.name
}

# Network Security Group
resource "azurerm_network_security_group" "networkSecurityGroup" {
  tags                = var.tagsNetwork
  name                = "nsg-${var.subscriptionName}-${var.region}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourceGroupNetwork.name
}

# Route Table
resource "azurerm_route_table" "routeTable" {
  tags                          = var.tagsNetwork
  name                          = "rt-${var.subscriptionName}-${var.region}-${var.environment}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.resourceGroupNetwork.name
  disable_bgp_route_propagation = true
}

# Virtual Network
resource "azurerm_virtual_network" "virtualNetwork" {
  tags                = var.tagsNetwork
  name                = "vnet-${var.subscriptionName}-${var.region}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourceGroupNetwork.name
  address_space       = ["${var.vnetAddressSpace}"]
  dns_servers         = ["10.136.254.68"]
}

# Subnets
resource "azurerm_subnet" "subnetPrivateEndpoint" {
  depends_on                                = [azurerm_virtual_network.virtualNetwork, azurerm_route_table.routeTable, azurerm_network_security_group.networkSecurityGroup]
  name                                      = "snet-${var.subscriptionName}-privateendpoint-${var.environment}"
  resource_group_name                       = azurerm_resource_group.resourceGroupNetwork.name
  virtual_network_name                      = azurerm_virtual_network.virtualNetwork.name
  address_prefixes                          = ["${var.subnetPrivateEndpointAddressSpace}"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "subnetService" {
  depends_on           = [azurerm_virtual_network.virtualNetwork, azurerm_route_table.routeTable, azurerm_network_security_group.networkSecurityGroup]
  name                 = "snet-${var.subscriptionName}-sql-${var.environment}"
  resource_group_name  = azurerm_resource_group.resourceGroupNetwork.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork.name
  address_prefixes     = ["${var.subnetServiceAddressSpace}"]
}

# Subnet & Network Security Group Associations
resource "azurerm_subnet_network_security_group_association" "subnetPrivateEndpointNetworkSecurityGroupAssociation" {
  depends_on                = [azurerm_subnet.subnetPrivateEndpoint, azurerm_network_security_group.networkSecurityGroup]
  subnet_id                 = azurerm_subnet.subnetPrivateEndpoint.id
  network_security_group_id = azurerm_network_security_group.networkSecurityGroup.id
}

resource "azurerm_subnet_network_security_group_association" "subnetServiceNetworkSecurityGroupAssociation" {
  depends_on                = [azurerm_subnet.subnetService, azurerm_network_security_group.networkSecurityGroup]
  subnet_id                 = azurerm_subnet.subnetService.id
  network_security_group_id = azurerm_network_security_group.networkSecurityGroup.id
}

# Subnet & Route Table Associations
resource "azurerm_subnet_route_table_association" "subnetPrivateEndpointRouteTableAssociation" {
  depends_on     = [azurerm_subnet.subnetPrivateEndpoint, azurerm_route_table.routeTable]
  subnet_id      = azurerm_subnet.subnetPrivateEndpoint.id
  route_table_id = azurerm_route_table.routeTable.id
}

resource "azurerm_subnet_route_table_association" "subnetServiceRouteTableAssociation" {
  depends_on     = [azurerm_subnet.subnetService, azurerm_route_table.routeTable]
  subnet_id      = azurerm_subnet.subnetService.id
  route_table_id = azurerm_route_table.routeTable.id
}