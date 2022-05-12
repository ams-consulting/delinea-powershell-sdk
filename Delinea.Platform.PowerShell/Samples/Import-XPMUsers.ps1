###############################################################################################################
# Import Users from CSV
#
# DISCLAIMER   : Sample script using the Delinea.Platform.PowerShell Module to demonstrate how to add Users into XPM Platform and add them to Groups when specified. 
###############################################################################################################

param (
	[Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the CSV file to perform import actions.")]
	[System.String]$File
)

# Add PowerShell Module to session if not already loaded
[System.String]$ModuleName = "Delinea.Platform.PowerShell"
# Load PowerShell Module if not already loaded
if (@(Get-Module | Where-Object {$_.Name -eq $ModuleName}).count -eq 0) {
	Write-Verbose ("Loading {0} module..." -f $ModuleName)
	Import-Module $ModuleName
	if (@(Get-Module | Where-Object {$_.Name -eq $ModuleName}).count -ne 0) {
		Write-Verbose ("{0} module loaded." -f $ModuleName)
	}
	else {
		Throw "Unable to load PowerShell module."
	}
}

# Connect to Centrify PAS instance using Oauth
$Url = "tenant.identity.delinea.app" # your tenant url
$Username = "" # User with permissions to create Users and Groups on Platform 

if ($PlatformConnection -eq [Void]$Null) {
    # Connect to Centrify Platform
    Connect-XPMPlatform -Url $Url -User $Username
    if ($PlatformConnection -eq [Void]$Null) {
        Throw "Unable to establish connection."
    }
}

# Read CSV file
if (Test-Path -Path $File) {
    # Load data
    $Data = Import-Csv -Path $File
    if ($Data -ne [Void]$null) {
        Write-Host ("CSV file '{0}' loaded." -f $File)
        # Proceed list of users
        foreach ($Entry in $Data) {
            # Verify if user already exist
            $XPMUser = Get-XPMUser -Name $Entry.Name
            if ($XPMUser -eq [Void]$null) {
                # Create user
                $XPMUser = New-XPMUser -Name $Entry.Name -DisplayName $Entry.DisplayName -Mail $Entry.Mail
                Write-Host ("User '{0}' has been created." -f $XPMUser.Username)
            } else {
                Write-Host ("User '{0}' already exists." -f $Entry.Name)
            }
            
            # Verify if user should be added to group
            if (-not [System.String]::IsNullOrEmpty($Entry.Groups)) {
                # Each group name is comma separated
                $Entry.Groups.Split(',') | ForEach-Object {
                    # Get group if exist
                    $XPMGroup = Get-XPMGroup -Name $_
                    if ($XPMGroup -eq [Void]$null) {
                        # Create group
                        $XPMGroup = New-XPMGroup -Name $_
                        Write-Debug ("Group '{0}' has been created." -f $_)
                    }
                    # Add user to group
                    $XPMUser | Add-XPMGroupMembers -Name $_
                    Write-Debug ("User '{0}' has been added to Group '{1}'." -f $XPMUser.Name, $_)
                }
            }
        }
    }
    else {
        Throw "Unable to read CSV file."
    }
}