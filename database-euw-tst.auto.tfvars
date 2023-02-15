location = "westeurope"
subscriptionName = "database"
subscriptionId = "cdf33668-8756-4368-833e-76f7cf7a525f"
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