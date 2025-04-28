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

		# Set Arguments
		if (-not [System.String]::IsNullOrEmpty($ID)) {
			# Get group by ID
			$Payload.ID = "role_byid"
			
			$Parameters = @{}
			$Parameters.Name = "roleid"
			$Parameters.Value = $ID

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		} elseif(-not [System.String]::IsNullOrEmpty($Name)) {
			# Get role by name
			$Payload.ID = "role_searchbyname"
			
			$Parameters = @{}
			$Parameters.Name = "searchString"
			$Parameters.Value = $Name

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		} else {
			# Get all users
			$Payload.ID = "all_role"
		}

		$Json = $Payload | ConvertTo-Json -Depth 3

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
			return $WebResponseResult.Result.Results.Row
		} else {
			# Query error
			Throw $WebResponseResult.Message
		}
	} catch {
		Throw $_.Exception
	}
}
