# Sample

## Getting started

This sample uses [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) to define a modular deployment presented in [topology](../doc/topology.md).

### Install

1. Install the Azure CLI by following the [docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) article.

1. Install Bicep from within the Azure CLI:

```
$ az bicep install
```

### Deploy

1. Deploy the `main.bicep` file from the `src` directory of this sample:

```
$ cd deploy/src/
$ az deployment sub create --location australiacentral --template-file main.bicep
```
