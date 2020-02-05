#
# Fetches user's certificate from VRK LDAP and installs it in local AD under user object
#
# Requires https://gallery.technet.microsoft.com/scriptcenter/Using-SystemDirectoryServic-0adf7ef5#content

param(
    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$serial,
    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [int]$employeeid
)


process {

    if($employeeid -gt "160000")
    {
        Write-Error "Employeeid number too big" -ErrorAction Continue
    }else{

        #.net object for handling bytearray to windows cert object
        $Certobject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

        $Ldapconnection = Get-LdapConnection -LdapServer "ldap.fineid.fi:389" -AuthType Anonymous
 
        $cn = Find-LDAPObject -LdapConnection $ldapconnection -searchFilter:"(serialnumber=$serial)" -searchBase:"c=FI" -searchScope Subtree

        if ($null -eq $cn) {
            Write-Error "No certificate found for serial $serial" -ErrorAction Continue
        }
        #if the returned array is longer than 1, we have multiple certificates
        elseif ($cn.Length -gt 1) {
            Write-Error "Multiple certificates found for serial $serial" -ErrorAction Continue
        }else {
            #we proceed to get the binary data from the ldap connection
            $ldapcert = Find-LDAPObject -LdapConnection $ldapconnection -searchFilter:"(ObjectClass=*)" -searchBase $cn -searchScope Base -RangeSize 0 -PropertiesToLoad:@("userCertificate;binary") -BinaryProperties:@("userCertificate;binary")
            $certificatebinary = $ldapcert."userCertificate;binary"
            #put binary data into .net certficate object.
            $Certobject.Import($certificatebinary)
            $decimalserial = [convert]::ToInt64($certobject.SerialNumber,16)
            $extensions = $Certobject.Extensions
            $asnarray = @()
            foreach ($e in $extensions) {
                $asn = New-Object -TypeName System.Security.Cryptography.AsnEncodedData($e.oid, $e.rawdata)

                $asnformatted= $asn.Format($true)

                $asnarray += @{$asn.Oid.Value=$asnformatted;FriendlyName=$asn.Oid.FriendlyName}
            }

            $mail = ((($asnarray."2.5.29.17") -replace "`r`n","").Split('='))[1]

            #check to see if certifcate has expired
            $expired = ""
            if($Certobject.NotAfter -lt (Get-Date)){
                 $expired = $true
                 Write-Error "Certificate expired for serial $serial" -ErrorAction Continue
            }
            else{
            
                $dn = get-aduser -filter {employeeid -eq $employeeid} | select distinguishedname
                if($dn -eq $null){
                    Write-Error "User $employeeid not found in AD" -ErrorAction Continue
                }else{
                    $dn = $dn.distinguishedname.Split(",")
                    [array]::Reverse($dn)
                    $dn = [system.String]::Join(",", $dn)

                    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate]::new($certificatebinary)
                    $alt = " X509:<I>"+$cert.GetIssuerName()+"<S>"+$cert.GetName()
                    $alt = $alt.Split(",").Substring(1)
                    $alt = [system.String]::Join(",", $alt)
                    $alt2 = "X509:<I>DC=fi,DC=dextra,CN=PihlajalinnaCA<S>"+$dn
                                        
                    Get-ADUser -filter {employeeid -eq $employeeid} | set-aduser -Certificates @{Add=$cert} -Add @{'altSecurityIdentities'=$alt,$alt2} -Replace @{'extensionattribute1'=$mail}
                    Write-Host "Certificate installed to user $employeeid"
                }
            }
        }
    }
}end{
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
