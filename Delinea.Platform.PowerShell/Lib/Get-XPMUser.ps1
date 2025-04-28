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

.EXAMPLE
PS C:\> Get-XPMUser -Name "%test%"
Return all users with Name containing "test" if exists

.EXAMPLE
PS C:\> Get-XPMUser -ID 12345678-ABCD-EFGH-IJKL-1234567890AB
Return user with ID "12345678-ABCD-EFGH-IJKL-1234567890AB" if exists
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
			# Get user by ID
			$Payload.ID = "user_byid"
			
			$Parameters = @{}
			$Parameters.Name = "userid"
			$Parameters.Value = $ID

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		} elseif (-not [System.String]::IsNullOrEmpty($Name)) {
			# Get user by name
			$Payload.ID = "user_searchbyname"
			
			$Parameters = @{}
			$Parameters.Name = "searchString"
			$Parameters.Value = $Name

			$Payload.Args = @{}
			$Payload.Args.Parameters = @($Parameters) 
		} else {
			# Get all users
			$Payload.ID = "user_all"
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
