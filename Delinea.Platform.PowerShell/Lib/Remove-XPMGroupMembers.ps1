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
This Cmdlet remove one or more Users as member(s) from a Group.

.DESCRIPTION
This Cmdlet remove one or more Users as member(s) from a Group. Can remove members by specifying an existing collection of [Object]XpmUser (can be retrieved using Get-XpmUser or using pipeline).

.PARAMETER Name
Specify the Group by its Name.

.PARAMETER XpmUsers
Specify a collection of users to remove from members.

.INPUTS
[Object[]]XpmUsers

.OUTPUTS

.EXAMPLE
PS C:\> Remove-XPMGroupMembers -Name "School Teachers" -XpmUsers (Get-XPMUser -Name lisa.simpson@delinea.app)
Remove user Lisa Simpson from Group named "School Teachers"

.EXAMPLE
PS C:\> Get-XPMUser | Where-Object { $_.lastInvite -ne $null -and $_.lastLogin -ne $null } | Add-XPMGroupMembers -Name "Invited Users"
Remove all users that have been invited and that have logged in once as members from group with Name "Invited Users" using pipeline
#>
function Remove-XPMGroupMembers {
	param (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Group by its Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify a collection of users to remove from members.")]
		[System.Object]$XpmUsers
	)

	try	{	
		# Test current connection to the XPM Platform
		if($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//RedRock/Query" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json"
		$Header = @{"Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Set RedrockQuery
		$Query = ("SELECT * FROM `"role`" WHERE name='{0}'" -f $Name)

		# Create Json payload
		$Payload = @{}
		$Payload.Script = $Query

		$Json = $Payload | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if($WebResponseResult.Success) {
			# Get raw data
			$XpmGroup = $WebResponseResult.Result.Results.Row

			# Test if XpmGroup is valid object and has a GUID
			if([System.String]::IsNullOrEmpty($XpmGroup) -or -not [GUID]::TryParse($XpmGroup.ID.Replace("_", "-"), $([REF][GUID]::Empty))) {
				# Add Arguments to Statement
				Throw("Cannot read GUID from parameter.")
			}			

			# Build Users ID list from arguments
			$UsersIDList = @()
			foreach($XpmUser in $XpmUsers) {
				# Test if XpmUser is valid object and has a GUID
				if([System.String]::IsNullOrEmpty($XpmUser) -or -not [GUID]::TryParse($XpmUser.ID, $([REF][GUID]::Empty))) {
					# Add Arguments to Statement
					Throw("Cannot read GUID from parameter.")
				}
				# Add User ID to list
				$UsersIDList += $XpmUser.ID
			}

			# Setup values for API request
			$Uri = ("https://{0}/api//Roles/UpdateRole" -f $PlatformConnection.PodFqdn)
			$ContentType = "application/json"
			$Header = @{"Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

			# Create Json payload
			$Payload = @{}
			$Payload.Name = $XpmGroup.ID
			$Payload.Users = @{"Delete" = $UsersIDList}

			$Json = $Payload | ConvertTo-Json
			
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if(-not $WebResponseResult.Success) {
				# Query error
				Throw $WebResponseResult.Message
			}
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
