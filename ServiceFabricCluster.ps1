
param(    $ResoureGroupName = "abbsc-nmdeploy-03",    $Location = "SouthCentralUS",    $Client_Name = "abb",    $Resource_Name = "VMSS-LB"    )
    
# Certificate variables.
$certpwd="Password#1234" | ConvertTo-SecureString -AsPlainText -Force
$certfolder="c:\mycertificates\"

# Variables for VM admin.
$adminuser="vmadmin"
$adminpwd="Password#1234" | ConvertTo-SecureString -AsPlainText -Force 

# Variables for common values
$vmsku = "Standard_D2_v2"
$vaultname = "testkeysf3"
$subname="$clustername.$Location.cloudapp.azure.com"

# Set the number of cluster nodes.
$clustersize=5 

Get-AzureRmResourceGroup -ResourceGroupName $ResoureGroupName

# Create the Service Fabric cluster.
New-AzureRmServiceFabricCluster -Name sevicefabqwert -ResourceGroupName $ResoureGroupName -Location $Location  `
-ClusterSize $clustersize -VmUserName $adminuser -VmPassword $adminpwd -CertificateSubjectName $subname `
-OS WindowsServer2016DatacenterwithContainers -VmSku $vmsku -KeyVaultName $vaultname
#-CertificatePassword $certpwd -CertificateOutputFolder $certfolder `
