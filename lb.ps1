param(    $ResoureGroupName = "abbsc-nmdeploy-01",    $Location = "SouthCentralUS",    $Client_Name = "abb",    $Resource_Name = "Test-LB"    )
    Write-Output "Script parameters: "
Write-Output "-------------------"
Write-Output "ResoureGroupName: $($ResoureGroupName)"
Write-Output "Location: $($Location)"
Write-Output "Client_Name: $($Client_Name)"
Write-Output "Resource_Name: $($Resource_Name)"   

if(
    ($ResoureGroupName -eq $null) `
    -or ($Location -eq $null) `
    -or ($Client_Name -eq $null) `
    -or ($Resource_Name -eq $null) `
   ) {
    Write-Output "Please provide proper parameters"
    exit 1
}

# Get Resource Group 

Get-AzureRmResourceGroup -ResourceGroupName $ResoureGroupName -Location $Location

# Create Public IP

$publicIP = New-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Location $Location -AllocationMethod Dynamic -Name $Client_Name"-"$Resource_Name"-PIP" 
$PublicIPNonProd1 = New-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Location $Location -AllocationMethod Dynamic -Name $Client_Name"-"$Resource_Name"-PIPNP1"
$PublicIPNonProd2 = New-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Location $Location -AllocationMethod Dynamic -Name $Client_Name"-"$Resource_Name"-PIPNP2"
$PublicIPNonProd3 = New-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Location $Location -AllocationMethod Dynamic -Name $Client_Name"-"$Resource_Name"-PIPNP3"

#Create FrontendIP

$frontendIP1 = New-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIP" -PublicIpAddress $publicIP 
$frontendIP2 = New-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIPNProd1" -PublicIpAddress $publicIPNonProd1 
$frontendIP3 = New-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIPNProd2" -PublicIpAddress $publicIPNonProd2 
$frontendIP4 = New-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIPNProd3" -PublicIpAddress $publicIPNonProd3 

#Create Backend Pool

$backendPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $Client_Name"-"$Resource_Name"-Backendpool" 

#Create Nat Rules

$natrule1 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $Client_Name"-"$Resource_Name"-NatRule33901" -FrontendIpConfiguration $frontendIP1 -Protocol tcp -FrontendPort 33901 -BackendPort 3389
$natrule2 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $Client_Name"-"$Resource_Name"-NatRule3390" -FrontendIpConfiguration $frontendIP1 -Protocol tcp -FrontendPort 3390 -BackendPort 3389
$natrule3 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $Client_Name"-"$Resource_Name"-NatRule3391" -FrontendIpConfiguration $frontendIP1 -Protocol tcp -FrontendPort 3391 -BackendPort 3389
$natrule4 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $Client_Name"-"$Resource_Name"-NatRule3392" -FrontendIpConfiguration $frontendIP1 -Protocol tcp -FrontendPort 3392 -BackendPort 3389
$natrule5 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $Client_Name"-"$Resource_Name"-NatRule3393" -FrontendIpConfiguration $frontendIP1 -Protocol tcp -FrontendPort 3393 -BackendPort 3389

#Create Load Balancer

$lb = New-AzureRmLoadBalancer `
        -ResourceGroupName "$ResoureGroupName" `
        -Name $Client_Name"-"$Resource_Name"-LB" `
        -Location "$Location" `
        -FrontendIpConfiguration $frontendIP1,$frontendIP2,$frontendIP3,$frontendIP4 `
        -BackendAddressPool $backendPool `
        -InboundNatRule $natrule1,$natrule2,$natrule3,$natrule4,$natrule5

#Create Probes

Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-Prod-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 8443 -IntervalInSeconds 5 -ProbeCount 2
Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-NonProd1-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 9443 -IntervalInSeconds 5 -ProbeCount 2
Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-NonProd2-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 10443 -IntervalInSeconds 5 -ProbeCount 2
Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-NonProd3-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 11443 -IntervalInSeconds 5 -ProbeCount 2
#Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-FabricHttpGatewayProbe" -LoadBalancer $lb -Protocol tcp -Port 19080 -IntervalInSeconds 5 -ProbeCount 2
Set-AzureRmLoadBalancer -LoadBalancer $lb
$probe1 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-Prod-HealthProbe"
$probe2 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-NonProd1-HealthProbe"
$probe3 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-NonProd2-HealthProbe"
$probe4 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-NonProd3-HealthProbe"
#$probe5 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-FabricHttpGatewayProbe"

#Add Load Balancer Rules

Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbProdRule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 8443 -Probe $probe1 
Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbNonProd1Rule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[1] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 9443 -Probe $probe2
Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbNonProd2Rule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[2] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 10443 -Probe $probe3 
Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbNonProd3Rule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[3] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 11443 -Probe $probe4 
#Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbHttpRuleName" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 19080 -BackendPort 19080 -Probe $probe5
Set-AzureRmLoadBalancer -LoadBalancer $lb

#Create VirtualMachine ScaleSets


  