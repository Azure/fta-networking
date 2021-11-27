param primaryRegionLocation string
param secondaryRegionLocation string 

param primaryRegionShortLocation string 
param secondaryRegionShortLocation string

param primaryRegionOctet2 int
param secondaryRegionOctet2 int

param net_nva_id_1 string
param net_nva_id_2 string

resource vwan 'Microsoft.Network/virtualWans@2020-11-01' = {
  name: 'au-vwan'
  location: primaryRegionLocation
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    type: 'Standard'
  }
}

module hub_1 'hub.bicep' = {
  name: 'hub-${primaryRegionShortLocation}'
  params: {
    location: primaryRegionLocation
    shortLocation: primaryRegionShortLocation
    octet2: primaryRegionOctet2
    vwan_id: vwan.id
  }
}
module hub_2 'hub.bicep' = {
  name: 'hub-${secondaryRegionShortLocation}'
  params: {
    location: secondaryRegionLocation
    shortLocation: secondaryRegionShortLocation
    octet2: secondaryRegionOctet2
    vwan_id: vwan.id
  }
}

module connections_1 'connections.bicep' = {
  name: 'connections-${primaryRegionShortLocation}'
  params: {
    shortLocation: primaryRegionShortLocation
    octet2: primaryRegionOctet2
    net_nva_id: net_nva_id_1
  }
  dependsOn: [
    hub_1
  ]
}
module connections_2 'connections.bicep' = {
  name: 'connections-${secondaryRegionShortLocation}'
  params: {
    shortLocation: secondaryRegionShortLocation
    octet2: secondaryRegionOctet2
    net_nva_id: net_nva_id_2
  }
  dependsOn: [
    hub_2
  ]
}

module routes_1 'routes.bicep' = {
  name: 'routes-${primaryRegionShortLocation}'
  params: {
    shortLocation: primaryRegionShortLocation
    primaryRegionShortLocation: primaryRegionShortLocation
    secondaryRegionShortLocation: secondaryRegionShortLocation
    primaryRegionOctet2: primaryRegionOctet2
    secondaryRegionOctet2: secondaryRegionOctet2
    connection_id_1: connections_1.outputs.connection_nva_id
    connection_id_2: connections_2.outputs.connection_nva_id
  }
  dependsOn: [
    connections_1
    connections_2
  ]
}
module routes_2 'routes.bicep' = {
  name: 'routes-${secondaryRegionShortLocation}'
  params: {
    shortLocation: secondaryRegionShortLocation
    primaryRegionShortLocation: primaryRegionShortLocation
    secondaryRegionShortLocation: secondaryRegionShortLocation
    primaryRegionOctet2: primaryRegionOctet2
    secondaryRegionOctet2: secondaryRegionOctet2    
    connection_id_1: connections_1.outputs.connection_nva_id
    connection_id_2: connections_2.outputs.connection_nva_id
  }
  dependsOn: [
    connections_1
    connections_2
  ]
}

output rg_id string = resourceGroup().id
output vwan_id string = vwan.id
