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
This Cmdlet retrieves important information about User(s) on the system.

.DESCRIPTION
This Cmdlet retrieves important information about User(s) on the system. Can return a single user by specifying the Username.

.PARAMETER Username
Specify the User by its Username.

.INPUTS
None

.OUTPUTS
[Object]XpmUser

.EXAMPLE
PS C:\> Get-XPMUser 
Outputs all Users objects existing on the system

.EXAMPLE
PS C:\> Get-XPMUser -Username "john.doe@domain.name"
Return user with username john.doe@domain.name if existing
#>
function Get-XPMUser {
	param (
		[Parameter(Mandatory = $false, HelpMessage = "Specify the User by its Username.")]
		[System.String]$Username,

		[Parameter(Mandatory = $false, HelpMessage = "Show details.")]
		[Switch]$Detailed
	)
	
	try	{	
		# Test current connection to the XPM Platform
		Delinea.Platform.PowerShell.Core.TestPlatformConnection

		# Set RedrockQuery
		$Query = "SELECT * FROM user"
		
		# Set Arguments
		if (-not [System.String]::IsNullOrEmpty($Username)) {
			# Add Arguments to Statement
			$Query = ("{0} WHERE username='{1}'" -f $Query, $Username)
		}

		# Build Uri value from PlatformConnection variable
		$Uri = ("https://{0}/api//RedRock/Query" -f $PlatformConnection.PodFqdn)
		
		# Create RedrockQuery
		$RedrockQuery = @{}
		$RedrockQuery.Uri			= $Uri
		$RedrockQuery.ContentType	= "application/json"
		$RedrockQuery.Header 		= @{ "X-CENTRIFY-NATIVE-CLIENT" = "true"; "Authorization" = ("Bearer {0}" -f $PlatformConnection.OAuthTokens.access_token) }

		# Build the JsonQuery string and add it to the RedrockQuery
		$JsonQuery = @{}
		$JsonQuery.Script 	= $Query

		$RedrockQuery.Json 	= $JsonQuery | ConvertTo-Json

		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success) {
			# Get raw data
            $XpmUser = $WebResponseResult.Result.Results.Row
            
            <# Only modify results if not empty
            if ($XpmUser -ne [Void]$null -and $Detailed.IsPresent) {
                # Modify results
                $XpmUser | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.Platform.PowerShell.Core.GetUserActivity($_.ID))

                    # Add Attributes
                    $_ | Add-Member -MemberType NoteProperty -Name Attributes -Value (Centrify.Platform.PowerShell.Core.GetUserAttributes($_.ID))
                }
            }
			#>
            
            # Return results
            return $XpmUser
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
