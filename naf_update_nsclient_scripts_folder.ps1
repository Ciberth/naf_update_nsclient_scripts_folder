# Script name: 		naf_update_nsclient_scripts_folder.ps1
# Version: 			2.15.02.02
# Created on: 		30/04/2014
# Author: 			D'Haese Willem
# Purpose: 			Quick action Powershell script to update the NSClient++ scripts folder on a Windows host.
# On Github:		https://github.com/willemdh/naf_update_nsclient_scripts_folder
# On OutsideIT:		http://outsideit.net/naf-update-nsclient-scripts-folder
# Recent History:
#	21/10/2014 => Tests with UAC, remoting
#	22/10/2014 => Edits to output and added test-path for source and destination folder
#	23/10/2014 => Added ErrorActionPreference before test-path
#	29/01/2015 => Compatibility for 0.4.3, scripts moved to powershell folder
#	02/02/2015 => Renamed nscp to nsclient
# Copyright:
#	This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#	by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed 
#	in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
#	PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public 
#	License along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Requires –Version 2.0

param(
	[Parameter(Mandatory=$true)][string]$hostname
)

$LogLocal="c:\Nagios\NAF\NAF_Logs\Naf_Actions.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$Date : NAF_PS: NSClient scripts folder update requested on $hostname" | Out-File -filepath $LogLocal -Append

$SourceFolder = "\\localhost\C$\Nagios\NAF\NAF_Sources\Scripts\"
$DestinationFolder = "\\$hostname\c$\Program Files\NSClient++\scripts\powershell\"

$ErrorActionPreference = "SilentlyContinue"

if (!(Test-path -Path \\$hostname\c$\Nagios\NAF\NAF_Logs)) {
	New-Item -Path \\$HostName\c$\Nagios\NAF\NAF_Logs -Type directory -Force | Out-Null
	$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$Date : Nagios directory created on $hostname" | Out-File -filepath $LogLocal -Append
	"$Date : Nagios directory created on $hostname" | Out-File -filepath $LogRemote -Append
}

if (!(Test-Path -path $DestinationFolder)) {
	New-Item -Path "\\$HostName\c$\Program Files\NSClient++\scripts\powershell\" -Type directory -Force  | Out-Null
	$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$Date : Directory created on $hostname" | Out-File -filepath $LogLocal -Append
	"$Date : Directory created on $hostname" | Out-File -filepath $LogRemote -Append
	"$Date : NAF_PS: WARNING: NSClient scripts folder on $hostname did not exist and had to be created!" | Out-File -filepath $LogLocal -Append
	Write-Host "$Date : NAF_PS:			WARNING: NSClient scripts folder on $hostname did not exist and had to be created!"
}

if (!(Test-Path -path $SourceFolder)) {
	$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$Date : NAF_PS: ERROR: NSClient scripts folder update failed on $hostname because the source folder did not exist!" | Out-File -filepath $LogLocal -Append
	Write-Host "$Date : NAF_PS:			ERROR: NSClient scripts folder update failed on $hostname because the source folder did not exist!"
	$LASTEXITCODE = 1
	exit $LASTEXITCODE
}

Try
{
	$SourceFolder += "*"
	$ErrorActionPreference = "Stop"
	Copy-Item -Path $SourceFolder -Destination $DestinationFolder -force
}
Catch
{
	$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$Date : NAF_PS: ERROR: NSClient scripts folder update failed on $hostname when trying to copy the files!" | Out-File -filepath $LogLocal -Append
	Write-Host "$Date : NAF_PS:			ERROR: NSClient scripts folder update failed on $hostname when trying to copy the files!"
	$LASTEXITCODE = 1
	exit $LASTEXITCODE
}

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$Date : NAF_PS:NSClient scripts folder update succeeded on $hostname" | Out-File -filepath $LogLocal -Append
Write-Host "$Date : NAF_PS: 		NSClient scripts folder update succeeded on $hostname"
exit $LASTEXITCODE