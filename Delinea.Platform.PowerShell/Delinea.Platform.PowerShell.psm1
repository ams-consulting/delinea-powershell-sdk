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