#!/bin/bash

entries="&#160;&#160;&#160;&#160;Shutdown\n&#160;&#160;&#160;&#160;Reboot\n&#160;&#160;&#160;&#160;Logout\n&#160;&#160;&#160;&#160;Suspend"

selected=$(echo -e "$entries" | wofi --width 250 --height 210 --dmenu --cache-file /dev/null --allow-markup --prompt "Power" --insensitive)

if [[ "$selected" =~ "Shutdown" ]]; then
    exec systemctl poweroff
elif [[ "$selected" =~ "Reboot" ]]; then
    exec systemctl reboot
elif [[ "$selected" =~ "Logout" ]]; then
    exec hyprctl dispatch exit
elif [[ "$selected" =~ "Suspend" ]]; then
    exec systemctl suspend
fi
