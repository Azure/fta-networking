param vnetId string
param remoteVnetId string

var vnetName = last(split(vnetId, '/'))
var remoteVnetName = last(split(remoteVnetId, '/'))

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnetName
}

resource peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${vnetName}-TO-${remoteVnetName}'
  parent: vnet
  properties: {
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
  }
}

output peerId string = peer.id
