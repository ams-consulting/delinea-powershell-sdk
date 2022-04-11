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

.PARAMETER DisplayName
Specify the Display Name for User to create.

.PARAMETER Email
Specify the Email for User to create.

.PARAMETER Password
Specify the Password for User to create (if no Password is specified, a randomly generated one will be assigned instead).

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

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Display Name for User to create.")]
		[System.String]$DisplayName,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Email for User to create.")]
		[System.String]$Mail,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Password for User to create (if no Password is specified, a randomly generated one will be assigned instead).")]
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
			if($WebResponseResult.Success) {
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
		if($WebResponseResult.Success) {
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
