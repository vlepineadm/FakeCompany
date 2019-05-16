###########################################################
#  This script allows you to create active directory      #
#  users by using a CSV file, add specific group and      #
#  set specific password  and OU for every user.          #
#                                                         #
# created on 2016/07/18 by Daniele Managò                 #  
###########################################################

$LocalDomain = "corp.priv"
$ExternalDomain = "corporate.priv"
$Password = "Azerty1"

## Modules ##
import-module activedirectory

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


    Write-Host $Name ## DOE Jane
    Write-Host $GivenName ## Jane --
    Write-Host $SurName ## DOE --
    Write-Host $User.('Path') ## OU=Paris,OU=Sites,OU=CORP,DC=corp,DC=priv --
    Write-Host $Password ## System.Security.SecureString
    Write-Host $Email ## jane.doe@corporate.com
    Write-Host $SamAccountName ## jane.doe
    Write-Host $UserPrincipalName ## DOE Jane
    Write-Host $DisplayName ## DOE Jane
    Write-Host $User.('Company') ## Corporate --
    Write-Host $User.('Department') ## Direction --
    Write-Host $User.('Title') ## Chief executive officer --
    Write-Host $User.('Office') ## 110 --
    Write-Host $User.('OfficePhone') ## +33 1 60 84 00 26 --
    Write-Host $User.('PostalCode') ## 75008 --
    Write-Host $User.('City') ## Paris --
    Write-Host $User.('StreetAddress') ## 55 Rue du Faubourg Saint-Honoré --
    Write-Host $User.('Description') ## Corporate User --
    Write-Host $User.('Manager') ## Blank --
    Write-Host $User.('Country') ## FR --

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
    -Manager $User.('Manager') `
    -Country $User.('Country') `
    -Enabled $true
}



Add-ADGroupMember -Identity $_."group" -Members $_."samaccountname";
