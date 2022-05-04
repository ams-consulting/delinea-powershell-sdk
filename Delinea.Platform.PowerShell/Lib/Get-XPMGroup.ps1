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
This Cmdlet retrieves important information about Group(s) on the system.

.DESCRIPTION
This Cmdlet retrieves important information about Group(s) on the system. Can return a single group by specifying the Name.

.PARAMETER Name
Specify the Group by its Name.

.INPUTS
None

.OUTPUTS
[Object]XpmGroup

.EXAMPLE
PS C:\> Get-XPMGroup
Outputs all Groups objects existing on the system

.EXAMPLE
PS C:\> Get-XPMGroup -Name "Product Group"
Return group with Name "Product Group" if exists

.EXAMPLE
PS C:\> Get-XPMGroup -Name "TEST%"
Return all groups with Name starting with "TEST" if exists

.EXAMPLE
PS C:\> Get-XPMGroup -ID 12345678_ABCD_EFGH_IJKL_1234567890AB
Return group with ID "12345678_ABCD_EFGH_IJKL_1234567890AB" if exists
#>
function Get-XPMGroup {
	param (
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Group by its ID.")]
		[System.String]$ID,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Group by its username.")]
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
			# Get group by ID
			$Payload.ID = "role_byid"
			
			$Parameters = @{}
			$Parameters.Name = "roleid"
			$Parameters.Value = $ID

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		}
		elseif(-not [System.String]::IsNullOrEmpty($Name)) {
			# Get role by name
			$Payload.ID = "role_searchbyname"
			
			$Parameters = @{}
			$Parameters.Name = "searchString"
			$Parameters.Value = $Name

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		}
		else {
			# Get all users
			$Payload.ID = "all_role"
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
