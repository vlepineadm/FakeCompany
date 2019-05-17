
$LocalDomain = "corp.priv"
$ExternalDomain = "corporate.com"
$Password = "Azerty1"


# Import du module Active Directory
Try 
{
    Import-Module ActiveDirectory
}
Catch [FileNotFoundException]
{
    
}


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
$Content = Import-Csv -Path "C:\new_Users.csv" 
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
    Write-Debug $User.('Manager') ## Blank --
    Write-Debug $User.('Country') ## FR --


    $ADUserExist = $(try {Get-ADUser $SamAccountName} catch {$null})
    If ($ADUserExist) 
    {
        Write-Host "The user already exists"
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
        Write-Host "The user was created"
    }
}
## Ending of the script ##


#Add-ADGroupMember -Identity $_."group" -Members $_."samaccountname";
