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
This Cmdlet invoke a Redrock Query on the Platform.

.DESCRIPTION
This Cmdlet invoke a Redrock Query from command line or a file. Only Select statements are allowed through Redrock.
Results will be filtered based on permissions of the identity used to invoke the query on the platform (i.e. if you have no permissions on any secrets, a query returning all secrets will be empty regardless of secrets existing or not).

.PARAMETER Query
Specify the query to invoke.

.PARAMETER File
Specify the file that contains the query to invoke.

.INPUTS

.OUTPUTS

.EXAMPLE
PS C:\> Invoke-XPMQuery -Query "SELECT * From User"
Outputs all Users objects existing on the system according to the query.

.EXAMPLE
PS C:\> Invoke-XPMQuery -File .\get-all-users.sql
Invoke the query from file named get-all-users.sql
#>
function Invoke-XPMQuery {
	param (
		[Parameter(Mandatory = $false, HelpMessage = "Specify the query to invoke.")]
		[System.String]$Query,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the file that contains the query to invoke.")]
		[System.String]$File
	)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		if(-not [System.String]::IsNullOrEmpty($File)) {
			# Test file
			if (Test-Path -Path $File) {
				# Get RedrockQuery from file
				$Query = Get-Content -Path $File
			}
			else {
				Throw ("Cannot open file {0}" -f $File)
			}
		}
		elseif ([System.String]::IsNullOrEmpty($Query)) {
			# Get RedrockQuery from file
			Throw ("You must specify a query using file or command line argument.")
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
	}
	catch {
		Throw $_.Exception
	}
}
