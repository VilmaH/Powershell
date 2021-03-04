#
#This script goes through every Shared Mailbox in Exchange Online and creates a group in local AD and populates that group with users that have FullAccess-permission for the shared mailbox
#
#This requires App registration in Azure AD https://docs.microsoft.com/en-us/powershell/exchange/app-only-auth-powershell-v2?view=exchange-ps#setup-app-only-authentication
#

Connect-ExchangeOnline -CertificateThumbPrint "XXXXX" -AppID "YYYY" -Organization "contoso.onmicrosoft.com"

$mbxs = Get-Mailbox -RecipientTypeDetails SharedMailbox

foreach($mbx in $mbxs){
$groupname = "mbx_" + $mbx.alias
$members = Get-MailboxPermission -Identity $mbx.alias | where { ($_.User -like '*@contoso.com') }
foreach($member in $members){
    $member.user = $member.user.split('@')[0]
    if($member.user.length -gt 20){
        $member.user = $member.user.substring(0,20)
    }
}

New-ADGroup -Name $groupname -SamAccountName $groupname -GroupCategory Security -GroupScope Global -DisplayName $groupname -Path "OU=Shared Mailboxes,OU=Groups,DC=contoso,DC=com"
Add-ADGroupMember -Identity $groupname -Members $Members.User
}