param location string
param shortLocation string
param octet2 int

resource udr_default 'Microsoft.Network/routeTables@2021-03-01' = {
  name: '${shortLocation}-default'
  location: location
  properties: {
    routes: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.${octet2}.255.4'
        }
      }           
    ]
  }
}
  
output rg_id string = resourceGroup().id
output udr_default_id string = udr_default.id
