param shortLocation string
param octet2 int

param net_nva_id string

resource connection_nva 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-08-01' = {
  name: '${shortLocation}/${last(split(net_nva_id,'/'))}'
  properties: {
    remoteVirtualNetwork: {
      id: net_nva_id
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: false
    routingConfiguration: {
      vnetRoutes: {
        staticRoutes: [
          {
            name: shortLocation
            addressPrefixes: [
              '10.${octet2}.0.0/16'
            ]
            nextHopIpAddress: '10.${octet2}.255.4'
          }         
        ]
      }
    }
  }
}

output rg_id string = resourceGroup().id
output connection_nva_id string = connection_nva.id
