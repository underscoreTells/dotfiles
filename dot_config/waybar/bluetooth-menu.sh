#!/bin/bash

# Bluetooth Management Menu for Waybar
# Features: device categorization, scanning, connection management

# Constants
DIVIDER="─────────────────"
BACK="↩️  Back"
EXIT="Exit"
SCAN_DURATION=10

# Device type icons
ICON_AUDIO="🎧"
ICON_PHONE="📱" 
ICON_KEYBOARD="⌨️"
ICON_MOUSE="🖱️"
ICON_SPEAKER="🔊"
ICON_WATCH="⌚"
ICON_DEFAULT="📦"

# Action icons
ICON_CONNECT="🔌"
ICON_DISCONNECT="🔋"
ICON_REMOVE="❌"
ICON_INFO="📊"
ICON_POWER="⚡"
ICON_SCAN="🔍"

# Formatting
MARKUP_SPACES="&#160;&#160;"

# Helper functions
log_error() {
    notify-send "Bluetooth Error" "$1"
}

check_bluetooth_service() {
    if ! systemctl is-active --quiet bluetooth; then
        log_error "Bluetooth service is not running"
        systemctl start bluetooth || return 1
        sleep 2
    fi
    return 0
}

is_powered_on() {
    bluetoothctl show | grep -F -q "Powered: yes"
}

is_scanning() {
    bluetoothctl show | grep -F -q "Discovering: yes"
}

get_device_type_icon() {
    local name="$1"
    local name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    
    case "$name_lower" in
        *headphone*|*earbud*|*airpod*|*earphone*) echo "$ICON_AUDIO" ;;
        *speaker*|*sound*|*audio*) echo "$ICON_SPEAKER" ;;
        *phone*|*mobile*) echo "$ICON_PHONE" ;;
        *keyboard*|*keypad*) echo "$ICON_KEYBOARD" ;;
        *mouse*|*trackpad*|*pointer*) echo "$ICON_MOUSE" ;;
        *watch*|*band*) echo "$ICON_WATCH" ;;
        *) echo "$ICON_DEFAULT" ;;
    esac
}

get_battery_level() {
    local device="$1"
    local battery=$(bluetoothctl info "$device" 2>/dev/null | grep "Battery Percentage")
    
    if [ -n "$battery" ]; then
        echo "$battery" | awk '{print $3}' | sed 's/%//'
    else
        echo ""
    fi
}

is_device_connected() {
    local device="$1"
    bluetoothctl info "$device" 2>/dev/null | grep -F -q "Connected: yes"
}

is_device_paired() {
    local device="$1"
    bluetoothctl info "$device" 2>/dev/null | grep -F -q "Paired: yes"
}

safe_bluetooth_command() {
    local cmd="$@"
    local output
    local exit_code
    
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        case "$output" in
            *"Failed to connect"*|*"not available"*)
                log_error "Connection failed - device not available"
                ;;
            *"org.bluez.Error.Failed"*)
                log_error "Bluetooth operation failed"
                ;;
            *"Device not found"*)
                log_error "Device not found"
                ;;
            *"Operation already in progress"*)
                log_error "Operation already in progress"
                ;;
            *)
                log_error "Bluetooth error: $output"
                ;;
        esac
        return 1
    fi
    
    echo "$output"
    return 0
}

toggle_bluetooth_power() {
    if is_powered_on; then
        safe_bluetooth_command "bluetoothctl power off"
    else
        # Check for rfkill blocks
        if rfkill list bluetooth | grep -F -q 'blocked: yes'; then
            rfkill unblock bluetooth
        fi
        safe_bluetooth_command "bluetoothctl power on"
        sleep 2
    fi
}

toggle_scanning() {
    if is_scanning; then
        # Stop scanning
        pkill -f "bluetoothctl scan on" 2>/dev/null
        bluetoothctl scan off
    else
        # Start scanning in background with timeout
        (
            bluetoothctl scan on &
            scan_pid=$!
            sleep $SCAN_DURATION
            kill $scan_pid 2>/dev/null
            bluetoothctl scan off
        ) &
        
        notify-send "Bluetooth Scanning" "Scanning for new devices for ${SCAN_DURATION}s"
        sleep 2  # Allow scan to start
    fi
}

connect_device() {
    local device="$1"
    local device_name="$2"
    
    safe_bluetooth_command "timeout 15s bluetoothctl connect $device"
}

disconnect_device() {
    local device="$1"
    safe_bluetooth_command "bluetoothctl disconnect $device"
}

remove_device() {
    local device="$1"
    local device_name="$2"
    
    # Disconnect first if connected
    if is_device_connected "$device"; then
        bluetoothctl disconnect "$device" 2>/dev/null
    fi
    
    safe_bluetooth_command "bluetoothctl remove $device"
}

show_device_info() {
    local device="$1"
    local device_name="$2"
    
    local info=$(bluetoothctl info "$device" 2>/dev/null)
    if [ -z "$info" ]; then
        log_error "Could not get device info"
        return
    fi
    
    local formatted_info=$(echo "$info" | sed 's/^[[:space:]]*//' | sed 's/:/:/' | head -15)
    
    echo -e "Device Information\n$DIVIDER\n$formatted_info\n$DIVIDER\n$BACK" | \
        wofi --width 400 --height 500 --dmenu --cache-file /dev/null --allow-markup --prompt "$device_name"
}

