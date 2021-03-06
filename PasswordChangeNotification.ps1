##################################################################################################################
# Please Configure the following variables....
$smtpServer="smtp.example.com"
$from = "administrator@example.com"
$expireindays = 14
###################################################################################################################


Import-Module ActiveDirectory
#For testing limit users only to testi.testaaja
#$users = get-aduser -properties * 'testi.testaaja'

#Get enabled Users From AD
$users = get-aduser -filter * -properties * |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
 

foreach ($user in $users)
{
  $Name = (Get-ADUser $user | foreach { $_.Name})
  $emailaddress = $user.emailaddress
  $passwordSetDate = (get-aduser $user -properties * | foreach { $_.PasswordLastSet })
  $maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
  $expireson = $passwordsetdate + $maxPasswordAge
  $today = (get-date)
  $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
  $subject="Salasanasi vanhenee $daystoExpire paivassa"
  $body ="
  Hyva $name,
  <p> Windowsin salasanasi vanhenee $daystoexpire paivassa.<br>
  Muista vaihtaa se ajoissa.
  </P>"
  
  if ($daystoexpire -lt $expireindays)
  {
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High
     
  }  
   
}