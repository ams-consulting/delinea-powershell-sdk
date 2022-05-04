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
PS C:\> Invoke-XPMReport -ID "user_all"
Outputs all Users objects existing on the system according to the report specified by its ID.
#>
function Invoke-XPMReport {
	param (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the report ID to invoke.")]
		[System.String]$ID,

		[Parameter(Mandatory = $false, HelpMessage = "Optionnaly specify the parameter's name to use for this report.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Optionnaly specify the parameter's value to use for this report.")]
		[System.String]$Value
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
		$Header = @{"Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Create Json payload
		$Payload = @{}
		$Payload.ID = $ID

		if(-not [System.String]::IsNullOrEmpty($Name) -and -not [System.String]::IsNullOrEmpty($Value)) {
			# Set Parameters for the report
			$Parameters = @{}
			$Parameters.Name = $Name
			$Parameters.Value = $Value
			# Add Parameters to report
			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		}

		$Json = $Payload | ConvertTo-Json -Depth 3

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
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
