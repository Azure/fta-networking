// Resource declaration in Bicep
// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/resource-declaration

param shortLocation string
param regionAddressPrefix string
param regionSpokes array

// Determine the location based on the resource group
var location = resourceGroup().location

// Get the needed octets to handle different address spaces for each region
var octet1 = int(split(regionAddressPrefix, '.')[0])
var octet2 = int(split(regionAddressPrefix, '.')[1])

var hubVnet = {
  name: '${shortLocation}-hub'
  prefixes: [
    '${octet1}.${octet2}.0.0/22'
  ]
  gatewaySubnet: {
    prefix: '${octet1}.${octet2}.0.0/24'
  }
  azureFirewallSubnet: {
    prefix: '${octet1}.${octet2}.1.0/26'
    lbIpAddress: '${octet1}.${octet2}.1.4' // the first available ip address in this subnet
  }
  azureFirewallManagementSubnet: {
    prefix: '${octet1}.${octet2}.1.64/26'
  }
  nvaSubnetManagement: {
    name: 'NvaSubnetManagement'
    prefix: '${octet1}.${octet2}.1.128/28'
  }
  nvaSubnetDiagnostic: {
    name: 'NvaSubnetDiagnostic'
    prefix: '${octet1}.${octet2}.1.144/28'
  }
  nvaSubnetInternal: {
    name: 'NvaSubnetInternal'
    prefix: '${octet1}.${octet2}.1.160/28'
    lbIpAddress: '${octet1}.${octet2}.1.174' // the last available ip address in this subnet
  }
  nvaSubnetPublic: {
    name: 'NvaSubnetPublic'
    prefix: '${octet1}.${octet2}.1.176/28'
  }
  azureBastionSubnet: {
    prefix: '${octet1}.${octet2}.1.192/27'
  }
  routeServerSubnet: {
    prefix: '${octet1}.${octet2}.1.224/27'
  }
  applicationGatewaySubnet1: {
    name: 'ApplicationGatewaySubnet1'
    prefix: '${octet1}.${octet2}.2.0/25'
  }
  applicationGatewaySubnet2: {
    name: 'ApplicationGatewaySubnet2'
    prefix: '${octet1}.${octet2}.2.128/25'
  }
  applicationGatewaySubnet3: {
    name: 'ApplicationGatewaySubnet3'
    prefix: '${octet1}.${octet2}.3.0/25'
  }
  vmSubnet1: {
    name: 'VmSubnet1'
    prefix: '${octet1}.${octet2}.3.128/28'
  }
  vmSubnet2: {
    name: 'VmSubnet2'
    prefix: '${octet1}.${octet2}.3.144/28'
  }
}

/* 
  IMPORTANT
    Add any vm subnets from the hub that need to route through the firewall 
     to this list.
*/
var hubVmSubnets = [
  {
    name: hubVnet.vmSubnet1.name
    prefix: hubVnet.vmSubnet1.prefix
    isStandalone: false
  }
  {
    name: hubVnet.vmSubnet2.name
    prefix: hubVnet.vmSubnet2.prefix
    isStandalone: false
  }
]

/*
  Choose to use either the Nva or Azure firewall:
    var routeTableNextHopIpAddress = hubVnet.azureFirewallSubnet.lbIpAddress //<-- use Azure Firewall
    var routeTableNextHopIpAddress = hubVnet.nvaSubnetInternal.lbIpAddress //<-- use Nva firewall
*/
var routeTableNextHopIpAddress = hubVnet.azureFirewallSubnet.lbIpAddress //<-- use Azure Firewall

// Use the information provided so far to determine route table entries
var routesDefault = [
  {
    name: 'default'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: routeTableNextHopIpAddress
    }
  }
]
var routesHubVmSubnets = [for destination in hubVmSubnets: {
  name: 'to-${toUpper(hubVnet.name)}-${toUpper(destination.name)}-subnet'
  properties: {
    addressPrefix: destination.prefix
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: routeTableNextHopIpAddress
  }
}]
var routesSpokeVnets = [for destination in regionSpokes: {
  name: 'to-${toUpper(destination.name)}-vnet'
  properties: {
    addressPrefix: destination.prefix
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: routeTableNextHopIpAddress
  }
}]

// Create hub network security groups
resource nsg_hubVnetNvaSubnetManagement 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.nvaSubnetManagement.name}-nsg'
}
resource nsg_hubVnetNvaSubnetDiagnostic 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.nvaSubnetDiagnostic.name}-nsg'
}
resource nsg_hubVnetNvaSubnetInternal 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.nvaSubnetInternal.name}-nsg'
  properties: {
    securityRules: [
      {
        name: 'Allow-Inbound-RFC1918'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 1000
          protocol: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          sourcePortRange: '*'
        }
      }
    ]
  }
}
resource nsg_hubVnetNvaSubnetPublic 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.nvaSubnetPublic.name}-nsg'
  properties: {
    securityRules: [
      {
        name: 'Allow-Inbound-All'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          priority: 1000
          protocol: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}
resource nsg_hubVnetVmSubnet1 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.vmSubnet1.name}-nsg'
}
resource nsg_hubVnetVmSubnet2 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.vmSubnet2.name}-nsg'
}

