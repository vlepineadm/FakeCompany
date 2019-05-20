## Global variables ##
$GroupCategory = "Security"
$GroupScope = "Global"

## Beginning of the script ##
$Content = Import-Csv -Path "C:\new_Groups.csv" 
foreach ($Group in $Content)
{
    ## Name ##
    $Name = $Group.('Name')

    ## DisplayName ##
    $DisplayName = $Group.('Name')

    Write-Debug $Name ## GRP_DPT_JUR
    Write-Debug $DisplayName ## GRP_DPT_JUR
    Write-Debug $Group.('Description') ## Département Juridique
    Write-Debug $Group.('Path') ## OU=Groups,OU=Paris,OU=Sites,OU=CORP,DC=corp,DC=priv

    ## If the Group exist
    $ADGroupExist = $(try {Get-ADGroup $Name} catch {$null})
    If ($ADGroupExist) 
    {
        Write-Host "The group $Name already exists"
    } 
    else 
    {   
        New-ADGroup -Name $Name `
        -DisplayName $DisplayName `
        -Description $Group.('Description') `
        -Path $Group.('Path') `
        -GroupCategory $GroupCategory `
        -GroupScope $GroupScope

        Write-Host "The group $Name was created"
    }
}