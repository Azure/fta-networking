# Security

#### [prev](./routing.md) | [home](./welcome.md)  | [next](./mgmt.md)

## Network Security Groups (NSG)
A network security group contains security rules that allow or deny inbound network traffic to, or outbound network traffic from, several types of Azure resources.

A network security group contains zero, or as many rules as desired, within Azure subscription limits. Each rule specifies the following properties:

* Name
* Priority
* Source
* Source Port ranges
* Destionation 
* Destionation Port Ranges
* Protocol
* Priority

Each Security rule is created as either Inboud or Outbound rule.
Each NSG also has default security rules which are created automaticly by Azure.

https://docs.microsoft.com/en-us/azure/virtual-network/security-overview

## Application Security Groups

Application security groups enable you to configure network security as a natural extension of an application's structure, allowing you to group virtual machines and define network security policies based on those groups. 

https://docs.microsoft.com/en-us/azure/virtual-network/application-security-groups



## Service Tags


## Service Endpoints

## Private Endpoints


## DDoS Protection

## Azure Firewall
