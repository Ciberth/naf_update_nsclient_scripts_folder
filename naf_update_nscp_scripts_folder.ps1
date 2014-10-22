# Script name: naf_update_nscp_scripts_folder.ps1
# Version: 1.14.10.22
# Author: Willem D'Haese
# Created on: 30/04/2014
# Purpose: Quick action Powershell script to update the nsclient scripts folder
# History:
#	12/08/2014 => Integrated try, catch, finally and updates for naf compatibility
#	21/08/2014 => Updates for logging and output
#   18/10/2014 => Updates to error handling and logging
#	21/10/2014 => Tests with UAC, remoting
#	22/10/2014 => Edits to output and added test-path for source and destination folder
# Copyright:
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.You should have received a copy of the GNU
# General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

param(
	[Parameter(Mandatory=$true)][string]$hostname
)

$LogLocal="c:\Nagios\naf_update_nscp_scripts_folder.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$Date : NAF_PS: NSClient scripts folder update requested on $hostname" | Out-File -filepath $LogLocal -Append

$SourceFolder = "\\stadgent\repository\systeembeheer\Nagios\Nagios_NSCP\Scripts\*"
$DestinationFolder = "\\$hostname\c$\Program Files\NSClient++\scripts"

if (!(Test-Path -path $DestinationFolder)) {
	$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$Date : NAF_PS: ERROR: NSClient scripts folder update failed on $hostname because the destination folder did not exist!" | Out-File -filepath $LogLocal -Append
	Write-Host "$Date : NAF_PS:			ERROR: NSClient scripts folder update failed on $hostname because the destination folder did not exist!"
	$LASTEXITCODE = 1
	exit $LASTEXITCODE
}
elseif (!(Test-Path -path $SourceFolder)) {
	$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$Date : NAF_PS: ERROR: NSClient scripts folder update failed on $hostname because the source folder did not exist!" | Out-File -filepath $LogLocal -Append
	Write-Host "$Date : NAF_PS:			ERROR: NSClient scripts folder update failed on $hostname because the destination folder did not exist!"
	$LASTEXITCODE = 1
	exit $LASTEXITCODE
}

Try
{
	$ErrorActionPreference = "Stop"
	Copy-Item -Path $SourceFolder -Destination $DestinationFolder -force
}
Catch
{
	$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$Date : NAF_PS: ERROR: NSClient scripts folder update failed on $hostname" | Out-File -filepath $LogLocal -Append
	Write-Host "$Date : NAF_PS:			ERROR: NSClient scripts folder update failed on $hostname "
	$LASTEXITCODE = 1
	exit $LASTEXITCODE
}

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$Date : NAF_PS:NSClient scripts folder update succeeded on $hostname" | Out-File -filepath $LogLocal -Append
Write-Host "$Date : NAF_PS: 		NSClient scripts folder update succeeded on $hostname"
exit $LASTEXITCODE