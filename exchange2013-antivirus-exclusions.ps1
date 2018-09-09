$AllPathExclusions=@()
$server=$env:COMPUTERNAME

###Mailbox databases
#Exchange databases, checkpoint files, and log files. By default, these are located in sub-folders under the ($env:ExchangeInstallPath + "Mailbox folder. To determine the location of a mailbox database, transaction log, and checkpoint file, run the following command: 
#$AllPathExclusions+=$(Get-MailboxDatabase -Server $server | select -expandproperty *path*)
$properties=(Get-MailboxDatabase | get-member | ? {$_.membertype -eq "Property" -and $_.name -match "path"}) |select -ExpandProperty name
$properties | % {$property=$_;$AllPathExclusions+=(Get-MailboxDatabase -Server $server | select -expandproperty $property | select -expandproperty pathname)}
#Database content indexes. By default, these are located in the same folder as the database file.

#Group Metrics files. By default, these files are located in the 
$AllPathExclusions+=($env:ExchangeInstallPath + "GroupMetrics")

#General log files, such as message tracking and calendar repair log files. By default, these files are located in subfolders under the ($env:ExchangeInstallPath + "TransportRoles\Logs folder and ($env:ExchangeInstallPath + "Logging folder. To determine the log paths being used, run the following command in the Exchange Management Shell: 
#$AllPathExclusions+=(Get-MailboxServer $server | select -expandproperty *path*)
$properties=(Get-MailboxServer $server | get-member | ? {$_.membertype -eq "Property" -and $_.name -match "path"}) |select -ExpandProperty name
$properties | % {$property=$_;$AllPathExclusions+=(Get-MailboxServer $server | select -expandproperty $property | select -expandproperty pathname)}
#The Offline Address Book files. By default, these are located in subfolders under the ($env:ExchangeInstallPath + "ClientAccess\OAB folder.
$AllPathExclusions+=($env:ExchangeInstallPath + "ClientAccess\OAB")

#IIS system files in the ($env:systemroot + "\System32\Inetsrv folder.
$AllPathExclusions+=($env:systemroot + "\System32\Inetsrv")

#The Mailbox database temporary folder: ($env:ExchangeInstallPath + "Mailbox\MDBTEMP
$AllPathExclusions+=($env:ExchangeInstallPath + "Mailbox\MDBTEMP")

###Members of Database Availability Groups
#All the items listed in the Mailbox databases list, and the cluster quorum database that exists at ($env:windir + "\Cluster.
$AllPathExclusions+=($env:windir + "\Cluster")

#The witness directory files. These files are located on another server in the environment, typically a Client Access server that isn’t installed on the same computer as a Mailbox server. By default, the witness directory files are located in ($env:systemdrive + ":\DAGFileShareWitnesses\<DAGFQDN>.
#$AllPathExclusions+=($env:systemdrive + ":\DAGFileShareWitnesses\<DAGFQDN>.

###Transport service
#Log files, for example, message tracking and connectivity logs. By default, these files are located in subfolders under the ($env:ExchangeInstallPath + "TransportRoles\Logs folder. To determine the log paths being used, run the following command in the Exchange Management Shell: Get-TransportService <servername> | Format-List *logpath*,*tracingpath*
$properties=(Get-TransportService | get-member | ? {$_.membertype -eq "Property" -and $_.name -match "logpath" -or $_.name -match "tracingpath"}) |select -ExpandProperty name
$properties | % {$property=$_;$AllPathExclusions+=(Get-TransportService $server | select -expandproperty $property | select -expandproperty pathname)}

#Pickup and Replay message directory folders. By default, these folders are located under the ($env:ExchangeInstallPath + "TransportRoles folder. To determine the paths being used, run the following command in the Exchange Management Shell: Get-TransportService <servername>| Format-List *dir*path*
$properties=(Get-TransportService | get-member | ? {$_.membertype -eq "Property" -and $_.name -match "path" -and $_.name -match "dir"}) |select -ExpandProperty name
$properties | % {$property=$_;$AllPathExclusions+=(Get-TransportService $server | select -expandproperty $property | select -expandproperty pathname)}

#The queue databases, checkpoints, and log files. By default, these are located in the ($env:ExchangeInstallPath + "TransportRoles\Data\Queue folder.
$AllPathExclusions+=($env:ExchangeInstallPath + "TransportRoles\Data\Queue")

#The Sender Reputation database, checkpoint, and log files. By default, these are located in the ($env:ExchangeInstallPath + "TransportRoles\Data\SenderReputation folder.
$AllPathExclusions+=($env:ExchangeInstallPath + "TransportRoles\Data\SenderReputation")

#The temporary folders that are used to perform conversions:
#By default, content conversions are performed in the Exchange server’s %TMP% folder.
#By default, rich text format (RTF) to MIME/HTML conversions are performed in ($env:ExchangeInstallPath + "\Working\OleConverter folder.
$AllPathExclusions+=$env:TMP
$AllPathExclusions+=($env:ExchangeInstallPath + "Working\OleConverter")

#The content scanning component is used by the Malware agent and data loss prevention (DLP). By default, these files are located in the ($env:ExchangeInstallPath + "FIP-FS folder.
$AllPathExclusions+=($env:ExchangeInstallPath + "FIP-FS")

