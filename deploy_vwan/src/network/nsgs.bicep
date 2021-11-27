param location string
param shortLocation string

resource nsg_basic 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${shortLocation}-basic'
  location: location 
}

output rg_id string = resourceGroup().id
output nsg_basic_id string = nsg_basic.id
