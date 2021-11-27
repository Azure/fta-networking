param net_nva_id string
param net_spoke1_id string
param net_spoke2_id string

resource existing_net_nva  'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: last(split(net_nva_id,'/'))
}

resource existing_net_spoke1 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: last(split(net_spoke1_id,'/'))
}

resource existing_net_spoke2 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: last(split(net_spoke2_id,'/'))
}

resource peer_nvaTOspoke1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${existing_net_nva.name}-TO-${existing_net_spoke1.name}'
  parent: existing_net_nva
  properties: {
    remoteVirtualNetwork: {
      id: existing_net_spoke1.id
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
  }
}

resource peer_spoke1TOnva 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${existing_net_spoke1.name}-TO-${existing_net_nva.name}'
  parent: existing_net_spoke1
  properties: {
    remoteVirtualNetwork: {
      id: existing_net_nva.id
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
  }
}

resource peer_nvaTOspoke2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${existing_net_nva.name}-TO-${existing_net_spoke2.name}'
  parent: existing_net_nva
  properties: {
    remoteVirtualNetwork: {
      id: existing_net_spoke2.id
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
  }
}
resource peer_spoke2TOnva 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${existing_net_spoke2.name}-TO-${existing_net_nva.name}'
  parent: existing_net_spoke2
  properties: {
    remoteVirtualNetwork: {
      id: existing_net_nva.id
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
  }
}

output rg_id string = resourceGroup().id
