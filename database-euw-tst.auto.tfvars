location = "westeurope"
subscriptionName = "database"
subscriptionId = "ea4943ca-3f1f-4a8c-acbe-6ee76843df3a"
region = "euw"
environment = "tst"
vnetAddressSpace = "10.136.16.0/24"
subnetPrivateEndpointAddressSpace = "10.136.16.0/27"
subnetServiceAddressSpace = "10.136.16.32/27"
privateEndpointIpAddress = "10.136.16.4"
tagsNetwork = {
	WorkloadName             = "Network"
    TechTeam                 = "IT-SyNW"
    OpsTeam                  = "IT-SyNW"
}

admin = "sqldatadmin"
adminPassword = "P+Nmb#WpM3jG"
tagsService = {
	WorkloadName             = "SQL Server"
    TechTeam                 = "IT-DAT"
    OpsTeam                  = "IT-DAT"
}