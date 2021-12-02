targetScope = 'subscription'

param vnetId string
param remoteVnetId string

var location = deployment().location

var regionCodeLookup = {
  australiaeast: 'aue'
  australiasoutheast: 'ase'
}
var shortLocation = regionCodeLookup[location]

resource rg_xRegionPeer 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: '${shortLocation}-xRegionPeer'
}

module dep_peer 'peer.bicep' = {
  name:  '${shortLocation}-vnet'
  scope: rg_xRegionPeer
  params: {
    vnetId: vnetId
    remoteVnetId: remoteVnetId
  }
}

output peerId string = dep_peer.outputs.peerId
