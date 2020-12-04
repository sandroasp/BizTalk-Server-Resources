#############################################################################
#                                                                           #
# Specify that the default security protocol on BizTalk Server is TLS 1.2.  #
# Author: Sandro Pereira                                                    #
#                                                                           #
#############################################################################

Push-Location

#Define Register path
Set-Location HKLM:

######################################################################################################################
# create or update the necessary DWORD's on HKEY_LOCAL_MACHINE to configure TLS 1.2 as the default security protocol #
######################################################################################################################
if((Test-Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2'))
{ 
    if((Test-Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client') -eq $false)
    {
        New-Item -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2' -Name 'Client'
    }
    if((Test-Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server') -eq $false)
    {
        New-Item -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2' -Name 'Server'
    }
}
else
{
    New-Item -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' -Name 'TLS 1.2'
    New-Item -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2' -Name 'Client'
    New-Item -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2' -Name 'Server'
}

# Add or Update Client DWORD's
New-ItemProperty -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null

# Add or Update Server DWORD's
New-ItemProperty -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path '.\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null

#######################################################################################################################
# set the .NET Framework 4.0 to use the latest version of the SecurityProtocol, by creating SchUseStrongCrypto DWORDs #
# for both 32- and 64-bit hosts                                                                                       #
#######################################################################################################################
New-ItemProperty -Path '.\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path '.\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -PropertyType DWORD -Force | Out-Null

#Leave Register
Pop-Location