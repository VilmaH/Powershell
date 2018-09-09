<#
.Synopsis
   Search-IISLog
.DESCRIPTION
   Parses the selected IIS logfile. F.ex. activesync log.
.EXAMPLE
   Search-IISLog -Logfile "c:\inetpub\logs\a1234.log" -SearchString "DOMAIN\user.name" -OnlyErrors $true
.EXAMPLE
   $parsedlog=Search-IISLog -Logfile "c:\inetpub\logs\a1234.log" -SearchString "user.name" -OnlyErrors $false
#>
function Search-IISLog
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Log File Location
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Logfile,

        # String to search
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $SearchString,

        # Show only errors
        [bool]
        $OnlyErrors
    )

    Begin
    {
    }
    Process
    {
    #Parseta IIS-logia:

    $log=get-content $logfile

    
    $usercontent=$log | ? {$_ -match $SearchString}


    #haetaan myös virhekoodi perästä
    $results=$usercontent | select @{Name="Username";Expression={($_ -split (" "))[7]}},@{Name="Ip-address";Expression={($_ -split (" "))[8]}},@{Name="Originatin_IP";Expression={($_ -split (" "))[2]}},@{Name="Client";Expression={($_ -split (" "))[9]}},@{Name="ErrorCode";Expression={($_ -split ("-"))[-1]}}

    #hae virhekoodilla koneelta (errorcoden kolmas rivi (numerosarja) yleensä):

    #net helpmsg 1326

    if (!$OnlyErrors)
    {
    return $results | ft
    }
    else
    {
    return $results | ? {$_.errorcode -notmatch "200"} | ft
    }
    End
    {
    }
}
}
