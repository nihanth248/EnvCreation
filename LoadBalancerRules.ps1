

Get-AzureRmResourceGroup -ResourceGroupName $ResoureGroupName -Location $Location

# Create Public IP

$publicIP = Get-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Name PublicIP-LB-FE-nt1vm
$PublicIPNonProd1 = New-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Name $Client_Name"-"$Resource_Name"-PIPNP1" -Location $Location -AllocationMethod Dynamic
$PublicIPNonProd2 = New-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Name $Client_Name"-"$Resource_Name"-PIPNP2" -Location $Location -AllocationMethod Dynamic
$PublicIPNonProd3 = New-AzureRmPublicIpAddress -ResourceGroupName $ResoureGroupName -Name $Client_Name"-"$Resource_Name"-PIPNP3" -Location $Location -AllocationMethod Dynamic

$lb = Get-AzureRmLoadBalancer -ResourceGroupName $ResoureGroupName

#Create FrontendIP

#Add-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIp" -PublicIpAddress $publicIP -LoadBalancer $lb
Add-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIPNProd1" -PublicIpAddress $publicIPNonProd1 -LoadBalancer $lb
Add-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIPNProd2" -PublicIpAddress $publicIPNonProd2 -LoadBalancer $lb
Add-AzureRmLoadBalancerFrontendIpConfig -Name $Client_Name"-"$Resource_Name"-FIPNProd3" -PublicIpAddress $publicIPNonProd3 -LoadBalancer $lb

#Create Backend Pool

$backendPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $Client_Name"-"$Resource_Name"-Backendpool"

#Create Probes

Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-Prod-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 8443 -IntervalInSeconds 5 -ProbeCount 2
Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-NonProd1-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 9443 -IntervalInSeconds 5 -ProbeCount 2
Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-NonProd2-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 10443 -IntervalInSeconds 5 -ProbeCount 2
Add-AzureRmLoadBalancerProbeConfig -Name $Client_Name"-"$Resource_Name"-NonProd3-HealthProbe" -LoadBalancer $lb -Protocol tcp -Port 11443 -IntervalInSeconds 5 -ProbeCount 2

$probe1 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-Prod-HealthProbe"
$probe2 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-NonProd1-HealthProbe"
$probe3 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-NonProd2-HealthProbe"
$probe4 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name $Client_Name"-"$Resource_Name"-NonProd3-HealthProbe"

#Add Load Balancer Rules

Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbProdRule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 8443 -Probe $probe1 
Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbNonProd1Rule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[1] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 9443 -Probe $probe2
Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbNonProd2Rule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[2] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 10443 -Probe $probe3 
Add-AzureRmLoadBalancerRuleConfig -Name $Client_Name"-"$Resource_Name"-LbNonProd3Rule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[3] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol Tcp -FrontendPort 443 -BackendPort 11443 -Probe $probe4 

Set-AzureRmLoadBalancer -LoadBalancer $lb
