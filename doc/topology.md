# Topology

#### [prev](./routing.md) | [home](./welcome.md)  | [next](./security.md)

## Hub and spoke 

![Topology Diagram](/png/topology.png)

A working example for a hub and spoke topology available for you to [try out](/deploy/README.md).

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

### Subnets in each hub (small org)

Use a single address space of 10.x.0.0/24 carved into the following subnets.

Subnet Name | Mask bits | Hosts | Usable | Net Address | Brst Address
---|---|---|---|---|---
AzureFirewallSubnet           | /26 | 64 | 59 | 10.x.0.0   | 10.x.0.63
AzureFirewallManagementSubnet | /26 | 64 | 59 | 10.x.0.64  | 10.x.0.127
ApplicationGatewaySubnet      | /27 | 32 | 27 | 10.x.0.128 | 10.x.0.159
AzureBastionSubnet            | /27 | 32 | 27 | 10.x.0.160 | 10.x.0.191
VmSubnet1 (domain services)   | /28 | 16 | 11 | 10.x.0.192 | 10.x.0.207
VmSubnet2 (jump boxes)        | /28 | 16 | 11 | 10.x.0.208 | 10.x.0.223
VmSubnet3 (spare)             | /28 | 16 | 11 | 10.x.0.224 | 10.x.0.239
GatewaySubnet                 | /28 | 16 | 11 | 10.x.0.240 | 10.x.0.255

> Reserve 10.x.254.0/24 for Point to Site VPN if desired.
### Subnets in each hub (larger org)

Use two address spaces 10.x.0.0/24 and 10.x.255.0/24 carved into the following subnets.

Subnet Name | Mask bits | Hosts | Usable | Net Address | Brst Address
---|---|---|---|---|---
AzureFirewallSubnet           | /26 | 64  | 59  | 10.x.0.0     | 10.x.0.63
AzureFirewallManagementSubnet | /26 | 64  | 59  | 10.x.0.64    | 10.x.0.127
AzureBastionSubnet            | /27 | 32  | 27  | 10.x.0.128   | 10.x.0.159
VmSubnet1 (domain services)   | /28 | 16  | 11  | 10.x.0.160   | 10.x.0.175
VmSubnet2 (jump boxes)        | /28 | 16  | 11  | 10.x.0.176   | 10.x.0.191
GatewaySubnet                 | /26 | 64  | 59  | 10.x.0.192   | 10.x.0.255
ApplicationGatewaySubnet1     | /25 | 128 | 123 | 10.x.255.0   | 10.x.255.127
ApplicationGatewaySubnet2     | /25 | 128 | 123 | 10.x.255.128 | 10.x.255.255

> Reserve 10.x.254.0/24 for Point to Site VPN if desired. 

## Other topologies

There is no golden topology that will fit every workload scenario.
- Consider the workload.
- Consider availability requirements (including global and regional).
- Consider peering costs.
- Don't underestimate hidden costs and administrative overheads.
