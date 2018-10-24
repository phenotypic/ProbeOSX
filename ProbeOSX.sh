#! /bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DARKGRAY='\033[1;30m'
NC='\033[0m'
BLUET='\033[1;34m'
REDT='\033[1;31m'
GREENT='\033[1;32m'

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

                               (Version: BETA)

    GitHub : https://github.com/Tommrodrigues/ProbeOSX
EOF
wifihardwareline="$( networksetup -listallhardwareports | grep -Fn 'Wi-Fi' | cut -d: -f1 )"
interfaceline=$(($wifihardwareline + 1))
wifiinterfacename="$( networksetup -listallhardwareports | sed ''"${interfaceline}"'!d' | cut -d " " -f 2 )"

sudo echo

printf "${GREENT}[+] ${NC}"
read -p "Wi-Fi interface detected to be \"$wifiinterfacename\", is this correct? (y/n): " interfaceconfirmation

if [ "$interfaceconfirmation" == "y" ] || [ "$interfaceconfirmation" = "Y" ]
then
  printf "${BLUET}[*] ${NC}Interfece set to: ${CYAN}$wifiinterfacename${NC}"

elif [ "$interfaceconfirmation" == "n" ] || [ "$interfaceconfirmation" = "N" ]
then
printf "${BLUET}[*] ${NC}User chose to change default Wi-Fi interface."
printf "\n\n${GREENT}[+] ${NC}"
read -p "Enter the name of the interface you wish to use: " wifiinterfacename
printf "${BLUET}[*] ${NC}Custom interfece set to: ${CYAN}$wifiinterfacename${NC}"

else
printf "${REDT}[!] ${NC}ERROR: choose 'y' or 'n'"
exit
fi


printf "\n\n${GREENT}[+] ${NC}"
read -p "Detailed output including signal strengh, time and vendor? (y/n): " moredetail
if [ "$moredetail" == "y" ] || [ "$moredetail" = "Y" ]
then
  printf "${BLUET}[*] ${NC}Will output detailed response."
  detailedonoff="On"
elif [ "$moredetail" == "n" ] || [ "$moredetail" = "N" ]
then
  printf "${BLUET}[*] ${NC}Will output simple response."
  detailedonoff="Off"
  displaytable="N/A"
else
  printf "${REDT}[!] ${NC}ERROR: choose 'y' or 'n'"
  exit
fi

if [ "$detailedonoff" == "On" ]
then
  if [ ! -f $DIR/mac-vendor.txt ]; then
    printf "\n\n${GREENT}[+] ${NC}"
    read -p "Enter the full path of a lookup table: " tablelocation
    if [ ! -f $tablelocation ]; then
      printf "${REDT}[!] ${NC}ERROR: No such file!"
      exit
    else
    printf "${BLUET}[*] ${NC}Table location set to: ${CYAN}$tablelocation${NC}"
      displaytable=$tablelocation
    fi
  else
    printf "\n\n${GREENT}[+] ${NC}"
    read -p "Found a MAC vendor list in current directory, is this correct (y/n): " autolistcheck
    if [ "$autolistcheck" == "y" ] || [ "$autolistcheck" = "Y" ]
    then
      printf "${BLUET}[*] ${NC}Table location set to: ${CYAN}$DIR/mac-vendor.txt${NC}"
        displaytable="$DIR/mac-vendor.txt"
        tablelocation="$DIR/mac-vendor.txt"
      elif [ "$autolistcheck" == "n" ] || [ "$autolistcheck" = "N" ]
      then
        printf "${BLUET}[*] ${NC}User chose to change default MAC list."
        printf "\n\n${GREENT}[+] ${NC}"
        read -p "Enter the full path of a lookup table: " tablelocation
        if [ ! -f $tablelocation ]; then
          printf "${REDT}[!] ${NC}ERROR: No such file!"
          exit
        else
        printf "${BLUET}[*] ${NC}Table location set to: ${CYAN}$tablelocation${NC}"
          displaytable=$tablelocation
        fi
      else
        printf "${REDT}[!] ${NC}ERROR: choose 'y' or 'n'"
        exit
      fi
    fi
  fi

printf "\n\n${GREENT}[+] ${NC}"
read -p "Would you like to ignore repeated requests? (Recommend) (y/n): " ignoreidentical
if [ "$ignoreidentical" == "y" ] || [ "$ignoreidentical" = "Y" ]
then
  printf "${BLUET}[*] ${NC}Will ignore identical requests."
  ignoreidenticalonoff="On"
