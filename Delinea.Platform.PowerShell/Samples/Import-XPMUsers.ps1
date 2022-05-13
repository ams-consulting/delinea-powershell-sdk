###############################################################################################################
# Import Users from CSV
#
# DISCLAIMER   : Sample script using the Delinea.Platform.PowerShell Module to demonstrate how to add Users into XPM Platform and add them to Groups when specified. 
###############################################################################################################

param (
	[Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the CSV file to perform import actions.")]
	[System.String]$File,

	[Parameter(Mandatory = $false, HelpMessage = "Commit import actions.")]
	[Switch]$Commit
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

        # Looking for duplicates
        $Duplicates = (Compare-Object -ReferenceObject ($Data.Name | Sort-Object | Get-Unique) -DifferenceObject $Data.Name).InputObject
        if ($Duplicates -ne [Void]$null) {
            # Print list of duplicate users
            $Duplicates | ForEach-Object {
                Write-Host ("User '{0}' is duplicate in CSV file." -f $_) -ForegroundColor Red
            }
            Write-Host "Cannot import users with same username. Fix CSV file and try again."
            Exit
        }

        # Caching list of users and groups
        Write-Host "Caching users and groups..."
        $UserCache = Get-XPMUser
        $GroupCache = @()
        Get-XPMGroup | ForEach-Object {
            # Ignore system groups
            if ($_.ID -ne "Everybody" -and $_.ID -ne "sysadmin") {
                # Get group members
                $GroupMembers = (Get-XPMGroupMembers -XpmGroup $_ | Select-Object -Property Name).Name
                # Set group details
                $Group = New-Object System.Object
                $Group | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name
                $Group | Add-Member -MemberType NoteProperty -Name Members -Value $GroupMembers
                # Add group to cache
                $GroupCache += $Group
            }
        }
        Write-Host "Caching complete."
        
        # Check if commit is enabled
        if (-not $Commit.IsPresent) {
            Write-Warning "Commit option is disabled. Actions will be preview only. Use -Commit on command line to perform actions on chosen tenant."
        }
    
        # Proceed list of users
        foreach ($Entry in $Data) {
            # Verify if user already exist
            if ($Entry.Name -notin $UserCache.Username) {
                if ($Commit.IsPresent) {
                    # Create user
                    $XPMUser = New-XPMUser -Name $Entry.Name -DisplayName $Entry.DisplayName -Mail $Entry.Mail
                    Write-Host ("User '{0}' has been created." -f $XPMUser.Username) -ForegroundColor Green
                } else {
                    # Preview user
                    Write-Host ("User '{0}' will be created." -f $Entry.Name)
                }
            } else {
                # Get user from list
                $XPMUser = $UserCache | Where-Object { $_.Username -eq $Entry.Name }
                Write-Host ("User '{0}' already exists." -f $Entry.Name)
            }
            
            # Verify if user should be added to group
            if (-not [System.String]::IsNullOrEmpty($Entry.Groups)) {
                # Each group name is comma separated
                $Entry.Groups.Split(',') | ForEach-Object {
                    # Get group if exist
                    if ($_ -notin $GroupCache.Name) {
                        if ($Commit.IsPresent) {
                            # Create group
                            $XPMGroup = New-XPMGroup -Name $_
                            # Set group details
                            $Group = New-Object System.Object
                            $Group | Add-Member -MemberType NoteProperty -Name Name -Value $XPMGroup.Name
                            $Group | Add-Member -MemberType NoteProperty -Name Members -Value @()
                            # Add group to cache
                            $GroupCache += $Group
                            Write-Host ("Group '{0}' has been created." -f $_) -ForegroundColor Green
                        } else {
                            Write-Host ("Group '{0}' will be created." -f $_)
                        }
                    }
                    # Check if user member of the group
                    if ($XPMUser.Username -notin $GroupCache.Members) {
                        if ($Commit.IsPresent) {
                            # Add user to group
                            $XPMUser | Add-XPMGroupMembers -Name $_
                            Write-Host ("User '{0}' has been added to Group '{1}'." -f $XPMUser.Username, $_) -ForegroundColor Green
                        } else {
                            Write-Host ("User '{0}' will be added to Group '{1}'." -f $XPMUser.Username, $_)
                        }
                    }
                }
            }
        }
    }
    else {
        Throw "Unable to read CSV file."
    }
}