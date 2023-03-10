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

# Private Endpoint
resource "azapi_resource" "privateEndpoint" {
  depends_on = [azurerm_mssql_server.sqlServer]
  tags       = var.tagsNetwork
  name       = "${azurerm_mssql_server.sqlServer.name}-pe"
  location   = var.location
  parent_id  = azurerm_resource_group.resourceGroupNetwork.id
  type       = "Microsoft.Network/privateEndpoints@2022-05-01"
  body       = jsonencode({
    properties = {
      customNetworkInterfaceName = "${azurerm_mssql_server.sqlServer.name}-pe-nic"
      ipConfigurations = [
        {
          name = "default"
          properties = {
            groupId = "sqlServer"
            memberName = "sqlServer"
            privateIPAddress = "${var.privateEndpointIpAddress}"
          }
        }
      ]
      privateLinkServiceConnections = [
        {
          id = "${azurerm_mssql_server.sqlServer.id}"
          name = "${azurerm_mssql_server.sqlServer.name}-psc"
          properties = {
            groupIds = [
              "sqlServer"
            ]
            privateLinkServiceId = "${azurerm_mssql_server.sqlServer.id}"
          }
        }
      ]
      subnet = {
        id = "${azurerm_subnet.subnetPrivateEndpoint.id}"
      }
    }
  })
}

# RG Service
resource "azurerm_resource_group" "resourceGroupService" {
  tags     = var.tagsService
  name     = "rg-${var.subscriptionName}-sql-${var.region}-${var.environment}"
  location = var.location
}

# SQL Server
resource "azurerm_mssql_server" "sqlServer" {
  tags                          = var.tagsService
  name                          = "sql-tbu09-${var.region}-${var.environment}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.resourceGroupService.name
  version                       = "12.0"
  administrator_login           = "${var.admin}"
  administrator_login_password  = "${var.adminPassword}"
  minimum_tls_version           = "1.2"
  connection_policy             = "Default"
  public_network_access_enabled = false

  azuread_administrator {
    login_username              = "O_AZURE_DATABASE_OPERATOR-AZ"
    object_id                   = "29ff9cd0-891f-45de-9c95-522ef28771c9"
    azuread_authentication_only = false
  }

  identity {
    type = "SystemAssigned"
  }
}

# SQL Database
resource "azurerm_mssql_database" "sqlDatabase" {
  depends_on           = [azurerm_mssql_server.sqlServer]
  tags                 = var.tagsService
  name                 = "sqldb-tbu09-${var.region}-${var.environment}"
  server_id            = azurerm_mssql_server.sqlServer.id
  collation            = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  create_mode          = "Default"
  license_type         = "BasePrice"
  max_size_gb          = 20
  read_scale           = false
  sku_name             = "S1"
  zone_redundant       = false
  storage_account_type = "Zone"

  threat_detection_policy {
    state = "Disabled"
  }

  short_term_retention_policy { 
    retention_days           = 7
    backup_interval_in_hours = 24
  }
}