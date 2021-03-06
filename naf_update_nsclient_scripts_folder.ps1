# Script name: 		naf_update_nsclient_scripts_folder.ps1
# Version: 			v2.4.12
# Created on: 		30/04/2014
# Author: 			D'Haese Willem
# Purpose: 			Quick action Powershell script to update the NSClient++ scripts folder on a Windows host.
# On Github:		https://github.com/willemdh/naf_update_nsclient_scripts_folder
# On OutsideIT:		http://outsideit.net/naf-update-nsclient-scripts-folder
# Recent History:
#	25/02/2015 => Better error handling and integration in Reactor
#	02/03/2015 => Added Test-FileLock check
#	03/03/2015 => Added writelog function
#   25/03/2015 => Cleanup script following ISESteroids recommendations
#	12/04/2015 => Further cleanup and added duration, first release
# Copyright:
#	This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#	by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed 
#	in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
#	PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public 
#	License along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Requires –Version 2.0

param(
	[Parameter(Mandatory=$true)][string]$Hostname,
	$Method='Regeneration'
)

$StartTime = (Get-Date)
$LogLocal="c:\Nagios\NAF\NAF_Logs\Naf_Actions_$Hostname.log"
$ErrorActionPreference='Stop'
$SourceFolder = "\\localhost\C$\Nagios\NAF\NAF_Sources\Scripts\"
$DestinationFolder = "\\$Hostname\c$\Program Files\NSClient++\scripts\powershell\"

#region Functions

function Test-FileLock {
      param ([parameter(Mandatory=$True)][string]$Path)
  $oFile = New-Object System.IO.FileInfo $Path
  if ((Test-Path -Path $Path) -eq $False) {
    return $False
  }
  try {
      $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
      if ($oStream) {
        $oStream.Close()
      }
      $False
  }
  catch {
    return $True
  }
}

function Push-Log {
	param (
	[parameter(Mandatory=$true)][string]$Log,
	[parameter(Mandatory=$true)][string]$Message
	)
	$Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	while (Test-FileLock $Log) {Start-Sleep (Get-Random -minimum 1 -maximum 10)}
	"$Date : $Message" | Out-File -filepath $Log -Append
}

#endregion Functions

try {
	Push-Log $LogLocal "Info: Update NSClient scripts folder initiated on $Hostname." 
	$Ini = Get-Item "\\$Hostname\c$\Program Files\NSClient++\nsclient.ini" -ErrorAction SilentlyContinue
	$timespan = new-timespan -minutes 10
    $i = 0
	if ($Method -ne 'Regeneration') {
		while ((!(Test-path -Path "\\$Hostname\c$\Program Files\NSClient++\nsclient.ini") -or ($Ini.Length -ge 2048 -and ((get-date) - $Ini.LastWriteTime -gt $timespan))) -and ($i -lt 6)) {
				Start-Sleep 10
				$Ini = Get-Item "\\$Hostname\c$\Program Files\NSClient++\nsclient.ini" -ErrorAction SilentlyContinue
				$i++
		}
	}
	if (!(Test-path -Path \\$Hostname\c$\Nagios\NAF\NAF_Logs)) {
		New-Item -Path \\$HostName\c$\Nagios\NAF\NAF_Logs -Type directory -Force | Out-Null
		Push-Log $LogLocal "Info: NAF directory `"\\$HostName\c$\Nagios\NAF\NAF_Logs`" created on $Hostname." 
	}
	if (!(Test-Path -path $SourceFolder)) {
		Push-Log $LogLocal "Error: NSClient scripts folder update failed on $Hostname because the source folder was not found."
		Exit 1
	}
	if (!(Test-Path -path $DestinationFolder)) {
		New-Item -Path "\\$HostName\c$\Program Files\NSClient++\scripts\powershell" -Type directory -Force  | Out-Null
		Push-Log $LogLocal "Info: NAF Directory `"\\$HostName\c$\Program Files\NSClient++\scripts\powershell`" created on $hostname."
	}
}
catch {
	Push-Log $LogLocal "Error: Update NSClient scripts folder failed while testing prerequisites on $hostname with error `"{$_}`" in $([Math]::Round($(((Get-Date)-$StartTime).totalseconds), 2)) seconds."
	Write-Host ''
    Exit 1
}

Try {
	$SourceFolder += '*'
	Copy-Item -Path $SourceFolder -Destination $DestinationFolder -force
}
Catch {
	Push-Log $LogLocal "Error: Update NSClient scripts folder failed on $Hostname while trying to copy the scripts in $([Math]::Round($(((Get-Date)-$StartTime).totalseconds), 2)) seconds."
	Write-Host ''
	Exit 1
}

Push-Log $LogLocal "Info: Update NSClient scripts folder succeeded on $Hostname in $([Math]::Round($(((Get-Date)-$StartTime).totalseconds), 2)) seconds."
Write-Host ''
Exit 0
