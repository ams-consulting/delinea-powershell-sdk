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
This Cmdlet removes one or more Cloud Directory Users from the system.

.DESCRIPTION
This Cmdlet removes one or more Cloud Directory Users from the system. Can specify the users by specifying a collection of existing [Object]XpmUser (can be retrieved using Get-XpmUser or using pipeline).

.PARAMETER XpmUser
Specify the User object(s) to be removed.

.INPUTS
[Object[]]XpmUsers

.OUTPUTS

.EXAMPLE
PS C:\> Remove-XPMUser -XpmUsers (Get-XPMUser -Name "lisa.simpson@delinea.app")
Removes specified user from current Identity tenant.

.EXAMPLE
PS C:\> Get-XPMUser -Name "lisa.simpson@delinea.app" | Remove-XPMUser
Removes specified user from current Identity tenant using pipeline.

.EXAMPLE
PS C:\> Get-XPMUser | Where-Object { $_.lastInvite -ne $null -and $_.lastLogin -eq $null } | Remove-XPMUser
Removes all users that have been invited and never logged in once from current Identity tenant using pipeline.
#>
function Remove-XPMUser {
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the User object(s) to be removed.")]
		[System.Object[]]$XpmUsers
	)

	try	{	
		# Test current connection to the XPM Platform
		if ($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//UserMgmt/RemoveUsers" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json"
		$Header = @{"Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }
		
		# Build Users ID list from arguments
		$UsersIDList = @()
		foreach ($XpmUser in $XpmUsers) {
			# Test if XpmUser is valid object and has a GUID
			if ([System.String]::IsNullOrEmpty($XpmUser) -or -not [GUID]::TryParse($XpmUser.ID, $([REF][GUID]::Empty))) {
				# Add Arguments to Statement
				Throw("Cannot read GUID from parameter.")
			}
			# Add User ID to list
			$UsersIDList += $XpmUser.ID
		}

		# Create Json payload
		$Payload = @{}
		$Payload.Users = $UsersIDList

		$Json = $Payload | ConvertTo-Json
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if (-not $WebResponseResult.Success) {
			# Query error
			Throw $WebResponseResult.Message
		}
	} catch {
		Throw $_.Exception
	}
}
