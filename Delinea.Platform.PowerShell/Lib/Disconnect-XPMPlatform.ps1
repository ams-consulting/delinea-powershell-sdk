###########################################################################################
# Delinea Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : contact AT ams-consulting.uk
# Release  : 21/02/2022
# Copyright: (c) 2022 Delinea Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
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
        }
        else {
            # Get existing connexion details
            $PodFqdn = $Global:PlatformConnection.PodFqdn
            $User = $Global:PlatformConnection.User
            # Delete existing connexion cache
            $Global:PlatformConnection = $null
            Write-Host ("`nPodFqdn : {0}" -f $PodFqdn)
            Write-Host ("User    : {0}" -f $User)
            Write-Host ("Summary : Connection closed.`n")
        }
    }
    catch {
        Throw $_.Exception
    }
}