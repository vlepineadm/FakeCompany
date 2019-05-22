Function FakeCompanyGroups
{
<#
.SYNOPSIS
	This function allows you to create Active Directory groups from CSV file.
.DESCRIPTION
	This function allows you to create Active Directory groups from CSV file.
.PARAMETER FilePath
	Specify the path of a CSV file containing groups information.
.EXAMPLE
    PS C:\> FakeCompanyGroups -CSVFile C:\new_Groups.csv
 
.NOTES
    Valentin LEPINE
    Email : vlepineadm@outlook.com
    Twitter : @vlepineadm
    Github : https://github.com/vlepineadm
#>

    [CmdletBinding()]
    [OutputType( [System.Object] )]
    PARAM
    (
        [System.String]$CSVFile
    )


    # Active Directory module import
    Try
    {
        Import-Module ActiveDirectory
    }
    Catch [FileNotFoundException]
    {
        Write-Error "The Active Directory module could not be loaded"
    }

    ## Global variables ##
    $GroupCategory = "Security"
    $GroupScope = "Global"

    $Content = Import-Csv -Path "$CSVFile" 

    ### Creating Groups ###
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
}