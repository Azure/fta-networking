targetScope = 'subscription'

@secure()
param vmpassword string
param vmusername string

var primaryRegionLocation = 'australiaeast'
var secondaryRegionLocation = 'australiasoutheast'

var version = '211129'
// var location = deployment().location

// Lookup region code based on location parameter
var regionCodeLookup = {
  australiaeast: 'aue'
  australiasoutheast: 'ase'
}
// var shortLocation = regionCodeLookup[location]
var primaryRegionShortLocation = regionCodeLookup[primaryRegionLocation]
var secondaryRegionShortLocation = regionCodeLookup[secondaryRegionLocation]

// Lookup region prefix based on location parameter
var regionPrefixLookup = {
  australiaeast: '10.101.0.0/16'
  australiasoutheast: '10.102.0.0/16'
}
// var regionAddressPrefix = regionPrefixLookup[location]
var primaryRegionAddressPrefix = regionPrefixLookup[primaryRegionLocation]
var secondaryRegionAddressPrefix = regionPrefixLookup[secondaryRegionLocation]

// Get the needed octets to handle different address spaces for each region
// var octet2 = int(split(regionAddressPrefix, '.')[1])
var primaryRegionOctet2 = int(split(primaryRegionAddressPrefix, '.')[1])
var secondaryRegionOctet2 = int(split(secondaryRegionAddressPrefix, '.')[1])

resource rg_network_1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${version}-${primaryRegionShortLocation}-network'
  location: primaryRegionLocation
}
resource rg_network_2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${version}-${secondaryRegionShortLocation}-network'
  location: secondaryRegionLocation
}

module network_1 'network/main.bicep' = {
  name: 'network-${primaryRegionShortLocation}'
  scope: rg_network_1
  params: {
    location: primaryRegionLocation
    shortLocation: primaryRegionShortLocation
    octet2: primaryRegionOctet2
  }
}
module network_2 'network/main.bicep' = {
  name: 'network-${secondaryRegionShortLocation}'
  scope: rg_network_2
  params: {
    location: secondaryRegionLocation
    shortLocation: secondaryRegionShortLocation
    octet2: secondaryRegionOctet2
  }
}

module firewall_1 'firewall/main.bicep' = {
  name: 'firewall-${primaryRegionShortLocation}'
  scope: rg_network_1
  params: {
    location: primaryRegionLocation
    shortLocation: primaryRegionShortLocation
    net_nva_id: network_1.outputs.net_nva_id
  }
}
module firewall_2 'firewall/main.bicep' = {
  name: 'firewall-${secondaryRegionShortLocation}'
  scope: rg_network_2
  params: {
    location: secondaryRegionLocation
    shortLocation: secondaryRegionShortLocation
    net_nva_id: network_2.outputs.net_nva_id
  }
}

resource rg_compute_1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${version}-${primaryRegionShortLocation}-compute'
  location: primaryRegionLocation
}
resource rg_compute_2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${version}-${secondaryRegionShortLocation}-compute'
  location: secondaryRegionLocation
}

module compute_1 'compute/main.bicep' = {
  name: 'compute-${primaryRegionShortLocation}'
  scope: rg_compute_1
  params: {
    location: primaryRegionLocation
    shortLocation: primaryRegionShortLocation
    net_nva_id: network_1.outputs.net_nva_id
    net_spoke1_id: network_1.outputs.net_spoke1_id
    net_spoke2_id: network_1.outputs.net_spoke2_id
    username: vmusername
    password: vmpassword
  }
}
module compute_2 'compute/main.bicep' = {
  name: 'compute-${secondaryRegionShortLocation}'
  scope: rg_compute_2
  params: {
    location: secondaryRegionLocation
    shortLocation: secondaryRegionShortLocation
    net_nva_id: network_2.outputs.net_nva_id
    net_spoke1_id: network_2.outputs.net_spoke1_id
    net_spoke2_id: network_2.outputs.net_spoke2_id
    username: vmusername
    password: vmpassword
  }
}

module wan 'wan/main.bicep' = {
  name: 'wan'
  scope: resourceGroup('${version}-${primaryRegionShortLocation}-network')
  params: {
    primaryRegionLocation: primaryRegionLocation
    secondaryRegionLocation: secondaryRegionLocation
    primaryRegionShortLocation: primaryRegionShortLocation
    secondaryRegionShortLocation: secondaryRegionShortLocation
    primaryRegionOctet2: primaryRegionOctet2
    secondaryRegionOctet2: secondaryRegionOctet2
    net_nva_id_1: network_1.outputs.net_nva_id
    net_nva_id_2: network_2.outputs.net_nva_id
  }
}
