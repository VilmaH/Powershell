Get-ADUser –Filter * -Properties SamAccountName -searchbase  "OU=users,DC=testi,DC=local" | foreach {
$upn = "$($_.givenName).$($_.Surname)@contoso.com".ToLower()
$upn = $upn -replace "ä","a"
$upn = $upn -replace "ö","o"
$upn = $upn -replace "å","a"

Set-ADUser $_ -UserPrincipalName $upn}