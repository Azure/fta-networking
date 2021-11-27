param shortLocation string

param primaryRegionShortLocation string 
param secondaryRegionShortLocation string

param primaryRegionOctet2 int
param secondaryRegionOctet2 int

param connection_id_1 string
param connection_id_2 string

resource hub 'Microsoft.Network/virtualHubs@2020-06-01' existing = {
  name: shortLocation
}

resource routes 'Microsoft.Network/virtualHubs/hubRouteTables@2021-03-01' = {
  name: 'defaultRouteTable'
  parent: hub
  properties: {
    routes: [
      {
        name: primaryRegionShortLocation
        destinationType: 'CIDR'
        destinations: [
          '10.${primaryRegionOctet2}.0.0/16'
        ]
        nextHopType: 'ResourceId'      
        nextHop: connection_id_1
      }   
      {
        name: secondaryRegionShortLocation
        destinationType: 'CIDR'
        destinations: [
          '10.${secondaryRegionOctet2}.0.0/16'
        ]
        nextHopType: 'ResourceId'      
        nextHop: connection_id_2
      }                    
    ]
    labels: [
      'default'
    ]
  }
}

output rg_id string = resourceGroup().id
output routes_id string = routes.id

