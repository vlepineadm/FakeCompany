### Creating OU Structure ###
$Content = Import-Csv -Path "C:\new_OU.csv" 
foreach ($OU in $Content)
{
    ## Name ###
    $Name = $OU.Name

    Write-Debug $Name
    Write-Debug $OU.Path

    ## If the OU exist
    $ADOUExist = $(try {Get-ADOrganizationalUnit -Filter {Name -like $Name} -SearchBase "DC=corp,DC=priv" -SearchScope OneLevel} catch {$null})
    If ($ADOUExist) 
    {
        Write-Host "The OU $Name already exists"
    } 
    else 
    {   
        New-ADOrganizationalUnit -Name $Name -Path $OU.Path -PassThru -ProtectedFromAccidentalDeletion $false

        Write-Host "The OU $Name was created"
    }
}




