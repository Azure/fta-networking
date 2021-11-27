param location string
param shortLocation string

param net_nva_id string

module policy 'policy.bicep' = {
  name: 'policy'
  params: {
    location: location
    shortLocation: shortLocation
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${shortLocation}-firewall-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' = {
  name: '${shortLocation}-firewall'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: policy.outputs.policy_id
    }
    applicationRuleCollections: []
    natRuleCollections: []
    networkRuleCollections: []
    threatIntelMode: 'Alert'    
    ipConfigurations: [
      {
        name: '${shortLocation}-firewall-ip'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: '${net_nva_id}/subnets/AzureFirewallSubnet'
          }
        }
      }
    ]
  }
}

output rg_id string = resourceGroup().id
