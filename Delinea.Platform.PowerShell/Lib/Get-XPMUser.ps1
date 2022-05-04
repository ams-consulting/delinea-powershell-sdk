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
This Cmdlet retrieves important information about User(s) on the system.

.DESCRIPTION
This Cmdlet retrieves important information about User(s) on the system. Can return a single user by specifying the Username.

.PARAMETER Name
Specify the User by its username.

.INPUTS
None

.OUTPUTS
[Object]XpmUser

.EXAMPLE
PS C:\> Get-XPMUser 
Outputs all Users objects existing on the system

.EXAMPLE
PS C:\> Get-XPMUser -Name "john.doe@domain.name"
Return user with username john.doe@domain.name if exists
#>
function Get-XPMUser {
	param (
		[Parameter(Mandatory = $false, HelpMessage = "Specify the User by its ID.")]
		[System.String]$ID,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the User by its username.")]
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
		$Uri = ("https://{0}/api//Report/RunReport" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json"
		$Header = @{ "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Create Json payload
		$Payload = @{}

		# Set Arguments
		if(-not [System.String]::IsNullOrEmpty($ID)) {
			# Get user by ID
			$Payload.ID = "user_byid"
			
			$Parameters = @{}
			$Parameters.Name = "userid"
			$Parameters.Value = $ID

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		}
		elseif(-not [System.String]::IsNullOrEmpty($Name)) {
			# Get user by name
			$Payload.ID = "user_searchbyname"
			
			$Parameters = @{}
			$Parameters.Name = "searchString"
			$Parameters.Value = $Name

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		}
		else {
			# Get all users
			$Payload.ID = "user_all"
		}

		$Json = $Payload | ConvertTo-Json -Depth 3

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if($WebResponseResult.Success) {
			# Get raw data
			return $WebResponseResult.Result.Results.Row
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
