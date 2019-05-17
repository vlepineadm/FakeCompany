$Name
$DisplayName
$Description
$Path

New-ADGroup -Name "GRP_DPT_JUR" `
-DisplayName "GRP_DPT_JUR" `
-Description "Département Juridique" `
-Path "OU=Groups,OU=Paris,OU=Sites,OU=CORP,DC=corp,DC=priv" -GroupCategory Security -GroupScope Global