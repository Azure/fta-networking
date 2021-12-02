targetScope = 'subscription'

var location = deployment().location

var regionCodeLookup = {
  australiaeast: 'aue'
  australiasoutheast: 'ase'
}
var shortLocation = regionCodeLookup[location]

var regionPrefixLookup = {
  australiaeast: '10.101.0.0/16'
  australiasoutheast: '10.102.0.0/16'
}
var regionAddressPrefix = regionPrefixLookup[location]

resource rg_xRegionPeer 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: '${shortLocation}-xRegionPeer'
}

module dep_vnet 'vnet.bicep' = {
  name:  '${shortLocation}-vnet'
  scope: rg_xRegionPeer
  params: {
    location: location
    shortLocation: shortLocation
    regionAddressPrefix: regionAddressPrefix
  }
}

output vnetId string = dep_vnet.outputs.vnetId
