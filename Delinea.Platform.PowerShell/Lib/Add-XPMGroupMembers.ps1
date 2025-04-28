###########################################################################################
# Delinea Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT ams-consulting.uk
# Release  : 21/02/2022
# License  : MIT License
#
# Copyright (c) 2024 AMS Consulting.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###########################################################################################

<#
.SYNOPSIS
This Cmdlet add one or more Users as member(s) of a Group.

.DESCRIPTION
This Cmdlet add one or more Users as member(s) of a Group. Can add members by specifying an existing collection of [Object]XpmUser (can be retrieved using Get-XpmUser or using pipeline).

.PARAMETER Name
Specify the Group by its Name.

.PARAMETER XpmUsers
Specify a collection of users to add as members.

.INPUTS
[Object[]]XpmUsers

.OUTPUTS

.EXAMPLE
PS C:\> Add-XPMGroupMembers -Name "Simpson Family" -XpmUsers (Get-XPMUser -Name lisa.simpson@delinea.app)
Add user Lisa Simpson to Group named "Simpson Family"

.EXAMPLE
PS C:\> Get-XPMUser | Where-Object { $_.lastInvite -ne $null -and $_.lastLogin -eq $null } | Add-XPMGroupMembers -Name "Invited Users"
Add all users that have been invited and never logged in once as members to group with Name "Invited Users" using pipeline
#>
function Add-XPMGroupMembers {
	param (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Group by its Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify a collection of users to add as members.")]
		[System.Object]$XpmUsers
	)

	try	{	
		# Test current connection to the XPM Platform
		if ($Global:PlatformConnection -eq [Void]$null) {
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
		$Payload.Script = $Query
		# Get group by name
		$Payload.ID = "role_searchbyname"
		
		$Parameters = @{}
		$Parameters.Name = "searchString"
		$Parameters.Value = $Name

		$Payload.Args = @{}
		$Payload.Args.Parameters = @($Parameters) 

		$Json = $Payload | ConvertTo-Json -Depth 3

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
			$XpmGroup = $WebResponseResult.Result.Results.Row

			# Test if XpmGroup is valid object and has a GUID
			if ([System.String]::IsNullOrEmpty($XpmGroup) -or -not [GUID]::TryParse($XpmGroup.ID.Replace("_", "-"), $([REF][GUID]::Empty))) {
				# Add Arguments to Statement
				Throw ("Cannot read GUID from parameter.")
			}			

			# Build Users ID list from arguments
			$UsersIDList = @()
			foreach ($XpmUser in $XpmUsers) {
				# Test if XpmUser is valid object and has a GUID
				if ([System.String]::IsNullOrEmpty($XpmUser) -or -not [GUID]::TryParse($XpmUser.ID, $([REF][GUID]::Empty))) {
					# Add Arguments to Statement
					Throw ("Cannot read GUID from parameter.")
				}
				# Add User ID to list
				$UsersIDList += $XpmUser.ID
			}

			# Setup values for API request
			$Uri = ("https://{0}/api//Roles/UpdateRole" -f $PlatformConnection.PodFqdn)
			$ContentType = "application/json"
			$Header = @{ "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

			# Create Json payload
			$Payload = @{}
			$Payload.Name = $XpmGroup.ID
			$Payload.Users = @{"Add" = $UsersIDList}

			$Json = $Payload | ConvertTo-Json
			
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if (-not $WebResponseResult.Success) {
				# Query error
				Throw $WebResponseResult.Message
			}
		} else {
			# Query error
			Throw $WebResponseResult.Message
		}
	} catch {
		Throw $_.Exception
	}
}
