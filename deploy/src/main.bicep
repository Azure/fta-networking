targetScope = 'subscription'

param location string = 'australiacentral'

// Lookup region code based on location parameter
var regionCodeLookup = {
  australiacentral: 'auc'
  australiaeast: 'aue'
  australiasoutheast: 'ase'
}
var shortLocation = regionCodeLookup[location]

// Lookup region prefix based on location parameter
var regionPrefixLookup = {
  australiacentral: '10.0.0.0/16'
  australiaeast: '10.1.0.0/16'
  australiasoutheast: '10.2.0.0/16'
}
var regionAddressPrefix = regionPrefixLookup[location]

// Get the needed octets to handle different address spaces for each region
var octet1 = int(split(regionAddressPrefix, '.')[0])
var octet2 = int(split(regionAddressPrefix, '.')[1])

// Declarativley define the hub vnet
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
    routeThroughFirewallToSpokes: true
    routeThroughFirewallToGateway: true
  }
  vmSubnet2: {
    name: 'VmSubnet2'
    prefix: '${octet1}.${octet2}.3.144/28'
    routeThroughFirewallToSpokes: true
    routeThroughFirewallToGateway: true
  }
}

/*
  Choose to use either the Nva or Azure firewall:
    var routeTableNextHopIpAddress = hubVnet.azureFirewallSubnet.lbIpAddress //<-- use Azure Firewall
    var routeTableNextHopIpAddress = hubVnet.nvaSubnetInternal.lbIpAddress //<-- use Nva firewall
*/
var routeTableNextHopIpAddress = hubVnet.azureFirewallSubnet.lbIpAddress //<-- use Azure Firewall

/* 
  Track each spoke vnets:
    This is used to determine route table entries and not used 
    to create spoke vnets. Update this list each time a new spoke 
    is created or known to be created in the future.
    This allows separation of responsibilities between hub administrators
    and spoke administrators / developers / business units.
*/
var regionSpokes = [
  {
    name: '${shortLocation}-spoke1'
    prefix: '${octet1}.${octet2}.4.0/24'
    peerToHub: true
  }
  {
    name: '${shortLocation}-spoke2'
    prefix: '${octet1}.${octet2}.5.0/25'
    peerToHub: true
  }
  {
    name: '${shortLocation}-spoke3'
    prefix: '${octet1}.${octet2}.5.128/26'
    peerToHub: true
  }
  {
    name: '${shortLocation}-spokeN'
    prefix: '${octet1}.${octet2}.255.0/24'
    peerToHub: true
  }
]

// Create core resource group
resource rgCoreNet 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${shortLocation}-core-net'
  location: location
}

// Deploy core networking resources
module depCoreNet 'core-net/main.bicep' = {
  name: '${rgCoreNet.name}'
  scope: rgCoreNet
  params: {
    shortLocation: shortLocation
    regionAddressPrefix: regionAddressPrefix
    regionSpokes: regionSpokes
  }
}

// Add Azure Bastion
module depCoreNetBastion 'core-net-bastion/main.bicep' = {
  name: '${rgCoreNet.name}'
  scope: rgCoreNet
  params: {
    shortLocation: shortLocation
    vnetId: depCoreNet.outputs.vnetHubId
  }
}

// Add Azure Firewall
module depCoreNetFirewall 'core-net-firewall/main.bicep' = {
  name: '${rgCoreNet.name}'
  scope: rgCoreNet
  params: {
    shortLocation: shortLocation
    vnetId: depCoreNet.outputs.vnetHubId
  }
}
