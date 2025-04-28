###########################################################################################
# Delinea Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT ams-consulting.uk
# Release  : 21/02/2022
# Copyright: (c) 2024 AMS Consulting. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################

# Explicit Cmdlets export
$FunctionsList = @(
    # Core Cmdlets
    'Connect-XPMPlatform',
    'Disconnect-XPMPlatform',
    'Invoke-XPMReport',
    # User Management
    'Get-XPMGroup',
    'New-XPMGroup',
    'Get-XPMGroupMembers',
    'Add-XPMGroupMembers',
    'Remove-XPMGroupMembers',
    'Get-XPMUser',
    'New-XPMUser',
    'Remove-XPMUser',
    # Authentication
    'Get-XPMAuthProfile'    
)
Export-ModuleMember -Function $FunctionsList