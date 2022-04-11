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
This Cmdlet removes a Cloud Directory User from the system.

.DESCRIPTION
This Cmdlet removes a Cloud Directory User from the system. Can specify the user by specifying an existing [Object]XpmUser or collection of [Object]XpmUser when looking to bulk remove users (can be retrieved using Get-XpmUser or using pipeline).

.PARAMETER XpmUser
Specify the User object(s) to be removed.

.INPUTS
[Object]XpmUser

.OUTPUTS

.EXAMPLE
PS C:\> Remove-XPMUser -XpmUser (Get-XPMUser -Name "lisa.simpson@delinea.app")
Removes specified user from current Identity tenant.

.EXAMPLE
PS C:\> Get-XPMUser -Name "lisa.simpson@delinea.app" | Remove-XPMUser
Removes specified user from current Identity tenant using pipeline.
#>
function Remove-XPMUser {
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the User object(s) to be removed.")]
		[System.Object[]]$XpmUser
	)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Test if XpmUser is valid object and has a GUID
		if([System.String]::IsNullOrEmpty($XpmUser) -or -not [GUID]::TryParse($XpmUser.ID.Replace("_", "-"), $([REF][GUID]::Empty))) {
			# Add Arguments to Statement
			Throw("Cannot read GUID from parameter.")
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//UserMgmt/RemoveUsers" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json"
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "true"; "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }
		
		# Build Users ID list from arguments
		$UsersIDList = @()
		foreach($User in $XpmUser) {
			$UsersIDList += $User.ID
		}

		# Create Json payload
		$Payload = @{}
		$Payload.Users = $UsersIDList

		$Json = $Payload | ConvertTo-Json
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if(-not $WebResponseResult.Success) {
			# Query error
			Throw $WebResponseResult.Message
		}
	}
	catch {
		Throw $_.Exception
	}
}
