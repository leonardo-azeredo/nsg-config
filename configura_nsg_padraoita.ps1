Connect-AzAccount

#Nome do Nsg
$nsgnome = Read-Host "Insira o nome do NSG"

#Nome do Resource
$nsgresource = Read-Host "Insira o nome do grupo de recurso em que o NSG está localizado."

Write-Output "Excluindo regras existentes..."

$nsg = Get-AzNetworkSecurityGroup -Name $nsgnome -ResourceGroupName $nsgresource
$rules= $nsg.SecurityRules.Name

Write-Output $rules | Out-Null

foreach($rule in $rules) {
    Remove-AzNetworkSecurityRuleConfig -Name $rule -NetworkSecurityGroup $nsg | Out-Null

    }

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg | Out-Null

Write-Output "Regras excluidas"
$vmtipo = Read-Host "Por favor pressione 1 para VM Windows ou 2 para VM Linux"
if ($vmtipo -eq 1)
{
$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowADIn" -Description "Libera comunicação full com o AD (10.0.0.10)" -Access Allow `
    -Protocol * -Direction Inbound -Priority 1001 -SourceAddressPrefix "10.0.0.10" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange * | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowZabbixIn" -Description "Libera comunicação com o Agent2 do Zabbix" -Access Allow `
    -Protocol "tcp" -Direction Inbound -Priority 1002 -SourceAddressPrefix "10.0.0.4" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 10050 | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowAzureLoadBalancer" -Description "Libera total comunicação com o LoadBalancer do Azure" -Access Allow `
    -Protocol * -Direction Inbound -Priority 1003 -SourceAddressPrefix "AzureLoadBalancer" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange * | Out-Null 

$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowRDPInVNet" -Description "Libera o acesso RDP pela vNet" -Access Allow `
    -Protocol "tcp" -Direction Inbound -Priority 1004 -SourceAddressPrefix "VirtualNetwork" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389 | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "DenyAllvNetIn" -Description "Bloqueia qualquer entrada pela vNet" -Access Deny `
    -Protocol * -Direction Inbound -Priority 1025 -SourceAddressPrefix "VirtualNetwork" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange * | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowADOut" -Description "Libera comunicação full com o AD (10.0.0.10)" -Access Allow `
    -Protocol * -Direction Outbound -Priority 1006 -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix "10.0.0.10" -DestinationPortRange * | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "DenyAllvNetOut" -Description "Bloqueia qualquer saída pela vNet" -Access Deny `
    -Protocol * -Direction Outbound -Priority 1025 -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix "VirtualNetwork" -DestinationPortRange * | Out-Null

    $nsg | Set-AzNetworkSecurityGroup | Out-Null

    Write-Output "As regras para máquina Windows foram criadas com sucesso!"

    }
    else
     { 

$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowZabbixIn" -Description "Libera comunicação com o Agent2 do Zabbix" -Access Allow `
    -Protocol "tcp" -Direction Inbound -Priority 1002 -SourceAddressPrefix "10.0.0.4" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 10050 | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowAzureLoadBalancer" -Description "Libera total comunicação com o LoadBalancer do Azure" -Access Allow `
    -Protocol * -Direction Inbound -Priority 1003 -SourceAddressPrefix "AzureLoadBalancer" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange * | Out-Null 

$nsg | Add-AzNetworkSecurityRuleConfig -Name "AllowSSHInVNet" -Description "Libera o acesso SSH pela vNet" -Access Allow `
    -Protocol "tcp" -Direction Inbound -Priority 1004 -SourceAddressPrefix "VirtualNetwork" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 22 | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "DenyAllvNetIn" -Description "Bloqueia qualquer entrada pela vNet" -Access Deny `
    -Protocol * -Direction Inbound -Priority 1025 -SourceAddressPrefix "VirtualNetwork" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange * | Out-Null

$nsg | Add-AzNetworkSecurityRuleConfig -Name "DenyAllvNetOut" -Description "Bloqueia qualquer saída pela vNet" -Access Deny `
    -Protocol * -Direction Outbound -Priority 1025 -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix "VirtualNetwork" -DestinationPortRange * | Out-Null

    $nsg | Set-AzNetworkSecurityGroup | Out-Null

    
Write-Output "As regras para máquina Linux foram criadas com sucesso!"

    }
 

