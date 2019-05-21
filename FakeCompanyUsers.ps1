Function FakeCompanyUsers
{
<#
.SYNOPSIS
	This function recovers the value of an Excel user file and process them and return the information in a table.
.DESCRIPTION
	This function recovers the value of an Excel user file and process them and return the information in a table.
.PARAMETER FilePath
	Specify the Excel file containing the user information.
.EXAMPLE
    PS C:\> FakeCompanyUsers -CSVFile C:\new_Users.csv
 
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
    $LocalDomain = "corp.priv"
    $ExternalDomain = "corporate.com"
    $Password = "Azerty1"

    ## Function ##
    function Remove-StringLatinCharacters
    {
        PARAM ([string]$String)
        [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String))
    }

    function FormattingVar
    {
        [CmdletBinding()]
        [OutputType( [System.Object] )]
        PARAM
        (
            [System.string]$String
        )
        $String = Remove-StringLatinCharacters $String
        $String = $String.replace(' ','')
        $String = $String.ToLower()
        return ,$String
    }


    ## Beginning of the script ##
    $Content = Import-Csv -Path "$CSVFile" 
    foreach ($User in $Content)
    {
        ## GivenName ##
        $GivenName = $User.GivenName.substring(0,1).toupper()+$User.GivenName.substring(1).tolower() 

        ## Surname ##
        $SurName = $User.Surname.ToUpper()

        ## SamAccountName ##
        $GivenNameFormat = FormattingVar $GivenName
        $SurNameFormat = FormattingVar $SurName
        $SamAccountName = $GivenNameFormat.ToLower()+"."+$SurNameFormat.ToLower()

        ## Name ##
        $Name = $SurName+" "+$GivenName+" ("+$SamAccountName+")"

        ## Password ##
        $Password = ConvertTo-SecureString -AsPlainText $Password -force

        ## Email ##
        $Email = $SamAccountName+"@"+$ExternalDomain

        ## UserPrincipalName ##
        $UserPrincipalName = $SamAccountName+"@"+$LocalDomain
        
        ## DisplayName ##
        $DisplayName = $User.('Surname')+" "+$User.('GivenName')

        ## Initials ##
        $Initials = $User.SurName.substring(0,1).toupper()+$User.GivenName.substring(0,1).toupper()

        ## department group ##
        $DepartmentGroup = $User.('DepartmentGroup')

        ## Business group ##
        $BusinessGroup = $User.('BusinessGroup')


        Write-Debug $Name ## DOE Jane
        Write-Debug $GivenName ## Jane --
        Write-Debug $SurName ## DOE --
        Write-Debug $User.('Path') ## OU=Paris,OU=Sites,OU=CORP,DC=corp,DC=priv --
        Write-Debug $Password ## System.Security.SecureString
        Write-Debug $Email ## jane.doe@corporate.com
        Write-Debug $SamAccountName ## jane.doe
        Write-Debug $UserPrincipalName ## DOE Jane
        Write-Debug $DisplayName ## DOE Jane
        Write-Debug $User.('Company') ## Corporate --
        Write-Debug $User.('Department') ## Direction --
        Write-Debug $User.('Title') ## Chief executive officer --
        Write-Debug $User.('Office') ## 110 --
        Write-Debug $User.('OfficePhone') ## +33 1 60 84 00 26 --
        Write-Debug $User.('PostalCode') ## 75008 --
        Write-Debug $User.('City') ## Paris --
        Write-Debug $User.('StreetAddress') ## 55 Rue du Faubourg Saint-Honoré --
        Write-Debug $User.('Description') ## Corporate User --
        Write-Debug $User.('Manager') ## CN=Administrator,CN=Users,DC=corp,DC=priv --
        Write-Debug $User.('Country') ## FR --
        Write-Debug $DepartmentGroup ## GRP_DPT_DIR
        Write-Debug $BusinessGroup ## GRP_MET_DIR


        $ADUserExist = $(try {Get-ADUser $SamAccountName} catch {$null})
        If ($ADUserExist) 
        {
            Write-Host "The user $Name already exists"
        } 
        else 
        {
            New-ADuser -Name $Name `
            -GivenName $User.('GivenName') `
            -Surname $User.('Surname') `
            -Path $User.('Path') `
            -AccountPassword $Password `
            -EmailAddress $Email `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UserPrincipalName `
            -DisplayName $DisplayName `
            -Company $User.('Company') `
            -Department $User.('Department') `
            -Title $User.('Title') `
            -Office $User.('Office') `
            -OfficePhone $User.('OfficePhone') `
            -PostalCode $User.('PostalCode') `
            -City $User.('City') `
            -StreetAddress $User.('StreetAddress') `
            -Description $User.('Description') `
            -Country $User.('Country') `
            -Initials $Initials `
            -Enabled $true `
            -CannotChangePassword $true `
            -PasswordNeverExpires $true
        
            If ($User.('Manager')) 
            {
                Set-ADUser -Identity $SamAccountName `
                -Manager $User.('Manager') 
            }

            ## If the Departement Group exist
            $ADGroupExist = $(try {Get-ADGroup $DepartmentGroup} catch {$null})
            If ($ADGroupExist) 
            {
                Add-ADGroupMember $DepartmentGroup -Members $SamAccountName
            } 

            ## If the Departement Group exist
            $ADGroupExist = $(try {Get-ADGroup $BusinessGroup} catch {$null})
            If ($ADGroupExist) 
            {
                Add-ADGroupMember $BusinessGroup -Members $SamAccountName
            } 

            Write-Host "The user $Name was created"
        }
    }
}
## Ending of the script ##