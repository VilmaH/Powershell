param([string]$path)
Get-ADUser -Filter * -Properties * | export-csv $path -NoClobber -NoTypeInformation -Encoding Unicode