// Create a template network security group for spokes
resource nsg_spokeTemplate 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: '${shortLocation}-spoke-vnet-nsg'
}

// Create hub route tables
resource rt_hubVnetGatewaySubnet 'Microsoft.Network/routeTables@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-GatewaySubnet-rt'
  properties: {
    disableBgpRoutePropagation: false // must be false for the GatewaySubnet
    routes: concat(routesSpokeVnets, routesHubVmSubnets) // define all routes except for 'default'
  }
}

var filteredRoutes1 = [for route in routesHubVmSubnets: (route.properties.addressPrefix != hubVnet.vmSubnet1.prefix) ? route : routesDefault[0]]
resource rt_hubVnetVmSubnet1 'Microsoft.Network/routeTables@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.vmSubnet1.name}-rt'
  properties: {
    disableBgpRoutePropagation: true // must be true
    routes: union(concat(routesSpokeVnets, filteredRoutes1), routesDefault) // define all routes except for its own subnet 
  }
}

var filteredRoutes2 = [for route in routesHubVmSubnets: (route.properties.addressPrefix != hubVnet.vmSubnet2.prefix) ? route : routesDefault[0]]
resource rt_hubVnetVmSubnet2 'Microsoft.Network/routeTables@2021-02-01' = {
  location: location
  name: '${shortLocation}-hub-${hubVnet.vmSubnet2.name}-rt'
  properties: {
    disableBgpRoutePropagation: true // must be true
    routes: union(concat(routesSpokeVnets, filteredRoutes2), routesDefault) // define all routes except for its own subnet
  }
}

// Create a template route table for spokes
resource rt_spokeTemplate 'Microsoft.Network/routeTables@2021-02-01' = {
  location: location
  name: '${shortLocation}-spoke-vnet-rt'
  properties: {
    disableBgpRoutePropagation: true // must be true
    routes: concat(routesDefault, routesHubVmSubnets) // only need to define 'default' route and any vm subnets in the hub
  }
}

// Create hub virtual network
resource vnet_hub 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  location: location
  name: hubVnet.name
  properties: {
    addressSpace: {
      addressPrefixes: hubVnet.prefixes
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: hubVnet.gatewaySubnet.prefix
          routeTable: {
            id: rt_hubVnetGatewaySubnet.id
          }
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: hubVnet.azureFirewallSubnet.prefix
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: hubVnet.azureFirewallManagementSubnet.prefix
        }
      }
      {
        name: hubVnet.nvaSubnetManagement.name
        properties: {
          addressPrefix: hubVnet.nvaSubnetManagement.prefix
          networkSecurityGroup: {
            id: nsg_hubVnetNvaSubnetManagement.id
          }
        }
      }
      {
        name: hubVnet.nvaSubnetDiagnostic.name
        properties: {
          addressPrefix: hubVnet.nvaSubnetDiagnostic.prefix
          networkSecurityGroup: {
            id: nsg_hubVnetNvaSubnetDiagnostic.id
          }
        }
      }
      {
        name: hubVnet.nvaSubnetInternal.name
        properties: {
          addressPrefix: hubVnet.nvaSubnetInternal.prefix
          networkSecurityGroup: {
            id: nsg_hubVnetNvaSubnetInternal.id
          }
        }
      }
      {
        name: hubVnet.nvaSubnetPublic.name
        properties: {
          addressPrefix: hubVnet.nvaSubnetPublic.prefix
          networkSecurityGroup: {
            id: nsg_hubVnetNvaSubnetPublic.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: hubVnet.azureBastionSubnet.prefix
        }
      }
      {
        name: 'RouteServerSubnet'
        properties: {
          addressPrefix: hubVnet.routeServerSubnet.prefix
        }
      }
      {
        name: hubVnet.applicationGatewaySubnet1.name
        properties: {
          addressPrefix: hubVnet.applicationGatewaySubnet1.prefix
        }
      }
      {
        name: hubVnet.applicationGatewaySubnet2.name
        properties: {
          addressPrefix: hubVnet.applicationGatewaySubnet2.prefix
        }
      }
      {
        name: hubVnet.applicationGatewaySubnet3.name
        properties: {
          addressPrefix: hubVnet.applicationGatewaySubnet3.prefix
        }
      }
      {
        name: hubVnet.vmSubnet1.name
        properties: {
          addressPrefix: hubVnet.vmSubnet1.prefix
          networkSecurityGroup: {
            id: nsg_hubVnetVmSubnet1.id
          }
          routeTable: {
            id: rt_hubVnetVmSubnet1.id
          }
        }
      }
      {
        name: hubVnet.vmSubnet2.name
        properties: {
          addressPrefix: hubVnet.vmSubnet2.prefix
          networkSecurityGroup: {
            id: nsg_hubVnetVmSubnet2.id
          }
          routeTable: {
            id: rt_hubVnetVmSubnet2.id
          }
        }
      }
    ]
  }
}

output vnetHubId string = vnet_hub.id
