#!/bin/bash

case $1 in

   volup) A="VOLUME: $(amixer -D pulse sset Master 5%+ unmute | grep -E ":[[:space:]]+Playback[[:space:]]+[[:digit:]]+[[:space:]]+\[[[:digit:]]{1,3}%\][[:space:]]+\[o[[:alpha:]]{1,2}\]" | tr -d '[]%' | awk '{SUM += $5} END {print SUM/NR"%"}')" ;;
   voldown) A="VOLUME: $(amixer -D pulse sset Master 5%- unmute | grep -E ":[[:space:]]+Playback[[:space:]]+[[:digit:]]+[[:space:]]+\[[[:digit:]]{1,3}%\][[:space:]]+\[o[[:alpha:]]{1,2}\]" | tr -d '[]%' | awk '{SUM += $5} END {print SUM/NR"%"}')" ;;
   mute)
      case $(amixer -D pulse sset Master toggle | grep -E ":[[:space:]]+Playback[[:space:]]+[[:digit:]]+[[:space:]]+\[[[:digit:]]{1,3}%\][[:space:]]+\[o[[:alpha:]]{1,2}\]" | tail -n 1 | awk '{print $6}' | tr -d '[]') in
            on) A="UNMUTED" ;;
            off) A="MUTED" ;;
      esac ;;

   *) echo "Usage: $0 { volup | voldown | mute }" ;;

esac

MUTESTATUS=$(amixer -D pulse get Master | grep -E ":[[:space:]]+Playback[[:space:]]+[[:digit:]]+[[:space:]]+\[[[:digit:]]{1,3}%\][[:space:]]+\[o[[:alpha:]]{1,2}\]" | tail -n 1 | awk '{print $6}' | tr -d '[]')

if [ $MUTESTATUS == "off" ]; then
   OSDCOLOR=red; else
   OSDCOLOR=yellow
fi
echo $OSDCOLOR
echo $MUTESTATUS

killall aosd_cat &> /dev/null

echo "$A" | aosd_cat --fore-color=$OSDCOLOR --font="bitstream bold 20" -p 7 --x-offset=-10 --y-offset=-30 --transparency=1 --fade-full=2500 -f 0 -o 300
