function rc-setup
    echo "🔍 Detecting backlight device..."

    set -l backlight_device ""
    set -l common_backlight_devices "intel_backlight" "amdgpu_bl0" "acpi_video0" "thinkpad_screen"

    for dev_name in $common_backlight_devices
        if test -f "/sys/class/backlight/$dev_name/brightness"
            set backlight_device "$dev_name"
            echo "💡 Detected backlight device: $backlight_device"
            break
        end
    end

    if test -z "$backlight_device"
        set -l generic_backlight_dirs (command ls -1 /sys/class/backlight/ 2>/dev/null)
        if test -n "$generic_backlight_dirs"
            for dir_entry in $generic_backlight_dirs
                if test -d "/sys/class/backlight/$dir_entry" && test -f "/sys/class/backlight/$dir_entry/brightness"
                    set backlight_device "$dir_entry"
                    echo "💡 Found generic backlight device: $backlight_device"
                    break
                end
            end
        end
    end

    # --- Setup rc.local (always includes rfkill) ---
    echo "📝 Setting up /etc/rc.local..."
    set -l rc_local_lines \
        '#!/bin/sh'

    if test -n "$backlight_device"
        set rc_local_lines $rc_local_lines \
            'number=$(cat /etc/end)' \
            "echo \"\$number\" > /sys/class/backlight/$backlight_device/brightness"
    else
        echo "❌ No backlight device found under /sys/class/backlight/ with a 'brightness' file."
        echo "Brightness persistence will be skipped."
    end

    set rc_local_lines $rc_local_lines \
        'rfkill block bluetooth'

    printf "%s\n" $rc_local_lines | doas tee /etc/rc.local > /dev/null
    doas chmod +x /etc/rc.local
    echo "✅ /etc/rc.local setup complete."


    # --- Conditional setup for rc.shutdown and /etc/end ---
    if test -n "$backlight_device"
        echo "📝 Setting up /etc/rc.shutdown..."
        set -l rc_shutdown_lines \
            '#!/bin/sh' \
            "cat /sys/class/backlight/$backlight_device/brightness > /etc/end"

        printf "%s\n" $rc_shutdown_lines | doas tee /etc/rc.shutdown > /dev/null
        doas chmod +x /etc/rc.shutdown # Corrected line
        echo "✅ /etc/rc.shutdown setup complete."

        echo "📝 Creating /etc/end for brightness persistence..."
        if not test -f /etc/end
            echo "0" | doas tee /etc/end > /dev/null
            echo "✅ /etc/end created and initialized to 0."
        else
            echo "✅ /etc/end already exists."
        end
    else
        echo "ℹ️ Skipping /etc/rc.shutdown and /etc/end creation as no backlight device was found."
        # Ensure these files are not present or are cleaned up if they exist from a previous run
        if test -f /etc/rc.shutdown
            doas rm /etc/rc.shutdown
            echo "🗑️ Removed existing /etc/rc.shutdown."
        end
        if test -f /etc/end
            doas rm /etc/end
            echo "🗑️ Removed existing /etc/end."
        end
    end
end
