#! /bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
ORANGEBROWN='\033[0;33m'
DARKGRAY='\033[1;30m'
NC='\033[0m'
BLUET='\033[1;34m'
REDT='\033[1;31m'
GREENT='\033[1;32m'
DUN='\033[1;30;4m'

ostype="$( uname -s )"
COLUMNS=$(tput cols)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

clear
cat << "EOF"
                _____           _           ____   _______   __
               |  __ \         | |         / __ \ / ____\ \ / /
               | |__) | __ ___ | |__   ___| |  | | (___  \ V /
               |  ___/ '__/ _ \| '_ \ / _ \ |  | |\___ \  > <
               | |   | | | (_) | |_) |  __/ |__| |____) |/ . \
               |_|   |_|  \___/|_.__/ \___|\____/|_____//_/ \_\

                               (Version: 1.0)

    GitHub : https://github.com/Tommrodrigues/ProbeOSX
EOF

if [[ "$@" == *"-na"* ]]; then
  analysis="0"
else
  analysis="1"
fi

wifihardwareline="$( networksetup -listallhardwareports | grep -Fn 'Wi-Fi' | cut -d: -f1 )"
interfaceline=$(($wifihardwareline + 1))
wifiinterfacename="$( networksetup -listallhardwareports | sed ''"${interfaceline}"'!d' | cut -d " " -f 2 )"

if [ ! -f $DIR/mac-vendor.txt ]; then
  printf "${REDT}[!] ${NC}ERROR: No \"mac-vendor.txt\" file found in my directory, quitting..."
  echo
  exit
fi

sudo echo

ignoreidenticalonoff="1" #Set to "0" if you want to see ALL probe requests

clear

convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d\n" $h $m $s
}

start=$SECONDS
DATE="$( date '+%d/%m/%Y %H:%M:%S' )"
echo
echo "Scan started: $DATE" | fmt -c -w $COLUMNS
echo
echo "Capturing all probe requests with \"$wifiinterfacename\"..." | fmt -c -w $COLUMNS
echo "(Stop scan with \"control\"+\"c\")" | fmt -c -w $COLUMNS
echo
echo "--------------------------------------------------------------------------------"
echo

sudo airport -z

printf "${DARKGRAY}"
printf "%-9s %-8s %-19s %-17s %-10s" "Time" "Signal" "MAC Address" "Target network" "Vendor"
printf "${NC}"


ARRAY=""
MACARRAY=""

tcpdump -l -I -i $wifiinterfacename -e -s 256 type mgt subtype probe-req 2> /dev/null | while read line; do

  if [[ "$line" == *"bad-fcs"* ]]; then
    continue
  fi

  macaddress="$( echo "$line" | sed 's/.*SA://' | sed 's/(oui.*//' | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' )"
  targetnetwork="$( echo "$line" | sed 's/.*Probe Request (//' | sed 's/).*//' )"
  signalstrength="$( echo "$line" | sed 's/ signal.*//' )"
  signalstrength=${signalstrength: -6}
  sig="$( echo "$signalstrength" | sed 's/[A-Za-z]*//g' )"
  timesent="$( echo "$line" | colrm 9 )"

  colonless="$( echo "${macaddress//:}" )"
  colonless="$( echo ${colonless//[[:blank:]]/} )"
  vendornumber="$( echo ${colonless/%??????/} )"
  vendorname="$( grep -i $vendornumber $DIR/mac-vendor.txt | cut -d '	' -f 2 )"

  if [ -z "$vendorname" ]; then
    vendorname="Unknown"
  fi

  if [ -z "$targetnetwork" ]; then
    continue
  fi

  if [ "$ignoreidenticalonoff" == "1" ]; then
      if [[ "$ARRAY" == *"$macaddress~$targetnetwork"* ]]; then
          continue
      fi
  fi

    printf "\n\n"

    if [ "$sig" -ge "-60" ]; then
      printf "%-9s ${GREEN}%-8s${NC} %-19s %-17s %-10s" "$timesent" "$signalstrength" "$macaddress" "$targetnetwork" "$vendorname"
    elif [ "$sig" -ge "-80" ]; then
      printf "%-9s ${ORANGEBROWN}%-8s${NC} %-19s %-17s %-10s" "$timesent" "$signalstrength" "$macaddress" "$targetnetwork" "$vendorname"
    else
      printf "%-9s ${RED}%-8s${NC} %-19s %-17s %-10s" "$timesent" "$signalstrength" "$macaddress" "$targetnetwork" "$vendorname"
    fi

    ARRAY+="($macaddress~$targetnetwork)"

    set -e
    function cleanup {
      DATE="$( date '+%d/%m/%Y %H:%M:%S' )"
      duration=$(( SECONDS - start ))
      echo
      echo
      echo "--------------------------------------------------------------------------------"
      echo
      echo "SCAN STOPPED" | fmt -c -w $COLUMNS

      duration="$( echo $(convertsecs $duration) )"
      echo "Time ended: $DATE ($duration)" | fmt -c -w $COLUMNS
      echo

      repeatmac="$( echo "$ARRAY" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | sort | uniq -c | grep -v "1 " | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' )"
      inividuallinearray="$( echo "$ARRAY" | sed 's/)/)\\n/g' )"
      inividuallinearray="$( echo -e "$inividuallinearray" )"
      inividuallinearray="$( echo "$inividuallinearray" | sed '/^\s*$/d' )"


      if [ "$analysis" != "1" ]; then
        exit
      fi
      echo "--------------------------------------------------------------------------------"
      echo
      printf "%-35s ${DUN}%-2s${NC}" "" "ANALYSIS"
      echo
      echo

      count="1"
      while read -r line; do
          printf "${DARKGRAY}"
          echo "$count. $line" | fmt -c -w $COLUMNS
          printf "${NC}"

          echo "$inividuallinearray" | grep "$line" | xargs -L1 | sed -n -e 's/^.*~//p' | cut -d\) -f1 | fmt -c -w $COLUMNS

          count=$(($count + 1))
      done < <(echo $repeatmac)
      echo
      echo "--------------------------------------------------------------------------------"
      echo
    }
    trap cleanup EXIT
done
