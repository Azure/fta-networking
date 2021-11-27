param location string
param shortLocation string
param octet2 int

param nsg_basic_id string
param udr_default_id string

resource net_nva 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${shortLocation}-nva'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.${octet2}.255.0/24'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.${octet2}.255.0/26'
        }
      }
      {
        name: 'VmSubnet'
        properties: {
          addressPrefix: '10.${octet2}.255.128/28'
          networkSecurityGroup: {
            id: nsg_basic_id
          }          
        }
      }      
    ]
  }
}

resource net_spoke1 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${shortLocation}-spoke1'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.${octet2}.1.0/24'
      ]
    }
    subnets: [
      {
        name: 'VmSubnet'
        properties: {
          addressPrefix: '10.${octet2}.1.0/28'
          networkSecurityGroup: {
            id: nsg_basic_id
          }
          routeTable: {
            id: udr_default_id
          }
        }
      }
    ]
  }
}

resource net_spoke2 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${shortLocation}-spoke2'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.${octet2}.2.0/24'
      ]
    }
    subnets: [
      {
        name: 'VmSubnet'
        properties: {
          addressPrefix: '10.${octet2}.2.0/28'
          networkSecurityGroup: {
            id: nsg_basic_id
          }
          routeTable: {
            id: udr_default_id
          }
        }
      }
    ]
  }
}

output rg_id string = resourceGroup().id
output net_nva_id string = net_nva.id
output net_spoke1_id string = net_spoke1.id
output net_spoke2_id string = net_spoke2.id
