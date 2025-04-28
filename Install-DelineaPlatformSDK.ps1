###########################################################################################
# Delinea Platform PowerShell module - Delinea.Platform.PowerShell Module Installer
# 
#
# Author   : Fabrice Viguier
# Contact  : support AT ams-consulting.uk
# Release  : 21/01/2016
# Copyright: (c) 2024 AMS Consulting. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################


function Install-PSModule {
    param ([System.String]$Path)

    # Install Module by copying Module folder to destination folder
    try {
	    # Deduct source location from script invocation path
        if ($PSVersionTable.Platform -eq "Win32NT") {
			$Source = ("{0}\Delinea.Platform.PowerShell" -f (Split-Path -Parent $PSCommandPath))
		}
		elseif ($PSVersionTable.Platform -eq "Unix") {
			$Source = ("{0}/Delinea.Platform.PowerShell" -f (Split-Path -Parent $PSCommandPath))
		}
		else {
			# Unsupported platform
			Write-Error ("Unknown platform '{0}'. Aborting installation." -f $PSVersionTable.Platform)
			Exit 1
		}
        
        # Copy source to module location
        $FileCopied = Copy-Item -Path $Source -Destination $Path -Recurse -Force -PassThru -ErrorAction "SilentlyContinue"
        if ($FileCopied.Count -gt 0) {
	        Write-Host
	        Write-Host ("{0} files copied." -f $FileCopied.Count)
	        Write-Host
        }
        else {
            Write-Error ("No files copied.")
        }

		# Unblock files to avoid preventing importing the module
        Get-ChildItem -Path $Path -Recurse | Unblock-File
    }
    catch {
		# Unhandled Exception
		Throw $_.Exception
    }
}

function Remove-PSModule {
    param ([System.String]$Path)

    # Delete Module
    Remove-Item -Path $Path -Recurse -Force
}


function Get-PSEdition {
	# Get current PowerShell edition and version
	Write-Host ("You are running PowerShell {0} edition version {1} on {2} platform." -f $PSVersionTable.PSEdition, $PSVersionTable.PSVersion, $PSVersionTable.Platform)
}

function Test-AdminRight {
	if ($PSVersionTable.Platform -eq "Win32NT") {
		# Get current user identity and principal
		$Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
		$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($Identity)
		
		# Validate that current user is a Local Administrator
		if (-not $WindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
			Write-Warning ("Installation must be run with Local Administrator privileges. User {0} does not have enough privileges." -f $Identity)
			Exit 1
		}
	}
	elseif (($PSVersionTable.Platform -eq "Unix")) {
		# Get current user identity and group

	}
	else {
		# Unsupported platform
		Write-Error ("Unknown platform '{0}'. Aborting installation." -f $PSVersionTable.Platform)
		Exit 1
	}	
}

