#
#This script goes through every security group in an OU and assigns their users Full Access and SendAs permissions to a shared mailbox with the same name as the group.
#
#For example if group name is mbx_testi.laatikko then shared mailbox alias is testi.laatikko
#
#This requires App registration in Azure AD https://docs.microsoft.com/en-us/powershell/exchange/app-only-auth-powershell-v2?view=exchange-ps#setup-app-only-authentication
#

Connect-ExchangeOnline -CertificateThumbPrint "XXXXXXXXX" -AppID "YYYYYYY" -Organization "contoso.onmicrosoft.com"

$groups = Get-ADGroup -Filter * -SearchBase "OU=Shared mailboxes,OU=Groups,DC=contoso,DC=com"
foreach($group in $groups){
    $mbx = $group.name.Split("_")[1]
    $members = Get-ADGroupMember -identity $group.name -Recursive
    $users = Get-MailboxPermission -identity $mbx | where { ($_.User -like '*@contoso.com') }
    $users2 = Get-RecipientPermission -Identity $mbx | where { ($_.Trustee -like '*@contoso.com') }
    foreach($user in $users){
        $u = $user.user.split("@")[0]
        if($u.Length -gt 20){
            $u = $u.substring(0,20)
        }
        if($members.samaccountname -notcontains $u){
            Remove-MailboxPermission -identity $mbx -User $user.user -AccessRights FullAccess -Confirm:$false
        }
    }
    foreach($usr in $users2){
        $u = $usr.trustee.split("@")[0]
        if($u.Length -gt 20){
            $u = $u.substring(0,20)
        }
        if($members.samaccountname -notcontains $u){
            Remove-RecipientPermission -identity $mbx -Trustee $usr.Trustee -AccessRights SendAs -Confirm:$false
        }
    }
    foreach($member in $members){
        Add-MailboxPermission –Identity $mbx –User $member.name –AccessRights ‘FullAccess’ –InheritanceType All -AutoMapping $true -Confirm:$false
        Add-RecipientPermission -Identity $mbx -Trustee $member.name -AccessRights SendAs -Confirm:$false
    }   
}