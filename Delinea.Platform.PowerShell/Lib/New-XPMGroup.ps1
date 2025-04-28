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
This Cmdlet creates a Group on the system.

.DESCRIPTION
This Cmdlet creates a Group on the system.

.PARAMETER Name
Specify the Name for Group to create.

.PARAMETER Description
Specify the Description for Group to create.

.INPUTS
None

.OUTPUTS
[Object]XpmGroup

.EXAMPLE
PS C:\> New-XPMGroup -Name lisa.simpson@delinea.app -DisplayName "Elisabeth Mary Simpson" -Email lisa.simpson@domain.mail
Outputs all Users objects existing on the system
#>
function New-XPMGroup {
	param (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Name for Group to create.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Description for Group to create.")]
		[System.String]$Description
	)

	try	{	
		# Test current connection to the XPM Platform
		if ($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//Roles/StoreRole" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Create Json payload
		$Payload = @{}
		$Payload.Name = $Name
		$Payload.Description = $Description

		$Json = $Payload | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
			return(Get-XPMGroup | Where-Object { $_.ID -eq $WebResponseResult.Result })
		} else {
			# Query error
			Throw $WebResponseResult.Message
		}		
	} catch {
		Throw $_.Exception
	}
}
