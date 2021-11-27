param location string
param shortLocation string

resource policy 'Microsoft.Network/firewallPolicies@2021-03-01' = {
  name: '${shortLocation}-open'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
  }
}

resource ruleCollectionGroups 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  parent: policy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'RFC1918A'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '10.0.0.0/8'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'RFC1918B'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '172.16.0.0/12'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'RFC1918C'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '192.168.0.0/16'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
        ]
        name: 'Allow-RFC1918'
        priority: 1000
      }
    ]
  }
}

output rg_id string = resourceGroup().id
output policy_id string = policy.id
