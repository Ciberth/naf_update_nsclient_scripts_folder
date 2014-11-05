#!/bin/bash

# Script name: 		naf_update_nscp_scripts_folder.sh
# Version: 			1.14.11.05
# Author: 			D'Haese Willem
# Created on: 		12/05/2014
# Purpose: 			Quick action bash script that will call naf_update_nscp_scripts_folder.ps1 Powershell 
#       			script through nrpe to update the NSClient++ scripts folder
# On Github:		https://github.com/willemdh/naf_update_nscp_scripts_folder
# On OutsideIT:		http://outsideit.net/naf_update_nscp_scripts_folder/
# History:
#       12/08/2014 => Updated logging and naf compatibility
#		22/08/2014 => Gateway passed as an argument
#		05/11/2014 => Updated script header
# Copyright:
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.You should have received a copy of the GNU
# General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

HOSTNAME=$1
GATEWAY=$2
LOGFILE=/var/log/naf_update_nscp_scripts_folder.log
NOW=$(date '+%Y-%m-%d -- %H:%M:%S')
echo "$NOW : Nsclient script folder update started on $HOSTNAME." >> $LOGFILE

/usr/local/nagios/libexec/check_nrpe -H $GATEWAY -t 300 -c naf_update_nscp_scripts_folder -a $HOSTNAME
EXITCODE=$?

NOW=$(date '+%Y-%m-%d -- %H:%M')

if [ $EXITCODE -eq 0 ]
then
        echo "$NOW : Nsclient scripts folder update succeeded on $HOSTNAME, with exit code $EXITCODE " >> $LOGFILE
else
        echo "$NOW : Nsclient scripts folder update failed on $HOSTNAME, with exit code $EXITCODE" >> $LOGFILE
fi

exit
