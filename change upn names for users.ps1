Get-ADUser �Filter * -Properties SamAccountName -searchbase  "OU=users,DC=testi,DC=local" | foreach {
$upn = "$($_.givenName).$($_.Surname)@contoso.com".ToLower()
$upn = $upn -replace "�","a"
$upn = $upn -replace "�","o"
$upn = $upn -replace "�","a"

Set-ADUser $_ -UserPrincipalName $upn}