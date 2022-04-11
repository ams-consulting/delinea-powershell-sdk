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
This Cmdlet creates a Cloud Directory User on the system.

.DESCRIPTION
This Cmdlet creates a Cloud Directory User on the system. Can specify the user password on creation or use a securely generated password returned at creation.

.PARAMETER Username
Specify the User by its Username.

.INPUTS
None

.OUTPUTS
[Object]XpmUser

.EXAMPLE
PS C:\> New-XPMUser 
Outputs all Users objects existing on the system

.EXAMPLE
PS C:\> New-XPMUser -Username "john.doe@domain.name"
Return user with username john.doe@domain.name if existing
#>
function New-XPMUser {
	param (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the User by its Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the User by its Name.")]
		[System.String]$DisplayName,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the User by its Name.")]
		[System.String]$Mail,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the User by its Name.")]
		[System.String]$Password,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the User by its Name.")]
		[Switch]$GeneratePassword
)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//CDirectoryService/CreateUser" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "true"; "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Create Json payload
		$JsonPayload = @{}
		$JsonPayload.Name = $Name
		$JsonPayload.DisplayName = $DisplayName
		$JsonPayload.Password = $Password
		$JsonPayload.confirmPassword = $Password

		$Json = $JsonPayload | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
			return $WebResponseResult.Result
		}
		else {
			# Query error
			Throw $WebResponseResult.Message
		}		
<#
		# Set RedrockQuery
		$Query = "SELECT * FROM `"user`""

		# Set Arguments
		if(-not [System.String]::IsNullOrEmpty($Username)) {
			# Add Arguments to Statement
			$Query = ("{0} WHERE username='{1}'" -f $Query, $Username)
		}

		# Build Uri value from PlatformConnection variable
		$Uri = ("https://{0}/api//RedRock/Query" -f $PlatformConnection.PodFqdn)

		# Create RedrockQuery
		$RedrockQuery = @{}
		$RedrockQuery.Uri = $Uri
		$RedrockQuery.ContentType = "application/json"
		$RedrockQuery.Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "true"; "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Build the JsonQuery string and add it to the RedrockQuery
		$JsonQuery = @{}
		$JsonQuery.Script = $Query

		$RedrockQuery.Json = $JsonQuery | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
			return $WebResponseResult.Result.Results.Row
		}
		else {
			# Query error
			Throw $WebResponseResult.Message
		}
#>
	}
	catch {
		Throw $_.Exception
	}
}
