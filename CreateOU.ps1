### Creating OU Structure ###
$Content = Import-Csv -Path "C:\new_OU.csv" 
foreach ($OU in $Content)
{
    Write-host $OU.Name
    Write-host $OU.Path
    New-ADOrganizationalUnit -Name $OU.Name -Path $OU.Path -PassThru
}

#New-ADOrganizationalUnit -Name "CORP" -Path "DC=corp,DC=priv" -Description "CORP Domain" -PassThru