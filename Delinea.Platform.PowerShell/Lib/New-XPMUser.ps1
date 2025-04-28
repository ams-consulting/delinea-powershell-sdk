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
This Cmdlet creates a Cloud Directory User on the system.

.DESCRIPTION
This Cmdlet creates a Cloud Directory User on the system. Can specify the user password on creation or use a securely generated password returned at creation.

.PARAMETER Name
Specify the Username for User to create (this must be in <name>@<domain> format, e.g. lisa.simpson@delinea.app).

.PARAMETER DisplayName
Specify the Display Name for User to create.

.PARAMETER Email
Specify the Email for User to create.

.PARAMETER Password
Specify the Password for User to create (if no Password is specified, a randomly generated one will be assigned instead).

.INPUTS
None

.OUTPUTS
[Object]XpmUser

.EXAMPLE
PS C:\> New-XPMUser -Name lisa.simpson@delinea.app -DisplayName "Elisabeth Mary Simpson" -Email lisa.simpson@domain.mail
Outputs all Users objects existing on the system
#>
function New-XPMUser {
	param (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Username for User to create (this must be in <name>@<domain> format, e.g. lisa.simpson@delinea.app).")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Display Name for User to create.")]
		[System.String]$DisplayName,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Email for User to create.")]
		[System.String]$Mail,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Password for User to create as a SecureString (if no Password is specified, a randomly generated one will be assigned instead).")]
		[System.Security.SecureString]$Password
	)

	try	{	
		# Test current connection to the XPM Platform
		if ($Global:PlatformConnection -eq [Void]$null) {
			# Inform connection does not exists and suggest to initiate one
			Write-Warning ("No connection could be found with the Delinea XPM Platform Identity Services. Use Connect-XPMPlatform Cmdlet to create a valid connection.")
			Break
		}

		if ([System.String]::IsNullOrEmpty($Password)) {
			# If password is empty, then generate password using default policy
			$Uri = ("https://{0}/api//Core/GeneratePassword" -f $PlatformConnection.PodFqdn)
			$ContentType = "application/json"
			$Header = @{ "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

			# Create Json payload
			$Payload = @{}
			$Payload.passwordLength = 0

			$Json = $Payload | ConvertTo-Json

			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success) {
				# Get raw data
				$PlainTextPassword = $WebResponseResult.Result
			} else {
				# Query error
				Throw $WebResponseResult.Message
			}		
		} else {
			# Convert SecureString in Plain Text
			$PlainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
		}

		# Setup values for API request
		$Uri = ("https://{0}/api//CDirectoryService/CreateUser" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Create Json payload
		$Payload = @{}
		$Payload.Name = $Name
		$Payload.DisplayName = $DisplayName
		$Payload.Mail = $Mail
		$Payload.Password = $PlainTextPassword
		$Payload.confirmPassword = $PlainTextPassword

		$Json = $Payload | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
			return(Get-XPMUser | Where-Object { $_.ID -eq $WebResponseResult.Result })
		} else {
			# Query error
			Throw $WebResponseResult.Message
		}		
	} catch {
		Throw $_.Exception
	}
}
