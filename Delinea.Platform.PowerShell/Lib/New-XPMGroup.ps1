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
This Cmdlet creates a Group on the system.

.DESCRIPTION
This Cmdlet creates a Group on the system.

.PARAMETER Name
Specify the Name for Group to create.

.PARAMETER Description
Specify the Description for Group to create.

.INPUTS
None

.OUTPUTS
[Object]XpmGroup

.EXAMPLE
PS C:\> New-XPMGroup -Name lisa.simpson@delinea.app -DisplayName "Elisabeth Mary Simpson" -Email lisa.simpson@domain.mail
Outputs all Users objects existing on the system
#>
function New-XPMGroup {
	param (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Name for Group to create.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Description for Group to create.")]
		[System.String]$Description
)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//Roles/StoreRole" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Create Json payload
		$Payload = @{}
		$Payload.Name = $Name
		$Payload.Description = $Description

		$Json = $Payload | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if($WebResponseResult.Success) {
			# Get raw data
			return(Get-XPMGroup | Where-Object { $_.ID -eq $WebResponseResult.Result })
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
