###########################################################################################
# Delinea Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT ams-consulting.uk
# Release  : 21/02/2022
# Copyright: (c) 2024 AMS Consulting. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################

<#
.SYNOPSIS
This Cmdlet retrieves Group Member(s).

.DESCRIPTION
This Cmdlet retrieves Group Member(s). Can return members from a single group by specifying an existing [Object]XpmGroup (can be retrieved using Get-XpmGroup or using pipeline).

.PARAMETER XpmGroup
Specify the Group by its object.

.INPUTS
[Object]XpmGroup

.OUTPUTS
[Object]XpmGroupMembers

.EXAMPLE
PS C:\> Get-XPMGroupMembers -XpmGroup (Get-XPMGroup -Name "Product Group")
Return members from group with Name "Product Group" using parameter

.EXAMPLE
PS C:\> Get-XPMGroup -Name "Product Group" | Get-XPMGroupMembers
Return members from group with Name "Product Group" using pipeline
#>
function Get-XPMGroupMembers {
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the Group by its object.")]
		[System.Object]$XpmGroup
	)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Test if XpmGroup is valid object and has a GUID
		if([System.String]::IsNullOrEmpty($XpmGroup) -or -not [GUID]::TryParse($XpmGroup.ID.Replace("_", "-"), $([REF][GUID]::Empty))) {
			# Add Arguments to Statement
			Throw("Cannot read GUID from parameter.")
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//Roles/GetRoleMembers?name={1}" -f $PlatformConnection.PodFqdn, $XpmGroup.ID)
		$ContentType = "application/json"
		$Header = @{ "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $null -ContentType $ContentType -Headers $Header
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
