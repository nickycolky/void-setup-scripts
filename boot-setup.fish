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
    xi -Sy limine

    echo "🗑 Cleaning Limine directory except BOOTX64.EFI..."
    cd /usr/share/limine
    rmexcept BOOTX64.EFI

    doas mkdir -p /boot/efi/EFI/BOOT
    doas cp BOOTX64.EFI /boot/efi/EFI/BOOT/

    echo "✏️ Writing /boot/efi/limine.conf..."
    # Get UUID
    set root_device (findmnt -n -o SOURCE /)
    if test -z "$root_device"
        echo "Failed to detect root device." >&2
        return 1
    end

    set root_uuid (blkid -s UUID -o value $root_device)
    if test -z "$root_uuid"
        echo "Failed to detect UUID of root device ($root_device)." >&2
        return 1
    end

    doas sh -c "cat > '/boot/efi/limine.conf' <<'EOF'
timeout: 5
quiet: no
remember_last_entry: no

/Void Linux
protocol: linux
kernel_path: boot():/vmlinuz-\$kernel_ver
kernel_cmdline: root=UUID=\$root_uuid rw loglevel=0 console=tty2
module_path: boot():/initramfs-\$kernel_ver.img
EOF
" > /dev/null

    echo "⚙️ Creating EFI boot entry with efibootmgr..."
    set -l esp_mountpoint "/boot/efi"

    # Find the device of the currently mounted ESP
    set -l esp_device (findmnt -no SOURCE -M "$esp_mountpoint")

if test -z "$esp_device"
    echo "❌ Could not find the EFI System Partition mounted at $esp_mountpoint."
    return 1
end

# Extract disk and partition number
set -l esp_disk (echo "$esp_device" | string match -r '^(/dev/[^0-9]+[0-9]*).*' --output-group 1)
set -l esp_part_num (echo "$esp_device" | string match -r '^/dev/(?:[^0-9]+[0-9]*)([^pP]*[0-9]+)$' --output-group 1)

if test -z "$esp_disk" -o -z "$esp_part_num"
    echo "❌ Failed to parse disk and partition number from $esp_device."
    return 1
end

echo "🔍 Using EFI System Partition: $esp_device (Disk: $esp_disk, Partition: $esp_part_num)"

doas efibootmgr --create --disk "$esp_disk" --part "$esp_part_num" --loader '\\EFI\\BOOT\\BOOTX64.EFI' --label 'Limine' --unicode

    echo "✅ Boot setup complete!"
end