elif [ "$ignoreidentical" == "n" ] || [ "$ignoreidentical" = "N" ]
then
  printf "${BLUET}[*] ${NC}Will output all requests."
  ignoreidenticalonoff="Off"
else
  printf "${REDT}[!] ${NC}ERROR: choose 'y' or 'n'"
  exit
fi

clear


convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d\n" $h $m $s
}


set -e
function cleanup {
  DATE="$( date '+%d/%m/%Y %H:%M:%S' )"
  duration=$(( SECONDS - start ))
  echo
  echo "--------------------------------------------------------------------------------"
  echo
  echo "SCAN STOPPED" | fmt -c -w $COLUMNS

  duration="$( echo $(convertsecs $duration) )"

  echo "Time ended: $DATE ($duration)" | fmt -c -w $COLUMNS
  echo
}
trap cleanup EXIT

count=0

start=$SECONDS
DATE="$( date '+%d/%m/%Y %H:%M:%S' )"
echo
echo "Scan started: $DATE" | fmt -c -w $COLUMNS
echo
echo "Capturing all probe requests through \"$wifiinterfacename\"..." | fmt -c -w $COLUMNS
echo "(Stop scan with \"control\"+\"c\")" | fmt -c -w $COLUMNS
echo
echo "--------------------------------------------------------------------------------"
echo

if [ "$detailedonoff" == "Off" ]
then

ARRAY=()
looptime=0

sudo airport -z

sudo tcpdump -l -I -i $wifiinterfacename -e -s 256 type mgt subtype probe-req | while read line
   do
     looptime=$(($looptime + 1))
     if [ "$looptime" == "1" ]
     then
       echo
       echo "--------------------------------------------------------------------------------"
       echo
       printf "${DARKGRAY}"
     printf "%-22s %-23s" "MAC Address" "Target network"
     printf "${NC}"
   fi

     if [[ "$line" == *"bad-fcs"* ]]; then
       continue
     fi

    macaddress="$( echo "$line" | sed 's/.*SA://' | sed 's/(oui.*//' )"
    targetnetwork="$( echo "$line" | sed 's/.*Probe Request (//' | sed 's/).*//' )"

    if [ -z "$targetnetwork" ]; then
      continue
    fi

    if [ "$ignoreidenticalonoff" == "On" ]
    then
    if [[ "$ARRAY" == *"$macaddress $targetnetwork"* ]]; then
      continue
    fi
  fi

    printf "\n\n"
    printf "%-22s %-23s" "$macaddress" "$targetnetwork"
    count=$(($count + 1))
    ARRAY+="$macaddress $targetnetwork"
done
fi



if [ "$detailedonoff" == "On" ]
then

  ARRAY=()
  looptime=0

  sudo airport -z

  sudo tcpdump -l -I -i $wifiinterfacename -e -s 256 type mgt subtype probe-req | while read line
     do
       looptime=$(($looptime + 1))
       if [ "$looptime" == "1" ]
       then
         echo
         echo "--------------------------------------------------------------------------------"
         echo
         printf "${DARKGRAY}"
         printf "%-9s %-8s %-19s %-17s %-22s" "Time" "Signal" "MAC Address" "Target network" "Vendor"
       printf "${NC}"
     fi

       if [[ "$line" == *"bad-fcs"* ]]; then
         continue
       fi

       macaddress="$( echo "$line" | sed 's/.*SA://' | sed 's/(oui.*//' )"
       targetnetwork="$( echo "$line" | sed 's/.*Probe Request (//' | sed 's/).*//' )"
       signalstrength="$( echo "$line" | sed 's/ signal.*//' )"
       signalstrength=${signalstrength: -6}
       timesent="$( echo "$line" | colrm 9 )"

       colonless="$( echo "${macaddress//:}" )"
       colonless="$( echo ${colonless//[[:blank:]]/} )"
       vendornumber="$( echo ${colonless/%??????/} )"
       vendorname="$( grep -i $vendornumber $tablelocation | cut -d '	' -f 2 )"

       if [ -z "$vendorname" ]; then
         vendorname="Unknown"
       fi
      if [ -z "$targetnetwork" ]; then
        continue
      fi
      if [ "$ignoreidenticalonoff" == "On" ]
      then
      if [[ "$ARRAY" == *"$macaddress $targetnetwork"* ]]; then
        continue
      fi
    fi

      printf "\n\n"
      printf "%-9s %-8s %-19s %-17s %-22s" "$timesent" "$signalstrength" "$macaddress" "$targetnetwork" "$vendorname"
      count=$(($count + 1))
      ARRAY+="$macaddress $targetnetwork"
  done
  fi
