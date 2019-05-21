Function FakeCompanyOU
{
<#
.SYNOPSIS
	This function allows you to create Active Directory OU structure from CSV file.
.DESCRIPTION
	This function allows you to create Active Directory OU structure from CSV file.
.PARAMETER FilePath
	Specify the path of a CSV file containing OU information.
.EXAMPLE
    PS C:\> FakeCompanyOU -CSVFile C:\new_OU.csv
 
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


    $Content = Import-Csv -Path "$CSVFile"

    ### Creating OU Structure ###
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
}


