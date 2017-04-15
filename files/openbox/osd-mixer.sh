#!/bin/bash
set -x
function updown {
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

function status {
  if echo $OUTPUT | grep -q off; then
    MESSAGE="STATUS: MUTTED"
  else
    MESSAGE="STATUS: UNMUTTED"
  fi
}
 
case $1 in
  volup) 
    OUTPUT=$(amixer sset Master 5%+ unmute)
    updown
    ACTION="Volume up"
    ;;
  voldown)
    OUTPUT=$(amixer sset Master 5%- unmute)
    updown
    ACTION="Volume down"
    ;;
  mute)
    OUTPUT=$(amixer sset Master toggle)
    status
    ACTION="Volume change"
    ;;
  *) echo "Usage: $0 { volup | voldown | mute }" ;;

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

notify-send -t 1 -a Pulseaudio -u low "$ACTION" "$MESSAGE"
