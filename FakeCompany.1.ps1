
    $Content = Import-Csv -Path "$CSVFile"


    foreach ($OU in $Content)
    {
        ### Creating OU Structure ###
        
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
        ## End of function FakeCompanyOU ##
    }



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
## End of function FakeCompanyGroups ##


Function FakeCompanyUsers
{
<#
.SYNOPSIS
	This function allows you to create Active Directory users from CSV file.
.DESCRIPTION
	This function allows you to create Active Directory users from CSV file.
.PARAMETER FilePath
	Specify the path of a CSV file containing user information.
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
    $Password = 'P@ssW0rd!'

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


    $Content = Import-Csv -Path "$CSVFile" 

    ### Creating Users ###
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
## End of function FakeCompanyUsers ##


Function FakeCompanyComputers
{
<#
.SYNOPSIS
	This function allows you to create Active Directory computers from CSV file.
.DESCRIPTION
	This function allows you to create Active Directory computers from CSV file.
.PARAMETER FilePath
	Specify the path of a CSV file containing computers information.
.EXAMPLE
    PS C:\> FakeCompanyComputers -CSVFile C:\new_Computers.csv
 
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
    $Domain = "cofi.priv"
    $OperatingSystem = "Windows 10 Enterprise"
    $OperatingSystemVersion = "10.0 (17763)"

    ### Creating Computers ###
    $Content = Import-Csv -Path "C:\new_Computers.csv" 
    foreach ($Computer in $Content)
    {
        ## Name ##
        $Name = $Computer.('Name')

        ## SamAccountName ##
        $SamAccountName = $Computer.('Name')

        ## DNSHostName ##
        $DNSHostName = $Name+""+$Domain

        Write-Debug $Name ## WD01
        Write-Debug $SamAccountName ## WD01
        Write-Debug $DNSHostName
        Write-Debug $Computer.('Path') ## OU=Computers,OU=Paris,OU=Sites,OU=CORP,DC=corp,DC=priv
        Write-Debug $OperatingSystem ## Windows 10 Enterprise
        Write-Debug $OperatingSystemVersion ## 10.0 (17763)

        ## If the Computer exist
        $ADComputerExist = $(try {Get-ADComputer $Name} catch {$null})
        If ($ADComputerExist) 
        {
            Write-Host "The Computer $Name already exists"
        } 
        else 
        {   
            New-ADComputer -Name $Name `
            -SamAccountName $SamAccountName  `
            -DNSHostName $DNSHostName `
            -Path $Computer.('Path') `
            -OperatingSystem $OperatingSystem `
            -OperatingSystemVersion $OperatingSystemVersion

            Write-Host "The Computer $Name was created"
        }
    }
}
## End of function FakeCompanyComputers ##




## Start to create Fake Company ##
Function FakeCompany
{
<#
.SYNOPSIS
	This function allows you to create Active Directory OU, Groups, Users, Computers from CSV file.
.DESCRIPTION
	This function allows you to create Active Directory OU, Groups, Users, Computers from CSV file.
.PARAMETER FilePath
	Specify the path of a CSV file containing computers information.
.EXAMPLE
    PS C:\> FakeCompany -CSVFolder C:\
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
        [System.String]$CSVFolder
    )

    If ((Test-Path "$CSVFolder\new_OU.csv") -eq $True) 
    {
        Write-Debug "Launching the FakeCompanyOU function"
        FakeCompanyOU -CSVFile "$CSVFolder\new_OU.csv"
    }
    else 
    {
        Write-Error "Could not find the file new_OU.csv in the directory $CSVFolder"    
    }


    If ((Test-Path "$CSVFolder\new_Groups.csv") -eq $True) 
    {
        Write-Debug "Launching the FakeCompanyGroups function"
        FakeCompanyGroups -CSVFile "$CSVFolder\new_Groups.csv"
    }
    else 
    {
        Write-Error "Could not find the file new_Groups.csv in the directory $CSVFolder"    
    }
    

    If ((Test-Path "$CSVFolder\new_Users.csv") -eq $True) 
    {
        Write-Debug "Launching the FakeCompanyUsers function"
        FakeCompanyUsers -CSVFile "$CSVFolder\new_Users.csv"
    }
    else 
    {
        Write-Error "Could not find the file new_Users.csv in the directory $CSVFolder"    
    }


    If ((Test-Path "$CSVFolder\new_Computers.csv") -eq $True) 
    {
        Write-Debug "Launching the FakeCompanyComputers function"
        FakeCompanyComputers -CSVFile "$CSVFolder\new_Computers.csv"
    }
    else 
    {
        Write-Error "Could not find the file new_Computers.csv in the directory $CSVFolder"    
    }

}
## End to create Fake Company ##