function Get-PSModulePath {
    if ($PSVersionTable.Platform -eq "Win32NT") {
		# Get PSModulePath from Environment on Windows platform
		$PSModulePath = ([System.Environment]::GetEnvironmentVariable("PSModulePath")) -Split ';' | Where-Object { $_ -match "C:\\Program Files\\Delinea\\PowerShell\\" }
		if ([System.String]::IsNullOrEmpty($PSModulePath)) {
			Write-Host "No custom PowerShell Module path detected on this system."
			$PSModulePath = "C:\Program Files\Delinea\PowerShell\"
			# Set PSModulePath into Machine Environment
			[System.Environment]::SetEnvironmentVariable("PSModulePath", ("{0};{1}" -f [System.Environment]::GetEnvironmentVariable("PSModulePath"), $PSModulePath), "Machine")
			Write-Warning "PSModulePath environment variable has been updated. Operating System may need to be rebooted for change to be taken into account."  
		}
		else {
			Write-Host ("Custom PowerShell module path detected on this system under '{0}'" -f $PSModulePath)
		}
		# Validating path exists even when set in environment variable
		if (-not (Test-Path -Path "C:\Program Files\Delinea\")) {
			# Create full path
			mkdir "C:\Program Files\Delinea"
			mkdir "C:\Program Files\Delinea\PowerShell"
		}
		else {
			# Create PowerShell folder
			if (-not (Test-Path -Path "C:\Program Files\Delinea\PowerShell")) {
				mkdir "C:\Program Files\Delinea\PowerShell"
			}
		}
	}
	elseif (($PSVersionTable.Platform -eq "Unix")) {
		# Get PSModulePath from Environment on Windows platform
		$PSModulePath = ([System.Environment]::GetEnvironmentVariable("PSModulePath")) -Split ':' | Where-Object { $_ -match "/usr/local/share/powershell/Modules" }
		if ([System.String]::IsNullOrEmpty($PSModulePath)) {
			Write-Host "No PowerShell Module path detected on this system."
			$PSModulePath = "/usr/local/share/powershell/Modules"
			# Set PSModulePath into Machine Environment
			[System.Environment]::SetEnvironmentVariable("PSModulePath", ("{0}:{1}" -f [System.Environment]::GetEnvironmentVariable("PSModulePath"), $PSModulePath), "Machine")
			Write-Warning "PSModulePath environmnet variable has been updated. Operating System may need to be rebooted for change to be taken into account."  
		}
		else {
			Write-Host ("PowerShell module path detected on this system under '{0}'" -f $PSModulePath)
		}
		# Validating path exists even when set in environment variable
		if (-not (Test-Path -Path "/usr/local/share/powershell")) {
			# Create full path
			mkdir "/usr/local/share/powershell"
			mkdir "/usr/local/share/powershell/Modules"
		}
		else {
			# Create Modules folder
			if (-not (Test-Path -Path "/usr/local/share/powershell/Modules")) {
				mkdir "/usr/local/share/powershell/Modules"
			}
		}
	}
	else {
		# Unsupported platform
		Write-Error ("Unknown platform '{0}'. Aborting installation." -f $PSVersionTable.Platform)
		Exit 1
	}
	# Return Path
    return $PSModulePath
}

##############
# Main Logic #
##############

# Validate PSEdition and Local Admin privileges
Get-PSEdition
Test-AdminRight

# Starting installation
Write-Host
Write-Host "################################################"
Write-Host "# Delinea.Platform.PowerShell Module Installer #"
Write-Host "################################################"
Write-Host

$PSModulePath = Get-PSModulePath
if ($PSVersionTable.Platform -eq "Win32NT") {
	# Set installation path on Windows from module path variable
	$InstallationPath = ("{0}Delinea.Platform.PowerShell" -f $PSModulePath)
}
elseif (($PSVersionTable.Platform -eq "Unix")) {
	# Set installation path on Unix from module path variable
	$InstallationPath = ("{0}/Delinea.Platform.PowerShell" -f $PSModulePath)
}
else {
	# Unsupported platform
	Write-Error ("Unknown platform '{0}'. Aborting installation." -f $PSVersionTable.Platform)
	Exit 1
}	

Write-Host ("Delinea Platform PowerShell module will be using Installation path:`n`t'{0}'" -f $InstallationPath)

if (Test-Path -Path $InstallationPath) {
	# Build Menu
	$Title = "The Delinea Platform PowerShell module is already installed."
	$Message = ("Choose action to perform:`n")
	$Message += ("[R] - Repair/Upgrade Module by deleting and re-installing all files.`n")
	$Message += ("[U] - Uninstall and exit.`n")
	$Message += ("[C] - Cancel and exit.`n")
	$Choice0 = New-Object System.Management.Automation.Host.ChoiceDescription "&Repair", "Repair Module"
	$Choice1 = New-Object System.Management.Automation.Host.ChoiceDescription "&Uninstall", "Uninstall and exit"
	$Choice2 = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "Cancel and exit"
	$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Choice0, $Choice1, $Choice2)
	# Prompt for choice
	$Prompt = $Host.UI.PromptForChoice($Title, $Message, $Options, 2)
	switch ($Prompt) {
		0 {
			# Repare
			Write-Host "Repairing/Upgrading Module."
            # Remove Module
            Remove-PSModule -Path $InstallationPath
            Write-Host ("Delinea Platform PowerShell module '{0}' deleted" -f $InstallationPath)
            # Installing Module
            Install-PSModule -Path $InstallationPath
            Write-Host ("Delinea Platform PowerShell module installed under '{0}'" -f $PSModulePath)
		}
		1 {
			# Uninstall
			Write-Host "Uninstalling Module."
            # Remove Module
            Remove-PSModule -Path $InstallationPath
            Write-Host ("Delinea Platform PowerShell module '{0}' deleted" -f $InstallationPath)
            Exit
		}
		2 {
			# Exit
			Write-Host "Operation canceled.`n"
			Exit
		}
	}
}
else {
	Write-Host "Installing module."
	# Installing Module
    Install-PSModule -Path $InstallationPath
    Write-Host ("Delinea Platform PowerShell module installed under '{0}'" -f $PSModulePath)
}
# Done.