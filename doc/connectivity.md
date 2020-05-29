# Connectivity

#### [prev](./topology.md) | [home](./welcome.md)  | [next](./routing.md)

## Do you need connectivity to another network outside of Azure?
if you need to communicate with services (using a private ip) in another network  there are a few options depending on what your requirements are:
the two main options are
* [VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways)
* [Express Route](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-introduction)

The Azure Architecture center has a a great article compaing the two [here](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)

## Express Route key points
* [Peering Locations](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers) -  MSEE is not equal to an Azure Region
* [Peering Types](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-circuit-peerings) - Microsoft and private, do i need 1 or the other or both?
* [Routing Requirements](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-routing)
* [High Availabililty](https://docs.microsoft.com/en-us/azure/expressroute/designing-for-high-availability-with-expressroute) - Path Redundancy and first mile considerations

## For more advanced scenarios make sure you are aware of
* [Virtual WAN](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
* [ExpressRoute Global Reach](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-global-reach)
* [Coexistance of ER and VPN Gateways](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-coexist-resource-manager)

## Alternatives to private connectivity
you may not need a full hybrid network to support your workloads. Some services offer their own connectivity options which might be worth exploring if you only need connectivity for 1 or two solutions
* [Azure Relay](https://docs.microsoft.com/en-us/azure/azure-relay/relay-what-is-it)
* [Data Gateway](https://docs.microsoft.com/en-us/data-integration/gateway/service-gateway-onprem)
* Exposing services using [Mutual Certificate Authentication](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-mutual-certificates)
