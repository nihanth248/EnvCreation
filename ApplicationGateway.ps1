Param(
    $ResoureGroupName = "abbsc-nmdeploy-03",
    $Location = "SouthCentralUS",
    $Client_Name = "abb",    $Resource_Name = "Test-AG",
    $AddPrefix = "10.0.4.0/24"
    #$AddressPrefix = "10.0.4.0/24"
    # $Nic1Name,
    # $Nic2Name,   
    )

    Write-Output "Script parameters: "
    Write-Output "-------------------"
    Write-Output "ResoureGroupName: $($ResoureGroupName)"
    Write-Output "Location $($Location)"
    Write-Output "Client_Name: $($Client_Name)"
    Write-Output "Resource_Name: $($Resource_Name)"
    Write-Output "Resource_Name: $($AddPrefix)"
    #Write-Output "Resource_Name: $($AddressPrefix)"

if(
    ($ResoureGroupName -eq $null) `
    -or ($Location -eq $null) `
    -or ($Client_Name -eq $null) `
    -or ($Resource_Name -eq $null) `
    -or ($AddPrefix -eq $null) `
    #-or ($AddressPrefix -eq $null) `
    ) {
     Write-Output "Please provide proper parameters"
     exit 1
    }

# Create Virtual Network

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResoureGroupName -Name "VNet" #-location $Location -AddressPrefix $AddressPrefix -Subnet $subnet 
        #$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name Subnet1 -AddressPrefix $AddPrefix
$subnet = Add-AzureRmVirtualNetworkSubnetConfig -Name Subnet1 -AddressPrefix $AddPrefix -VirtualNetwork $vnet
$vnet | Set-AzureRmVirtualNetwork 
$subnetid = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet
#$VNet = Get-AzureRmvirtualNetwork -Name "VNet" -ResourceGroupName $ResoureGroupName
        $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name Subnet1 -VirtualNetwork $vnet 
#$subnet = $vnet.Subnets[1]

# Create Public IP's

$pip = New-AzureRmPublicIPAddress -AllocationMethod Dynamic -ResourceGroupName $ResoureGroupName -Location $Location -Name $Client_Name"-"$Resource_Name"-AGPIP"
$gipconfig = New-AzureRmApplicationGatewayIPConfiguration -Name $Client_Name"-"$Resource_Name"-AGIPConfig" -Subnet $subnet
$fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig -Name $Client_Name"-"$Resource_Name"-AGFrontendIPConfig" -PublicIPAddress $pip 
$frontendport = New-AzureRmApplicationGatewayFrontendPort -Name $Client_Name"-"$Resource_Name"-AGFrontendPort" -Port "8443"
$frontendport1 = New-AzureRmApplicationGatewayFrontendPort -Name $Client_Name"-"$Resource_Name"-AGFrontendPort1" -Port "9443"
$frontendport2 = New-AzureRmApplicationGatewayFrontendPort -Name $Client_Name"-"$Resource_Name"-AGFrontendPort2" -Port "10443"
$frontendport3 = New-AzureRmApplicationGatewayFrontendPort -Name $Client_Name"-"$Resource_Name"-AGFrontendPort3" -Port "11443" 
        #$IPconfig1 = New-AzureRmNetworkInterfaceIpConfig -Name $Client_Name"-"$Resource_Name"-IpConfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress '10.0.4.10' -SubnetId $subnetid.Id
        #$IPconfig2 = New-AzureRmNetworkInterfaceIpConfig -Name $Client_Name"-"$Resource_Name"-IpConfig2" -PrivateIpAddressVersion IPv4 -PrivateIpAddress "10.0.4.11" -SubnetId $subnetid.Id
        #$address1 = New-AzureRmNetworkInterface -ResourceGroupName $ResoureGroupName -Location $Location -Name $Client_Name"-"$Resource_Name"-Nic1" #-IpConfiguration $IPconfig1
        #$address2 = New-AzureRmNetworkInterface -ResourceGroupName $ResoureGroupName -Location $Location -Name $Client_Name"-"$Resource_Name"-Nic2" #-IpConfiguration $IPconfig2

#Create Backend Pool

$backendPool = New-AzureRmApplicationGatewayBackendAddressPool -Name $Client_Name"-"$Resource_Name"-AGBackendPool" #-BackendFqdns #-BackendIPAddresses $address1.ipconfigurations[0].privateipaddress, $address2.ipconfigurations[0].privateipaddress 

# Pool Settings
$ProdPoolSettings = New-AzureRmApplicationGatewayBackendHttpSettings -Name $Client_Name"-"$Resource_Name"-ProdPoolSettings" -Port 8443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 86400 -Probe $ProdProbe #-ProbeEnabled 
$NonProd1PoolSettings = New-AzureRmApplicationGatewayBackendHttpSettings -Name $Client_Name"-"$Resource_Name"-NonProd1PoolSettings" -Port 9443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 86400 -Probe $NonProd1Probe #-ProbeEnabled
$NonProd2PoolSettings = New-AzureRmApplicationGatewayBackendHttpSettings -Name $Client_Name"-"$Resource_Name"-NonProd2PoolSettings" -Port 10433 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 86400 -Probe $NonProd2Probe #-ProbeEnabled
$NonProd3PoolSettings = New-AzureRmApplicationGatewayBackendHttpSettings -Name $Client_Name"-"$Resource_Name"-NonProd3PoolSettings" -Port 11443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 86400 -Probe $NonProd3Probe #-ProbeEnabled

#Create Certificate

New-SelfSignedCertificate `
  -certstorelocation C:\ `
  -dnsname www.contoso.com


