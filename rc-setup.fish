function rc-setup
    echo "🔍 Detecting backlight device..."
    set -l backlight_device ""

    # Define a list of common backlight device names, updated as per your request
    set -l common_backlight_devices "intel_backlight" "amdgpu_bl0" "acpi_video0" "thinkpad_screen"

    # Iterate through the common names and check if the 'brightness' file exists
    for dev_name in $common_backlight_devices
        if test -f "/sys/class/backlight/$dev_name/brightness"
            set backlight_device "$dev_name"
            echo "💡 Detected backlight device: $backlight_device"
            break # Found one, no need to check further
        end
    end

    # If no common device was found, try a more generic fallback using standard 'ls'
    if test -z "$backlight_device"
        set -l generic_backlight_dirs (command ls -1 /sys/class/backlight/ 2>/dev/null)
        if test -n "$generic_backlight_dirs"
            for dir_entry in $generic_backlight_dirs
                # Ensure it's a directory and contains 'brightness'
                if test -d "/sys/class/backlight/$dir_entry" && test -f "/sys/class/backlight/$dir_entry/brightness"
                    set backlight_device "$dir_entry"
                    echo "💡 Found generic backlight device: $backlight_device"
                    break
                end
            end
        end
    end

    if test -z "$backlight_device"
        echo "❌ No backlight device found under /sys/class/backlight/ with a 'brightness' file."
        echo "Brightness persistence may not work."
        set backlight_device "unknown_backlight" # Placeholder if nothing found
    end

    echo "📝 Setting up /etc/rc.local..."
    doas sh -c "cat > '/etc/rc.local' <<EOF
#!/bin/sh
number=\$(cat /etc/end)
echo \"\$number\" > /sys/class/backlight/$backlight_device/brightness
rfkill block bluetooth
EOF
" > /dev/null
    doas chmod +x /etc/rc.local
    echo "✅ /etc/rc.local setup complete."

    echo "📝 Setting up /etc/rc.shutdown..."
    doas sh -c "cat > '/etc/rc.shutdown' <<EOF
#!/bin/sh
cat /sys/class/backlight/$backlight_device/brightness > /etc/end
EOF
" > /dev/null
    doas chmod +x /etc/rc.shutdown
    echo "✅ /etc/rc.shutdown setup complete."

    echo "📝 Creating /etc/end for brightness persistence..."
    if not test -f /etc/end
        echo "0" | doas tee /etc/end > /dev/null
        echo "✅ /etc/end created and initialized to 0."
    else
        echo "✅ /etc/end already exists."
    end
end
