param location string
param shortLocation string
param octet2 int

module nsgs 'nsgs.bicep' = {
  name: 'nsgs'
  params: {
    location: location
    shortLocation: shortLocation
  }
}

module udrs 'udrs.bicep' = {
  name: 'udrs'
  params: {
    location: location
    shortLocation: shortLocation
    octet2: octet2
  }
}

module vnets 'vnets.bicep' = {
  name: 'vnets'
  params: {
    location: location
    shortLocation: shortLocation
    octet2: octet2
    nsg_basic_id: nsgs.outputs.nsg_basic_id
    udr_default_id: udrs.outputs.udr_default_id
  }
}

module peering 'peerings.bicep' = {
  name: 'peerings'
  params: {
    net_nva_id: vnets.outputs.net_nva_id
    net_spoke1_id: vnets.outputs.net_spoke1_id
    net_spoke2_id: vnets.outputs.net_spoke2_id
  }
}

output rg_id string = resourceGroup().id
output net_nva_id string = vnets.outputs.net_nva_id
output net_spoke1_id string = vnets.outputs.net_spoke1_id
output net_spoke2_id string = vnets.outputs.net_spoke2_id
