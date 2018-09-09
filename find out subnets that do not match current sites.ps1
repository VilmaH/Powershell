
$ipt=(get-content "c:\windows\debug\netlogon.log" | where {$_ -match "NO_CLIENT_SITE"})
$listaus=@()

$listaus=

foreach ($ip in $ipt)
{
($ip -split " ")[-1]
#$ip.substring((6),($ip.length-1))
}


$listaus | select -unique | sort-object
