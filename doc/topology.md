# Topology

#### [prev](./routing.md) | [home](./welcome.md)  | [next](./security.md)

## Hub and spoke 

![Topology Diagram](/png/topology.png)

A working example for a hub and spoke topology available for you to [deploy](/deploy/README.md).

### Example address scheme

Location | VNet Name | Address Space
---|---|---
Primary Region | hub | 10.1.0.0/24
Primary Region | spoke1 | 10.1.1.0/24
Primary Region | spoke2 | 10.1.2.0/24
Primary Region | ... | ...
Primary Region | spoke255 | 10.1.255.0/24

> Primary region supernet 10.1.0.0/16

Location | VNet Name | Address Space
---|---|---
Secondary Region | hub | 10.2.0.0/24
Secondary Region | spoke1 | 10.2.1.0/24
Secondary Region | spoke2 | 10.2.2.0/24
Secondary Region | ... | ...
Secondary Region | spoke255 | 10.2.255.0/24

> Secondary region supernet 10.2.0.0/16

### Subnets in each hub

Subnet Name | Mask bits | Hosts | Usable | Net Address | Brst Address
---|---|---|---|---|---
AzureFirewallSubnet           | /26 | 64 | 60 | 10.x.0.0   | 10.x.0.63
AzureFirewallManagementSubnet | /26 | 64 | 60 | 10.x.0.64  | 10.x.0.127
ApplicationGatewaySubnet      | /27 | 32 | 28 | 10.x.0.128 | 10.x.0.159
AzureBastionSubnet            | /27 | 32 | 28 | 10.x.0.160 | 10.x.0.191
VmSubnet1                     | /28 | 16 | 12 | 10.x.0.192 | 10.x.0.207
VmSubnet2                     | /28 | 16 | 12 | 10.x.0.208 | 10.x.0.223
VmSubnet3                     | /28 | 16 | 12 | 10.x.0.224 | 10.x.0.239
GatewaySubnet                 | /28 | 16 | 12 | 10.x.0.240 | 10.x.0.255

## Other topologies

There is no golden topology that will fit every workload scenario.
- Consider the workload.
- Consider availability requirements (including global and regional).
- Consider peering costs.
- Don't underestimate hidden costs and administrative overheads.
