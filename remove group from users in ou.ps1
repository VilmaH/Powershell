#This script removes GROUP group from users that are in the OUs defined in $sb.

$logfile = "logfile.log"
$sb = "OU=Disabled,DC=example,DC=com","OU=Deleted,DC=example,DC=com" 

foreach($search in $sb){
    
    $users = Get-AdUser -SearchBase $search -Filter *

    foreach($user in $users){

        if(Get-ADPrincipalGroupMembership -Identity $user | Select Name | Where-Object { $_ -like '*GROUP*' }){

            Remove-ADGroupMember -Identity GROUP -Members $user -Confirm:$false
            Add-Content $logFile "$(Get-Date -format u) - $user"  -Encoding UTF8
        }
    }
}