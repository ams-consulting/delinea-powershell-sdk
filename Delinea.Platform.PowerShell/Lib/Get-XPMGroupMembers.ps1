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
		if ($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Test if XpmGroup is valid object and has a GUID
		if ([System.String]::IsNullOrEmpty($XpmGroup) -or -not [GUID]::TryParse($XpmGroup.ID.Replace("_", "-"), $([REF][GUID]::Empty))) {
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
