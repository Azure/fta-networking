[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $Subscription1,

    [Parameter(Mandatory=$true, Position=1)]
    [string]
    $Subscription2
)

$aue = 'australiaeast'
$ase = 'australiasoutheast'

Write-Output "deploying first vnet"
$aueVnetDep = az deployment sub create --subscription $Subscription1 --location $aue --template-file vnet/main.bicep --name xregionvnet-aue
$aueVnetId = ($aueVnetDep | ConvertFrom-Json).properties.outputs.vnetId.value; $aueVnetId

Write-Output "deploying second vnet"
$aseVnetDep = az deployment sub create --subscription $Subscription2 --location $ase --template-file vnet/main.bicep --name xregionvnet-ase
$aseVnetId = ($aseVnetDep | ConvertFrom-Json).properties.outputs.vnetId.value; $aseVnetId 

Write-Output "peering first vnet to second vent"
$auePeerDep = az deployment sub create --subscription $Subscription1 --location $aue --template-file peer/main.bicep --name xregionpeer-aue --parameters vnetId=$aueVnetId remoteVnetId=$aseVnetId
$auePeerId = ($auePeerDep | ConvertFrom-Json).properties.outputs.peerId.value; $auePeerId

Write-Output "peering second vnet to first vent"
$asePeerDep = az deployment sub create --subscription $Subscription2 --location $ase --template-file peer/main.bicep --name xregionpeer-ase --parameters vnetId=$aseVnetId remoteVnetId=$aueVnetId
$asePeerId = ($asePeerDep | ConvertFrom-Json).properties.outputs.peerId.value; $asePeerId 