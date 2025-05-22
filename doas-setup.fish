function doas-setup
    xi -Sy opendoas
    echo "📝 Writing /etc/doas.conf..."

    echo 'permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel
permit nopass :plugdev as root cmd /usr/bin/smartctl
permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel' | sudo tee /etc/doas.conf > /dev/null

    echo "🔒 Setting permissions..."
    sudo chmod -c 0400 /etc/doas.conf
    sudo chown -c root:root /etc/doas.conf

    echo "✅ doas.conf configured with sudo."
end
