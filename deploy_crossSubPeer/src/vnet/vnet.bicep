param location string
param shortLocation string
param regionAddressPrefix string

var octet1 = int(split(regionAddressPrefix, '.')[0])
var octet2 = int(split(regionAddressPrefix, '.')[1])

resource net_vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${shortLocation}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        regionAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'VmSubnet'
        properties: {
          addressPrefix: '${octet1}.${octet2}.0.0/28'       
        }
      }      
    ]
  }
}

output vnetId string = net_vnet.id
