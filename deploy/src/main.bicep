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

/* 
  IMPORTANT
    Update this list each time a new spoke is created
*/
var regionSpokes = [
  {
    name: '${shortLocation}-spoke1'
    prefix: '${octet1}.${octet2}.4.0/24'
    isStandalone: false
  }
  {
    name: '${shortLocation}-spoke2'
    prefix: '${octet1}.${octet2}.5.0/25'
    isStandalone: false
  }
  {
    name: '${shortLocation}-spoke3'
    prefix: '${octet1}.${octet2}.5.128/26'
    isStandalone: false
  }
  {
    name: '${shortLocation}-spokeN'
    prefix: '${octet1}.${octet2}.255.0/24'
    isStandalone: false
  }
]

// Create core resource groups and update their deployment
resource rgCoreNet 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${shortLocation}-core-net'
  location: location
}

module depCoreNet 'core-net/main.bicep' = {
  name: '${rgCoreNet.name}'
  scope: rgCoreNet
  params: {
    shortLocation: shortLocation
    regionAddressPrefix: regionAddressPrefix
    regionSpokes: regionSpokes
  }
}

resource rgCoreNetBastion 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${shortLocation}-core-net-bastion'
  location: location
  dependsOn: [
    depCoreNet
  ]
}

module depCoreNetBastion 'core-net-bastion/main.bicep' = {
  name: '${rgCoreNetBastion.name}'
  scope: rgCoreNetBastion
  params: {
    shortLocation: shortLocation
    vnetId: depCoreNet.outputs.vnetHubId
  }
}
