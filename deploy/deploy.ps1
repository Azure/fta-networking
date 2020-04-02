$rgName = "fta-networking-sample" 
$rgLocation = "australiasoutheast"

New-AzResourceGroup -ResourceGroupName $rgName -Location $rgLocation
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile .\template.json -Verbose -Name "fta-networking"