###Mailbox Transport service
#Log files, for example, connectivity logs. By default, these files are located in subfolders under the ($env:ExchangeInstallPath + "TransportRoles\Logs\Mailbox folder. To determine the log paths being used, run the following command in the Exchange Management Shell: Get-MailboxTransportService <servername> | Format-List *logpath*
#$AllPathExclusions+=(Get-MailboxTransportService $server | Format-List *logpath*)
$properties=(Get-MailboxTransportService | get-member | ? {$_.membertype -eq "Property" -and $_.name -match "path"}) |select -ExpandProperty name
$properties | % {$property=$_;$AllPathExclusions+=(Get-MailboxTransportService $server | select -expandproperty $property | select -expandproperty pathname)}

###Unified Messaging
#The grammar files for different locales, for example en-EN or es-ES. By default, these are stored in the subfolders in the ($env:ExchangeInstallPath + "UnifiedMessaging\grammars folder.
$AllPathExclusions+=($env:ExchangeInstallPath + "UnifiedMessaging\grammars")

#The voice prompts, greetings and informational message files. By default, these are stored in the subfolders in the ($env:ExchangeInstallPath + "UnifiedMessaging\Prompts folder
$AllPathExclusions+=($env:ExchangeInstallPath + "UnifiedMessaging\Prompts")

#The voicemail files that are temporarily stored in the ($env:ExchangeInstallPath + "UnifiedMessaging\voicemail folder.
$AllPathExclusions+=($env:ExchangeInstallPath + "UnifiedMessaging\voicemail")

#The temporary files generated by Unified Messaging. By default, these are stored in the ($env:ExchangeInstallPath + "UnifiedMessaging\temp folder.
$AllPathExclusions+=($env:ExchangeInstallPath + "UnifiedMessaging\temp")

###Setup
#Exchange Server setup temporary files. These files are typically located in ($env:systemroot + "\Temp\ExchangeSetup.
$AllPathExclusions+=($env:systemroot + "\Temp\ExchangeSetup")

###Exchange Search service
#Temporary files used by the Exchange Search service and Microsoft Filter Pack to perform file conversion in a sandboxed environment. These files are located in ($env:systemroot + "\Temp\OICE_<GUID>\.
#$AllPathExclusions+=($env:systemroot + "\Temp\OICE_<GUID>\

###Client Access servers
#Web components
#For servers using Internet Information Services (IIS) 7.0, the compression folder that is used with Microsoft Outlook Web App. By default, the compression folder for IIS 7.0 is located at ($env:systemdrive + "\inetpub\temp\IIS Temporary Compressed Files.
$AllPathExclusions+=($env:systemdrive + "\inetpub\temp\IIS Temporary Compressed Files")

#IIS system files in the ($env:systemroot + "\System32\Inetsrv folder
$AllPathExclusions+=($env:systemroot + "\System32\Inetsrv")

#Inetpub\logs\logfiles\w3svc
$AllPathExclusions+=($env:systemdrive + "\inetpub\logs\logfiles\w3svc")

#Sub-folders in ($env:systemroot + "\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files
$AllPathExclusions+=($env:systemroot + "\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET")

###POP3 and IMAP4 protocol logging
#POP3 folder: ($env:ExchangeInstallPath + "Logging\POP3")
$AllPathExclusions+=($env:ExchangeInstallPath + "Logging\POP3")

#IMAP4 folder: ($env:ExchangeInstallPath + "Logging\IMAP4")
$AllPathExclusions+=($env:ExchangeInstallPath + "Logging\IMAP4")

###Front End Transport service
#Log files, for example, connectivity logs and protocol logs. By default, these files are located in subfolders under the ($env:ExchangeInstallPath + "TransportRoles\Logs\FrontEnd folder. To determine the log paths being used, run the following command in the Exchange Management Shell: Get-FrontEndTransportService <servername> | Format-List *logpath*
$AllPathExclusions+=(Get-FrontEndTransportService $server | select -expandproperty *logpath*)

#Setup
#Exchange Server setup temporary files. These files are typically located in ($env:systemroot + "\Temp\ExchangeSetup.
$AllPathExclusions+=($env:systemroot + "\Temp\ExchangeSetup")

#filter out not existing paths
#deep guard notation. no wild cards and
$RealPathExclusions=$AllPathExclusions | % {if (test-path $_) {$_}}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-Volumepath
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $driveLetter

    )

    Begin
    {
    }
    Process
    {
    
    $DynAssembly = New-Object System.Reflection.AssemblyName('SysUtils')
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('SysUtils', $False)

    # Define [Kernel32]::QueryDosDevice method
    $TypeBuilder = $ModuleBuilder.DefineType('Kernel32', 'Public, Class')
    $PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('QueryDosDevice', 'kernel32.dll', ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static), [Reflection.CallingConventions]::Standard, [UInt32], [Type[]]@([String], [Text.StringBuilder], [UInt32]), [Runtime.InteropServices.CallingConvention]::Winapi, [Runtime.InteropServices.CharSet]::Auto)
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $SetLastError = [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor, @('kernel32.dll'), [Reflection.FieldInfo[]]@($SetLastError), @($true))
    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    $Kernel32 = $TypeBuilder.CreateType()

    $Max = 65536
    $StringBuilder = New-Object System.Text.StringBuilder($Max)
    $ReturnLength = $Kernel32::QueryDosDevice($driveLetter, $StringBuilder, $Max)

    return $StringBuilder.ToString()

    #Write-Host " "
    }
    End
    {
    }
}




$RealpathExclusions | out-file exchange2013_f-secure_exlusions.txt -Encoding utf8
$RealPathExclusions | % {("*" +  (get-volumepath  (($_)[0] + ":")) + (($_ -split ":")[1]) + "\*")  -replace "\\","\\"} | out-file exchange2013_f-secure_exlusions.txt -Encoding utf8 -Append


