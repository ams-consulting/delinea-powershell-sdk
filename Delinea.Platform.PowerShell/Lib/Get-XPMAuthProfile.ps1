###########################################################################################
# Delinea Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT Delinea.com
# Release  : 21/02/2022
# Copyright: (c) 2022 Delinea Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################

<#
.SYNOPSIS
This Cmdlet retrieves important information about Authentication Profile(s) on the system.

.DESCRIPTION
This Cmdlet retrieves important information about Authentication Profile(s) on the system. Can return a single Profile by specifying the Name.

.PARAMETER Name
Specify the Authentication Profile by its Name.

.INPUTS
None

.OUTPUTS
[Object]XpmAuthProfile

.EXAMPLE
PS C:\> Get-XPMAuthProfile 
Outputs all Authentication Profile objects existing on the system

.EXAMPLE
PS C:\> Get-XPMAuthProfile -Name "Default Password Reset Profile"
Return Authentication Profile with name Default Password Reset Profile if exists
#>
function Get-XPMAuthProfile {
	param (
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Authentication Profile by its Name.")]
		[System.String]$Name
	)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//AuthProfile/GetProfileList" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json"
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "true"; "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if($WebResponseResult.Success) {
			# Get raw data
			return $WebResponseResult.Result
		}
		else {
			# Query error
			Throw $WebResponseResult.Message
		}
	}
	catch {
		Throw $_.Exception
	}
}
