function pipewire-setup
    echo "📦 Installing PipeWire, WirePlumber, and SOF firmware..."
    xi -Sy pipewire wireplumber sof-firmware
    if test $status -ne 0
        echo "❌ Failed to install PipeWire packages. Aborting PipeWire setup."
        return 1
    end

    echo "📂 Creating /etc/pipewire/pipewire.conf.d directory..."
    doas mkdir -p /etc/pipewire/pipewire.conf.d
    if test $status -ne 0
        echo "❌ Failed to create /etc/pipewire/pipewire.conf.d. Aborting PipeWire setup."
        return 1
    end

    echo "🔗 Symlinking WirePlumber configuration..."
    if not test -f /usr/share/examples/wireplumber/10-wireplumber.conf
        echo "❌ Source file /usr/share/examples/wireplumber/10-wireplumber.conf not found. Skipping symlink."
    else
        doas ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
        if test $status -ne 0
            echo "❌ Failed to create symlink for WirePlumber config."
            return 1
        end
    end

    echo "🔗 Symlinking PipeWire PulseAudio compatibility configuration..."
    if not test -f /usr/share/examples/pipewire/20-pipewire-pulse.conf
        echo "❌ Source file /usr/share/examples/pipewire/20-pipewire-pulse.conf not found. Skipping symlink."
    else
        doas ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
        if test $status -ne 0
            echo "❌ Failed to create symlink for PipeWire Pulse config."
            return 1
        end
    end

    echo "🚀 Setting up PipeWire autostart via ~/.config/autostart..."
    mkdir -p ~/.config/autostart
    if test $status -ne 0
        echo "❌ Failed to create ~/.config/autostart directory. Aborting PipeWire autostart setup."
        return 1
    end

    printf '%s\n' '[Desktop Entry]
Name=PipeWire
Comment=Start PipeWire
Icon=pipewire
Exec=pipewire
Terminal=false
Type=Application
#NoDisplay=true
' | tee ~/.config/autostart/pipewire.desktop > /dev/null

    echo "✅ PipeWire setup complete."
end
