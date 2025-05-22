function rc-setup
    echo "📝 Setting up /etc/rc.local..."
    # Ensure /etc/rc.local is executable after creation
    doas sh -c "cat > '/etc/rc.local' <<'EOF'
#!/bin/sh
number=\$(cat /etc/end)
echo \"\$number\" > /sys/class/backlight/intel_backlight/brightness
rfkill block bluetooth
EOF
" > /dev/null
    doas chmod +x /etc/rc.local
    echo "✅ /etc/rc.local setup complete."

    echo "📝 Setting up /etc/rc.shutdown..."
    # Ensure /etc/rc.shutdown is executable after creation
    doas sh -c "cat > '/etc/rc.shutdown' <<'EOF'
#!/bin/sh
cat /sys/class/backlight/intel_backlight/brightness > /etc/end
EOF
" > /dev/null
    doas chmod +x /etc/rc.shutdown
    echo "✅ /etc/rc.shutdown setup complete."

    echo "📝 Creating /etc/end for brightness persistence..."
    # Create the /etc/end file, empty or with a space. Empty is usually fine.
    echo "" | doas tee /etc/end > /dev/null
    # Alternatively, to ensure it contains a space:
    # echo " " | doas tee /etc/end > /dev/null
    echo "✅ /etc/end created."
end
