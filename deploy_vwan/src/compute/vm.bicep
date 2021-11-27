param location string
param shortLocation string
param name string

param net_id string
param store_id string

@secure()
param password string
param username string

resource existing_store 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: last(split(store_id,'/'))
}

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: '${shortLocation}-${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet:{
            id: '${net_id}/subnets/VmSubnet'
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: '${shortLocation}-${name}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${shortLocation}-${name}-disk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Detach'
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: '${shortLocation}-${name}'
      adminUsername: username
      adminPassword: password
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'https://${existing_store.name}.blob.core.windows.net/'
      }
    }
  }
}

output rg_id string = resourceGroup().id
