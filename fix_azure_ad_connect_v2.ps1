#Fix Veeam backup VSS error when Azure AD Sync has updated by fixing SQL Server installation

Set-ExecutionPolicy Unrestricted
$now = get-date -format yyyMdd
$adconnect = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{0415663A-7211-4734-A63B-B23D0F2E4364}" |  Select-Object | where-object {$_.InstallDate -eq $now}
if(!$adconnect){
exit 0
}else{
stop-service -displayname "Microsoft Azure AD Sync"
$FQlogonaccount = Get-WmiObject -Class Win32_Service | ? { $_.displayname -match "Microsoft Azure AD Sync"} | select Startname 
$split = $FQlogonaccount.startname.Split("\"[0])
$username = $split[1]
$sqlprocess = Get-WmiObject -Query "Select * from Win32_Process where name = 'sqlservr.exe'" | Select Name, Handle, @{Label='Owner';Expression={$_.GetOwner().User}} | ? { $_.owner -match $username} | select handle | Out-String 
$sqlpid= $sqlprocess.Split("`n")[3]
Stop-Process -id $sqlpid -force
start-process -filepath "MsiExec.exe" -argumentlist "/f {6C026A91-640F-4A23-8B68-05D589CC6F18}" -wait
Start-Service -displayname "Microsoft Azure AD Sync"
}