variable location {
    type = string
}

variable subscriptionName {
    type = string
}

variable subscriptionId {
    type = string
}

variable region {
    type = string
}

variable environment {
    type = string
}

variable vnetAddressSpace {
    type = string
}

variable subnetPrivateEndpointAddressSpace {
    type = string
}

variable subnetServiceAddressSpace {
    type = string
}

variable privateEndpointIpAddress {
    type = string
}

variable tagsNetwork {
    type = map(string)
}

variable admin {
    type = string
}

variable adminPassword {
    type      = string
    sensitive = true
}

variable tagsService {
    type = map(string)
}