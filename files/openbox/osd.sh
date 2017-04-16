#!/bin/bash
set -x
APP="amixer"

function volupdown {
   volsum=0;
   volcount=0;
   for string in $OUTPUT; do 
     if [[ $string =~ ([[:digit:]]+)% ]]; then 
       let volsum+=${BASH_REMATCH[1]};
       let volcount+=1;
     fi   
   done
   vol=$((volsum / volcount))
   MESSAGE="LEVEL: ${vol}%" 
}

function volstatus {
  if echo $OUTPUT | grep -q off; then
    MESSAGE="STATUS: MUTTED"
  else
    MESSAGE="STATUS: UNMUTTED"
  fi
}

function backlightstatus {
  level=$(xbacklight -get | cut -d'.' -f1)
  if [[ $1 == "backlightdown" ]] && [[ ${level} -le 5 ]]; then
    exit 0
  fi
  MESSAGE="LEVEL: ${level}%"
  APP="xbacklight"
}
 
case $1 in
  volup) 
    OUTPUT=$(amixer sset Master 5%+ unmute)
    volupdown
    ACTION="Volume up"
    ;;
  voldown)
    OUTPUT=$(amixer sset Master 5%- unmute)
    volupdown
    ACTION="Volume down"
    ;;
  mute)
    OUTPUT=$(amixer sset Master toggle)
    volstatus
    ACTION="Volume change"
    ;;
  backlightup)
    backlightstatus
    xbacklight +5
    backlightstatus
    ACTION="Brightness up"
    ;;
  backlightdown)
    backlightstatus $1
    xbacklight -5
    backlightstatus
    ACTION="Brightness down"
    ;;
  *) echo "Usage: $0 { volup | voldown | mute | backlightup | backlightdown }" ;;

esac

#OUTPUT=$(amixer get Master)
#status

#if [ $MUTESTATUS == "MUTTED" ]; then
#   OSDCOLOR=red; else
#   OSDCOLOR=yellow
#fi
#echo $OSDCOLOR
#echo $MUTESTATUS

#killall aosd_cat &> /dev/null

#echo "$A" | aosd_cat --fore-color=$OSDCOLOR --font="bitstream bold 20" -p 7 --x-offset=-10 --y-offset=-30 --transparency=1 --fade-full=2500 -f 0 -o 300
notify-send -t 1 -a "$APP" -u low "$ACTION" "$MESSAGE"
