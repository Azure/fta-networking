param location string
param shortLocation string
param net_nva_id string
param net_spoke1_id string
param net_spoke2_id string

@secure()
param password string
param username string

resource store 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: uniqueString(resourceGroup().id, shortLocation)
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

// module vm_hub 'vm.bicep' = {
//   name: 'vm_hub'
//   params: {
//     location: location
//     shortLocation: shortLocation
//     name: 'hubvm'
//     username: username
//     password: password
//     net_id: net_nva_id
//     store_id: store.id
//   }
// }

module vm_spoke1 'vm.bicep' = {
  name: 'vm_spoke1'
  params: {
    location: location
    shortLocation: shortLocation
    name: 'spoke1vm'
    username: username
    password: password
    net_id: net_spoke1_id
    store_id: store.id
  }
}

module vm_spoke2 'vm.bicep' = {
  name: 'vm_spoke2'
  params: {
    location: location
    shortLocation: shortLocation
    name: 'spoke2vm'
    username: username
    password: password
    net_id: net_spoke2_id
    store_id: store.id
  }
}

output rg_id string = resourceGroup().id
