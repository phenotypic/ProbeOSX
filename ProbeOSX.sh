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
TERMINALCOLOUR="$( defaults read -g AppleInterfaceStyle 2>/dev/null )"

if [[ "$TERMINALCOLOUR" == *"Dark"* ]]; then
  DARKGRAY='\033[1;37m'
  DUN='\033[1;37;4m'
else
  DARKGRAY='\033[1;30m'
  DUN='\033[1;30;4m'
fi

printf "${NC}"

clear
cat << "EOF"
                _____           _           ____   _______   __
               |  __ \         | |         / __ \ / ____\ \ / /
               | |__) | __ ___ | |__   ___| |  | | (___  \ V /
               |  ___/ '__/ _ \| '_ \ / _ \ |  | |\___ \  > <
               | |   | | | (_) | |_) |  __/ |__| |____) |/ . \
               |_|   |_|  \___/|_.__/ \___|\____/|_____//_/ \_\

EOF

if [[ "$@" == *"-h"* ]]; then
  echo "Help:"
  printf "   ${DARKGRAY}-h               ${NC}| Show this text\n"
  printf "   ${DARKGRAY}-v               ${NC}| Display all probe requests\n"
  printf "   ${DARKGRAY}-na              ${NC}| Do not display analysis at the end of scan\n"
  printf "   ${DARKGRAY}-i <interface>   ${NC}| Manually define a Wi-Fi interface\n"
  echo
  exit
fi

if [[ "$@" == *"-na"* ]]; then
  analysis="0"
else
  analysis="1"
fi

if [[ "$@" == *"-v"* ]]; then
  ignoreidenticalonoff="0"
else
  ignoreidenticalonoff="1"
fi

if [[ "$@" == *"-i"* ]]; then
  wifiinterfacename="$( echo "$@" | sed -n -e 's/^.*-i //p' | cut -d\  -f1 )"
else
  wifiinterfacename="$( networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}' )"
fi

if [ ! -f $DIR/mac-vendor.txt ]; then
  printf "${REDT}[!] ${NC}ERROR: No \"mac-vendor.txt\" file found in my directory, quitting..."
  echo
  exit
fi

sudo echo

clear

convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d\n" $h $m $s
}

start=$SECONDS
DATE="$( date +"%T" )"
echo
echo "Scan started: $DATE" | fmt -c -w $COLUMNS
echo "(Stop scan with \"control\"+\"c\")" | fmt -c -w $COLUMNS
echo
echo "--------------------------------------------------------------------------------"
echo

sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z

printf "${DUN}%-4s${NC} %-4s ${DUN}%-4s${NC} %-1s ${DUN}%-5s${NC} %-7s ${DUN}%-6s${NC} %-2s ${DUN}%-6s${NC}" "Time" "" "Signal" "" "MAC Address" "" "Target network" "" "Vendor"

sudo tcpdump -l -I -i $wifiinterfacename -e -s 256 type mgt subtype probe-req 2> /dev/null | while read line; do

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
      DATE="$( date +"%T" )"
      duration=$(( SECONDS - start ))
      echo
      echo
      echo "--------------------------------------------------------------------------------"
      echo

      duration="$( echo $(convertsecs $duration) )"
      echo "Scan stopped: $DATE ($duration)" | fmt -c -w $COLUMNS
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

      while read -r line; do
          echo
          printf "${DARKGRAY}"
          echo "$line" | fmt -c -w $COLUMNS
          printf "${NC}"

          echo "$inividuallinearray" | grep "$line" | sort -u | xargs -L1 | sed -n -e 's/^.*~//p' | cut -d\) -f1 | fmt -c -w $COLUMNS

      done < <(echo "$repeatmac")
      echo
      echo "--------------------------------------------------------------------------------"
      echo
    }
    trap cleanup EXIT
done
