#!/bin/bash

# Animated screensaver script using mpv fullscreen
# Usage: screensaver.sh start|stop

VIDEO_PATH="$HOME/.config/hypr/screensaver.mp4"

case "$1" in
    start)
        # Kill any existing screensaver
        pkill -f "mpv.*screensaver" 2>/dev/null
        pkill -f "mpv.*$VIDEO_PATH" 2>/dev/null
        
        # Launch fullscreen mpv on each active monitor
        for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
            mpv --fullscreen \
                --loop-file=inf \
                --no-audio \
                --no-osc \
                --cursor-autohide=1 \
                --fs-screen-name="$monitor" \
                --panscan=1.0 \
                --input-conf=<(echo "MOUSE_BTN0 quit"; echo "ANY_UNICODE quit") \
                "$VIDEO_PATH" &
        done
        ;;
    stop)
        pkill -f "mpv.*screensaver" 2>/dev/null
        pkill -f "mpv.*$VIDEO_PATH" 2>/dev/null
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac