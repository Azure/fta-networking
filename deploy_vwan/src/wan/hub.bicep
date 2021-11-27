param location string
param shortLocation string
param octet2 int

param vwan_id string

resource hub 'Microsoft.Network/virtualHubs@2020-06-01' = {
  name: shortLocation
  location: location
  properties: {
    addressPrefix: '10.${octet2}.0.0/24'
    virtualWan: {
      id: vwan_id
    }
  }
}

output rg_id string = resourceGroup().id
output hub_id string = hub.id
