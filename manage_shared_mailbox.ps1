#
#This script goes through every security group in an OU and assigns their users Full Access and SendAs permissions to a shared mailbox with the same name as the group.
#
#For example if group name is mbx_testi.laatikko then shared mailbox is testi.laatikko@pihlajalinna.fi
#
#This requires App registration in Azure AD https://docs.microsoft.com/en-us/powershell/exchange/app-only-auth-powershell-v2?view=exchange-ps#setup-app-only-authentication
#

[string] $logFile = "$(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)\log\$(Get-Date -format yyyy-MM-dd)-manage_shared_mbx.log"

trap [Exception] {
	Add-Content $logFile "$(Get-Date -format u) Exception: $($_.Exception.GetType().FullName)"
	Add-Content $logFile "$(Get-Date -format u) Exception: $($_.Exception.Message)"
	Add-Content $logFile "$(Get-Date -format u) Exception: $($_.Exception.StackTrace)"
	continue; # Continue on Exception
}

Connect-ExchangeOnline -CertificateThumbPrint "XXXX" -AppID "YYYY" -Organization "contoso.onmicrosoft.com"

$groups = Get-ADGroup -Filter * -SearchBase "OU=Groups,DC=contoso,DC=com"

foreach($group in $groups){
    $mbx = $group.name.Split("_")[1]
    $members = Get-ADGroupMember -identity $group.name -Recursive
    $users = Get-ExoMailboxPermission -identity $mbx | where { ($_.User -like '*@contoso.com') }
    $users2 = Get-ExoRecipientPermission -Identity $mbx | where { ($_.Trustee -like '*@contoso.com') }
    foreach($user in $users){
        $u = $user.user.split("@")[0]
        if($u.Length -gt 20){
            $u = $u.substring(0,20)
        }
        if($members.samaccountname -notcontains $u){
            Remove-MailboxPermission -identity $mbx -User $user.user -AccessRights FullAccess -Confirm:$false
            Add-Content $logFile "$(Get-Date -format u) Removed $($user.user) from $mbx FullAccess permissions" -Encoding UTF8 

        }
    }
    foreach($usr in $users2){
        $u = $usr.trustee.split("@")[0]
        if($u.Length -gt 20){
            $u = $u.substring(0,20)
        }
        if($members.samaccountname -notcontains $u){
            Remove-RecipientPermission -identity $mbx -Trustee $usr.Trustee -AccessRights SendAs -Confirm:$false
            Add-Content $logFile "$(Get-Date -format u) Removed $($user.user) from $mbx SendAs permissions" -Encoding UTF8 
        }
    }
    foreach($member in $members){
        
        $upn = get-aduser -identity $member | select UserPrincipalName
        if($users.user -notcontains $upn.UserPrincipalName){
        Add-MailboxPermission –Identity $mbx –User $upn.userprincipalname –AccessRights ‘FullAccess’ –InheritanceType All -AutoMapping $true -Confirm:$false
        Add-Content $logFile "$(Get-Date -format u) Added $($upn.UserPrincipalName) to $mbx FullAccess permissions" -Encoding UTF8 
        }
       
        if($users2.trustee -notcontains $upn.UserPrincipalName){
        Add-RecipientPermission -Identity $mbx -Trustee $upn.userprincipalname -AccessRights SendAs -Confirm:$false
        Add-Content $logFile "$(Get-Date -format u) Added $($upn.UserPrincipalName) to $mbx SendAs permissions" -Encoding UTF8 
        }
    }   
}
