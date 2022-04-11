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
		[System.String]$Password
)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		if([System.String]::IsNullOrEmpty($Password)) {
			# If password is empty, then generate password using default policy
			$Uri = ("https://{0}/api//Core/GeneratePassword" -f $PlatformConnection.PodFqdn)
			$ContentType = "application/json"
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "true"; "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

			# Create Json payload
			$Payload = @{}
			$Payload.passwordLength = 0

			$Json = $Payload | ConvertTo-Json

			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success) {
				# Get raw data
				$Password = $WebResponseResult.Result
			}
			else {
				# Query error
				Throw $WebResponseResult.Message
			}		
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//CDirectoryService/CreateUser" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "true"; "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Create Json payload
		$Payload = @{}
		$Payload.Name = $Name
		$Payload.DisplayName = $DisplayName
		$Payload.Mail = $Mail
		$Payload.Password = $Password
		$Payload.confirmPassword = $Password

		$Json = $Payload | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
			return(Get-XPMUser | Where-Object { $_.ID -eq $WebResponseResult.Result })
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
