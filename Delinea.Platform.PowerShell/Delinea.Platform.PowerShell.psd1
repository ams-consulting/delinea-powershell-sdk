###########################################################################################
# Delinea Platform PowerShell module manifest
#
# Author   : Fabrice Viguier
# Contact  : support AT ams-consulting.uk
# Release  : 21/02/2022
# Copyright: (c) 2024 AMS Consulting. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################

@{
    Author = 'Fabrice Viguier'
    CompanyName	= 'AMS Consulting'
    Copyright = 'Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.'
    Description = 'This unofficial PowerShell module is to be used with Delinea XPM Platform.'
    GUID = '325f94ca-6660-a42b-210d-2e0f39d34b9a'
    ModuleToProcess = 'Delinea.Platform.PowerShell.psm1'
    ModuleVersion = '0.4.81122'
    NestedModules = @(
        # Loading Cmdlets
        '.\Lib\Add-XPMGroupMembers.ps1',
        '.\Lib\Connect-XPMPlatform.ps1',
        '.\Lib\Disconnect-XPMPlatform.ps1',
        '.\Lib\Invoke-XPMReport.ps1',
        '.\Lib\Get-XPMAuthProfile.ps1',
        '.\Lib\Get-XPMGroup.ps1',
        '.\Lib\Get-XPMGroupMembers.ps1',
        '.\Lib\Get-XPMUser.ps1',
        '.\Lib\New-XPMGroup.ps1',
        '.\Lib\New-XPMUser.ps1',
        '.\Lib\Remove-XPMGroupMembers.ps1',
        '.\Lib\Remove-XPMUser.ps1'
        )
    PowerShellVersion = '5.0'
    RequiredAssemblies = @()
}