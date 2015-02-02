#!/bin/bash

# Script name: naf_update_nsclient_scripts_folder.sh
# Version: 1.15.02.02
# Created on: 12/05/2014
# Author: Willem D'Haese
# Purpose: Reactor action that will call naf_update_nsclient_scripts_folder.ps1 Powershell script through nrpe to initiate the upadte of
#        NSClient++ scripts folder.
# On Github:            https://github.com/willemdh/naf_update_nsclient_scripts_folder
# On OutsideIT:         http://outsideit.net/naf-update-nsclient-scripts-folder
# History:
#       12/08/2014 => Updated logging and naf compatibility
#       22/10/2014 => Gateway passed as an argument
#       10/01/2015 => Compatibility with Reactor
#       29/01/2015 => Compatibility with 0.4.3. Moving script to powershell folder
#       02/02/2015 => Tests with Reactor, cleanup script
# Copyright:
#       This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#       by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed
#       in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
#       PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public
#       License along with this program.  If not, see <http://www.gnu.org/licenses/>.

Gateway=$1
Hostname=$2

Logfile=/var/log/naf_actions.log
Now=$(date '+%Y-%m-%d -- %H:%M:%S')
echo "$Now : Nsclient script folder update started on host $Hostname from gateway $Gateway" >> $Logfile

/usr/local/nagios/libexec/check_nrpe -H $Gateway -t 120 -c naf_update_nsclient_scripts_folder -a $Hostname
Exitcode=$?

Now=$(date '+%Y-%m-%d -- %H:%M:%S')

if [ $Exitcode -eq 0 ]
then
        echo "$Now : Nsclient scripts folder update succeeded on $Hostname, with exit code $Exitcode ." >> $Logfile
else
        echo "$Now : Nsclient scripts folder update failed on $Hostname, with exit code $Exitcode ." >> $Logfile
fi

exit 0