param shortLocation string
param vnetId string

// Determine the location based on the resource group
var location = resourceGroup().location

var name = 'bastion'

resource ipBastion 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${shortLocation}-${name}-ip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: '${shortLocation}-${name}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: ipBastion.id
          }
          subnet: {
            id: '${vnetId}/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
  }
  sku: {
    name: 'Basic'
  }
}
