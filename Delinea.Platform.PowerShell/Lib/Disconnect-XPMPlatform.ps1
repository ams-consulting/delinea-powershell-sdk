###########################################################################################
# Delinea Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT ams-consulting.uk
# Release  : 21/02/2022
# License  : MIT License
#
# Copyright (c) 2024 AMS Consulting.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###########################################################################################

<#
.SYNOPSIS
This Cmdlet is closing an existing secure connection with a Delinea XPM Platform tenant.

.DESCRIPTION
This Cmdlet is closing an existing secure connection with a Delinea XPM Platform tenant.

.INPUTS

.OUTPUTS

.EXAMPLE
PS C:\> Disconnect-XPMPlatform

#>
function Disconnect-XPMPlatform {
    param ()

    try {	
        # Set Security Protocol for RestAPI (must use TLS 1.2)
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Test current connection to the XPM Platform
        if ($Global:PlatformConnection -eq [Void]$null) {
            # Inform connection does not exists and suggest to initiate one
            Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
            Break
        } else {
            # Get existing connexion details
            $PodFqdn = $Global:PlatformConnection.PodFqdn
            $User = $Global:PlatformConnection.User
            # Delete existing connexion cache
            $Global:PlatformConnection = $null
            Write-Host ("`nPodFqdn : {0}" -f $PodFqdn)
            Write-Host ("User    : {0}" -f $User)
            Write-Host ("Summary : Connection closed.`n")
        }
    } catch {
        Throw $_.Exception
    }
}