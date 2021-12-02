# Sample

## Getting started

This sample uses [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) to deploy a cross region and cross subscription vnet peering.

### Install

1. Install the Azure CLI by following the [docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) article.

1. Install Bicep from within the Azure CLI:

```
az bicep install

az bicep upgrade
```

### Login

1. Login and select your subscription

```
az login
```

### Deploy

1. Run the `deploy.ps1` script from the `src` directory of this sample:

```
cd deploy_crossSubPeer/src/

./deploy.ps1 -Subscription1 <your_first_subscription> -Subscription2 <your_second_subscription> 
``` 