build_device_list() {
    local connected_entries=""
    local paired_entries=""
    local available_entries=""
    
    # Get all devices
    while IFS= read -r line; do
        if echo "$line" | grep -q "Device "; then
            local mac=$(echo "$line" | cut -d ' ' -f 2)
            local name=$(echo "$line" | cut -d ' ' -f 3-)
            local type_icon=$(get_device_type_icon "$name")
            
            if is_device_connected "$mac"; then
                # Get battery if available
                local battery=$(get_battery_level "$mac")
                local battery_text=""
                if [ -n "$battery" ]; then
                    battery_text="${MARKUP_SPACES}${battery}%"
                fi
                connected_entries="${connected_entries}${type_icon}${MARKUP_SPACES}<b>${name}</b>${battery_text}\n"
            elif is_device_paired "$mac"; then
                paired_entries="${paired_entries}${type_icon}${MARKUP_SPACES}${name}\n"
            else
                available_entries="${available_entries}${type_icon}${MARKUP_SPACES}${name}\n"
            fi
        fi
    done < <(bluetoothctl devices 2>/dev/null)
    
    local final_list=""
    
    if [ -n "$connected_entries" ]; then
        final_list="${final_list}<b>Connected:</b>\n${connected_entries}"
    fi
    
    if [ -n "$paired_entries" ]; then
        if [ -n "$final_list" ]; then final_list="${final_list}\n"; fi
        final_list="${final_list}<b>Paired:</b>\n${paired_entries}"
    fi
    
    if [ -n "$available_entries" ]; then
        if [ -n "$final_list" ]; then final_list="${final_list}\n"; fi
        final_list="${final_list}<b>Available:</b>\n${available_entries}"
    fi
    
    echo -e "$final_list"
}

show_device_menu() {
    local mac="$1"
    local name="$2"
    
    local connected="false"
    if is_device_connected "$mac"; then
        connected="true"
    fi
    
    local options=""
    if [ "$connected" = "true" ]; then
        options="${ICON_DISCONNECT}${MARKUP_SPACES}Disconnect\n"
    else
        options="${ICON_CONNECT}${MARKUP_SPACES}Connect\n"
    fi
    
    options="${options}${ICON_INFO}${MARKUP_SPACES}Device Info\n${ICON_REMOVE}${MARKUP_SPACES}Remove Device\n$DIVIDER\n$BACK"
    
    local selected=$(echo -e "$options" | \
        wofi --width 250 --height 250 --dmenu --cache-file /dev/null --allow-markup --prompt "$name" --insensitive)
    
    case "$selected" in
        *Connect*)
            connect_device "$mac" "$name"
            ;;
        *Disconnect*)
            disconnect_device "$mac"
            ;;
        *Device\ Info*)
            show_device_info "$mac" "$name"
            ;;
        *Remove*)
            remove_device "$mac" "$name"
            ;;
        *Back*)
            show_main_menu
            return
            ;;
        *)
            return
            ;;
    esac
}

show_main_menu() {
    check_bluetooth_service || return
    
    local entries=""
    
    if is_powered_on; then
        # Build device list
        local devices=$(build_device_list)
        
        if [ -n "$devices" ]; then
            entries="${devices}"
        else
            entries="No devices found\n"
        fi
        
        entries="${entries}\n$DIVIDER\n"
        
        # Scan status
        local scan_status="Start Scan"
        if is_scanning; then
            scan_status="Stop Scan"
        fi
        
        entries="${entries}${ICON_SCAN}${MARKUP_SPACES}${scan_status}\n"
        entries="${entries}${ICON_POWER}${MARKUP_SPACES}Power: on\n"
    else
        entries="${entries}${ICON_POWER}${MARKUP_SPACES}Power: on\n"
    fi
    
    entries="${entries}$BACK"
    
    local selected=$(echo -e "$entries" | \
        wofi --width 300 --height 500 --dmenu --cache-file /dev/null --allow-markup --prompt "Bluetooth" --insensitive)
    
    # Parse selection
    if [ -z "$selected" ]; then
        return
    elif echo "$selected" | grep -qE "^<b>.*:</b>$"; then
        # Selected a header, ignore/reload
        show_main_menu
    elif echo "$selected" | grep -q "Connect\|Disconnect\|Device Info\|Remove Device"; then
        # This shouldn't happen in main menu, but just in case
        return
    elif echo "$selected" | grep -q "Start Scan\|Stop Scan"; then
        toggle_scanning
        sleep 2  # Allow scan state to update
        show_main_menu
    elif echo "$selected" | grep -q "Power:"; then
        toggle_bluetooth_power
        sleep 2
        show_main_menu
    elif echo "$selected" | grep -q "No devices found"; then
        show_main_menu
    elif echo "$selected" | grep -q "↩️  Back"; then
        return
    elif echo "$selected" | grep -q "$DIVIDER"; then
        show_main_menu
    else
        # Device selected - extract name
        # Remove markup tags first
        local clean_line=$(echo "$selected" | sed 's/<[^>]*>//g')
        
        # Extract name using the delimiter (MARKUP_SPACES)
        # The format is: ICON + DELIMITER + Name [+ DELIMITER + Battery]
        local device_name=$(echo "$clean_line" | awk -F'&#160;&#160;' '{print $2}')
        
        # Find MAC for this device name
        local device_mac=""
        while IFS= read -r dev_line; do
            if echo "$dev_line" | grep -q "Device "; then
                local mac=$(echo "$dev_line" | cut -d ' ' -f 2)
                local name=$(echo "$dev_line" | cut -d ' ' -f 3-)
                if [ "$name" = "$device_name" ]; then
                    device_mac="$mac"
                    break
                fi
            fi
        done < <(bluetoothctl devices 2>/dev/null)
        
        if [ -n "$device_mac" ]; then
            show_device_menu "$device_mac" "$device_name"
        else
            log_error "Could not find device MAC address"
            show_main_menu
        fi
    fi
}

# Main execution
show_main_menu