## Global variables ##
$Domain = "cofi.priv"
$OperatingSystem = "Windows 10 Enterprise"
$OperatingSystemVersion = "10.0 (17763)"

## Beginning of the script ##
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