$cert = New-AzureRmApplicationGatewaySslCertificate `
  -Name "appgwcert" `
  -CertificateFile "c:\appgwcert.pfx" `
  -Password $pwd
  
$pwd = ConvertTo-SecureString `
  -String "Azure123456!" `
  -Force `
  -AsPlainText

 Export-PfxCertificate `
  -cert cert:\localMachine\my\791B49F7B7675A98EEA8B6463651FE847C04B981 `
  -FilePath c:\appgwcert.pfx `
  -Password $pwd

#Create Default Listeners

$ProdListner = New-AzureRmApplicationGatewayHttpListener -Name $Client_Name"-"$Resource_Name"-ProdListner" -Protocol Https -FrontendIPConfiguration $fipconfig -FrontendPort $frontendport -SslCertificate $cert #-HostName prod.esb.nmarket.enterprisesoftware.abb #-Certificate ESB-NonProd2 
$NonProd1Listner = New-AzureRmApplicationGatewayHttpListener -Name $Client_Name"-"$Resource_Name"-NonProd1Listner" -Protocol Https -FrontendIPConfiguration $fipconfig -FrontendPort $frontendport1 -SslCertificate $cert #-HostName nonprod1.esb.nmarket.enterprisesoftware.abb #-Certificate ESB-NonProd1-Cert 
$NonProd2Listner = New-AzureRmApplicationGatewayHttpListener -Name $Client_Name"-"$Resource_Name"-NonProd2Listner" -Protocol Https -FrontendIPConfiguration $fipconfig -FrontendPort $frontendport2 -SslCertificate $cert #-HostName nonprod2.esb.nmarket.enterprisesoftware.abb #-Certificate ESB-NonProd2 
$NonProd3Listner = New-AzureRmApplicationGatewayHttpListener -Name $Client_Name"-"$Resource_Name"-NonProd3Listner" -Protocol Https -FrontendIPConfiguration $fipconfig -FrontendPort $frontendport3 -SslCertificate $cert #-HostName nonprod3.esb.nmarket.enterprisesoftware.abb #-Certificate ESB-NonProd1-Cert 

#Create Frondend Rules

$frontendRule1 = New-AzureRmApplicationGatewayRequestRoutingRule -Name $Client_Name"-"$Resource_Name"-FrontendRule1" -RuleType Basic -HttpListener $ProdListner -BackendAddressPool $backendPool -BackendHttpSettings $ProdPoolSettings 
$frontendRule2 = New-AzureRmApplicationGatewayRequestRoutingRule -Name $Client_Name"-"$Resource_Name"-FrontendRule2Name" -RuleType Basic -HttpListener $NonProd1Listner -BackendAddressPool $backendPool -BackendHttpSettings $NonProd1PoolSettings 
$frontendRule3 = New-AzureRmApplicationGatewayRequestRoutingRule -Name $Client_Name"-"$Resource_Name"-FrontendRule3Name" -RuleType Basic -HttpListener $NonProd2Listner -BackendAddressPool $backendPool -BackendHttpSettings $NonProd2PoolSettings 
$frontendRule4 = New-AzureRmApplicationGatewayRequestRoutingRule -Name $Client_Name"-"$Resource_Name"-FrontendRule4Name" -RuleType Basic -HttpListener $NonProd3Listner -BackendAddressPool $backendPool -BackendHttpSettings $NonProd3PoolSettings 

$sku = New-AzureRmApplicationGatewaySku -Name WAF_Medium -Tier WAF -Capacity 2
$waf = New-AzureRmApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode Prevention -RuleSetType OWASP

#Health Probes

$ProdProbe = New-AzureRmApplicationGatewayProbeConfig -Name Health1 -Protocol Https -HostName 'contoso.com' -Path '/nmarket-core/index.jsp' -Interval 30 -Timeout 30 -UnhealthyThreshold 8
$NonProd1Probe = New-AzureRmApplicationGatewayProbeConfig -Name Health2 -Protocol Https -HostName 'contoso.com' -Path '/nmarket-core/index.jsp' -Interval 30 -Timeout 30 -UnhealthyThreshold 8
$NonProd2Probe = New-AzureRmApplicationGatewayProbeConfig -Name Health3 -Protocol Https -HostName 'contoso.com' -Path '/nmarket-core/index.jsp' -Interval 30 -Timeout 30 -UnhealthyThreshold 8
$NonProd3Probe = New-AzureRmApplicationGatewayProbeConfig -Name Health4 -Protocol Https -HostName 'contoso.com' -Path '/nmarket-core/index.jsp' -Interval 30 -Timeout 30 -UnhealthyThreshold 8

#Create Application Gateway

New-AzureRmApplicationGateway `
  -Name $Client_Name"-"$Resource_Name"-AppGateway" `
  -ResourceGroupName $ResoureGroupName `
  -Location $Location `
  -BackendAddressPools $backendPool `
  -Probes $ProdProbe,$NonProd1Probe,$NonProd2Probe,$NonProd3Probe `
  -BackendHttpSettingsCollection $ProdPoolSettings,$NonProd1PoolSettings,$NonProd2PoolSettings,$NonProd3PoolSettings `
  -FrontendIpConfigurations $fipconfig `
  -GatewayIpConfigurations $gipconfig `
  -FrontendPorts $frontendport,$frontendport1,$frontendport2,$frontendport3 `
  -HttpListeners $ProdListner,$NonProd1Listner,$NonProd2Listner,$NonProd3Listner `
  -RequestRoutingRules $frontendRule1,$frontendRule2,$frontendRule3,$frontendRule4 `
  -Sku $sku `
  -WebApplicationFirewallConfiguration $waf `
  -SslCertificates $cert

#$as = New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Location $Location `
# -Name 'MyAvailabilitySet' -Sku Aligned -PlatformFaultDomainCount 3 -PlatformUpdateDomainCount 3