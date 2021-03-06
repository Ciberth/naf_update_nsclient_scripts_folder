#!/bin/bash

# Script Name: 		naf_update_nsclient_scripts_folder.sh
# Version: 			v2.4.12
# Created On: 		01/04/2014
# Author: 			Willem D'Haese
# Purpose: 			Bash script to update the NSClient scripts folder on a Windows host or on all members of a hostgroup with Windows hosts.
# On Github:		https://github.com/willemdh/naf_update_nsclient_scripts_folder
# On OutsideIT:		http://outsideit.net/naf-update-nsclient-scripts-folder
# Recent History:
#       29/01/2015 => Compatibility with 0.4.3. Moving script to powershell folder
#       02/02/2015 => Tests with Reactor, cleanup script
#       25/02/2015 => Making use of targets to replace host or hostgroup
#       26/02/2015 => Replaced backend API method by json method
#		12/04/2015 => Further cleanup, first release
# Copyright:
#       This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#       by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed
#       in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
#       PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public
#       License along with this program.  If not, see <http://www.gnu.org/licenses/>.

Gateway=$1
Target=$2
Method=$3
NagiosXiServer="<NAGIOSSERVER>"
NagReadOnlyUser="<READONLYUSER>"
NagReadOnlyPw="<READONLYPASSWORD>"
Logfile=/var/log/naf_actions.log
IsHostgroup=false
IsHost=false
OutputSuccess=0
OutputFailed=0
OutputUnknown=0

Now=$(date '+%Y-%m-%d %H:%M:%S')
echo "$Now : Update NSClient scripts folder started on target $Target." >> $Logfile

# Curl HostgrouList

HostgroupList=$(curl -s $NagReadOnlyUser:$NagReadOnlyPw@$NagiosXiServer/nagios/cgi-bin/objectjson.cgi?query=hostgrouplist)

if (echo $HostgroupList | grep "\"$Target\"" > /dev/null)
then
    IsHostgroup=true
else
    IsHostgroup=false
fi

# Curl HostList

HostList=$(curl -s $NagReadOnlyUser:$NagReadOnlyPw@$NagiosXiServer/nagios/cgi-bin/objectjson.cgi?query=hostlist)

if (echo $HostList | grep "\"$Target\"" > /dev/null)
then
    IsHost=true
else
    IsHost=false
fi

# Check Target

if [[ $IsHost == true ]] && [[ $IsHostgroup == true ]]; then
    echo "$Now : Error: Target $Target exist as a host and as a hostgroup. Exiting..."
    exit 1
elif [[ $IsHost == false ]] && [[ $IsHostgroup == false ]]; then
    echo "$Now : Error: Target $Target does not exist as a host or as a hostgroup. Exiting..."
    exit 1
elif [[ $IsHost == true ]]; then
    Now=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$Now : Update NSClient scripts folder started on host $Target." >> $Logfile
    Arg="\"$Target\" \"$Method\""
    /usr/local/nagios/libexec/check_nrpe -H $Gateway -t 120 -c naf_update_nsclient_scripts_folder -a "$Arg"
    if [ $? -eq 0 ]; then
        echo "$Now : Update NSClient scripts folder succeeded on $Target." >> $Logfile
        echo "$Now : Update NSClient scripts folder succeeded on $Target."
        exit 0
    else
        echo "$Now : Update NSClient scripts folder failed on $Target, with exitcode $?." >> $Logfile
        echo "$Now : Update NSClient scripts folder failed on $Target, with exitcode $?."
        exit 1
    fi
elif [[ $IsHostgroup == true ]]; then
    Now=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$Now : Update NSClient scripts folder started on hostgroup $Target." >> $Logfile

    HostMemberList=$(curl -s "$NagReadOnlyUser:$NagReadOnlyPw@$NagiosXiServer/nagios/cgi-bin/objectjson.cgi?query=hostgroup&hostgroup=$Target" | sed -e '1,/members/d' | sed '/]/,+100 d' | tr -d '"' | tr -d ',' | tr -d ' ')

    IFS=$'\n'
    for Hostname in $HostMemberList
    do
        Now=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$Now : Update NSClient scripts folder initiated on $Hostname." >> $Logfile
        Arg="\"$Hostname\" \"$Method\""
        /usr/local/nagios/libexec/check_nrpe -H $Gateway -t 120 -c naf_update_nsclient_scripts_folder -a "$Arg"
        case $? in
            "0")
                Now=$(date '+%Y-%m-%d %H:%M:%S')
                OutputStringSuccess="${OutputStringSuccess}$Now: $Hostname - "
                ((OutputSuccess+=1))
                echo "$Now :  Update NSClient scripts folder succeeded on $Hostname." >> $Logfile
                ;;
            "1")
                Now=$(date '+%Y-%m-%d %H:%M:%S')
                OutputStringFailed=" ${OutputStringFailed}$Now: $Hostname - "
                ((OutputFailed+=1))
                echo "$Now : Update NSClient scripts folder failed on $Hostname, with exitcode $?." >> $Logfile
                ;;
            *)
                Now=$(date '+%Y-%m-%d %H:%M:%S')
                OutputStringUnknown=" ${OutputStringUnknown}$Now: $Hostname: ($?) - "
                ((OutputUnknown+=1))
                echo "$Now : Update NSClient scripts folder failed on $Hostname with exitcode $?." >> $Logfile
                ;;
        esac
    done

    Now=$(date '+%Y-%m-%d %H:%M:%S')
    OutputTotal=$((OutputSuccess + OutputFailed + OutputUnknown))
    OutputString="$Now: $OutputSuccess / $OutputTotal HOSTS SUCCEEDED! "

    if [[ $OutputFailed -ge 1  ]]; then
        OutputString="${OutputString}FAILED: ${OutputStringFailed}, "
    fi
    if [[ $OutputUnknown -ge 1  ]]; then
        OutputString="${OutputString}UNKNOWN: ${OutputStringUnknown}, "
    fi
    echo "${OutputString}SUCCES: $OutputStringSuccess"
    if [[ $OutputFailed -ge 1  ]]; then
        exit 1
    else
        exit 0
    fi
fi
