function boot-setup
    echo "📁 Copying kernel files from /boot to /boot/efi (ESP)..."
    set kernel_ver (basename (ls -1 /boot/vmlinuz-6.* | sort -V | tail -n 1) | string replace -r '^vmlinuz-' '')

    if test -z "$kernel_ver"
        echo "❌ No kernel found!"
        return 1
    end

    echo "🔍 Detected kernel version: $kernel_ver"

    doas cp /boot/vmlinuz-$kernel_ver /boot/efi/
    doas cp /boot/initramfs-$kernel_ver.img /boot/efi/
    doas cp /boot/config-$kernel_ver /boot/efi/

    echo "🛠️ Backing up and updating /etc/fstab: mounting ESP at /boot instead of /boot/efi..."
    doas cp /etc/fstab /etc/fstab.bak
    doas sed -i 's#/boot/efi#/boot#g' /etc/fstab

    echo "📦 Installing Limine..."
    xi -S limine

    echo "🗑 Cleaning Limine directory except BOOTX64.EFI..."
    cd /usr/share/limine
    rmexcept BOOTX64.EFI

    doas mkdir -p /boot/efi/EFI/BOOT
    doas cp BOOTX64.EFI /boot/efi/EFI/BOOT/

    echo "✏️ Writing /boot/efi/limine.conf..."
    set UUID (blkid -s UUID -o value /)

    if test -z "$UUID"
        echo "❌ Could not get UUID for root partition!"
        return 1
    end

    doas sh -c "cat > '/boot/efi/limine.conf' <<'EOF'
timeout: 5
quiet: no
remember_last_entry: no

/Void Linux
protocol: linux
kernel_path: boot():/vmlinuz-\$kernel_ver
kernel_cmdline: root=UUID=\$UUID rw loglevel=0 console=tty2
module_path: boot():/initramfs-\$kernel_ver.img
EOF
" > /dev/null

    echo "⚙️ Creating EFI boot entry with efibootmgr..."
    doas efibootmgr --create --disk /dev/nvme0n1 --part 1 --loader '\\EFI\\BOOT\\BOOTX64.EFI' --label 'Limine' --unicode

    echo "✅ Boot setup complete!"
end
