function boot-setup
    echo "📁 Copying kernel files from /boot to /boot/efi (ESP)..."
    # Get the latest kernel version
    set kernel_ver (basename (ls -1 /boot/vmlinuz-6.* | sort -V | tail -n 1) | string replace -r '^vmlinuz-' '')

    if test -z "$kernel_ver"
        echo "❌ No kernel found!"
        return 1
    end

    echo "🔍 Detected kernel version: $kernel_ver"

    # Copy kernel, initramfs, and config to the EFI System Partition (ESP)
    doas cp /boot/vmlinuz-$kernel_ver /boot/efi/
    doas cp /boot/initramfs-$kernel_ver.img /boot/efi/
    doas cp /boot/config-$kernel_ver /boot/efi/

    echo "🛠️ Backing up and updating /etc/fstab: mounting ESP at /boot instead of /boot/efi..."
    # Create a backup of fstab
    doas cp /etc/fstab /etc/fstab.bak
    # Modify fstab to mount the ESP at /boot
    doas sed -i 's#/boot/efi#/boot#g' /etc/fstab

    echo "📦 Installing Limine..."
    # Install Limine bootloader using xi package manager
    xi -Sy limine

    # Create the necessary EFI boot directory structure on the ESP
    doas mkdir -p /boot/efi/EFI/BOOT
    # Copy the Limine EFI executable to the standard boot path on the ESP
    doas cp BOOTX64.EFI /boot/efi/EFI/BOOT/

    # Verify the loader file exists in the target location on the ESP
    set -l final_loader_path "/boot/efi/EFI/BOOT/BOOTX64.EFI"
    if not test -f "$final_loader_path"
        echo "❌ EFI boot loader not found at $final_loader_path. Copy operation failed."
        return 1
    end

    echo "✏️ Writing /boot/efi/limine.conf..."
    # Get the root device (e.g., /dev/sda1, /dev/nvme0n1p1)
    set root_device (findmnt -n -o SOURCE /)
    if test -z "$root_device"
        echo "Failed to detect root device." >&2
        return 1
    end

    # Get the UUID of the root device
    set root_uuid (blkid -s UUID -o value $root_device)
    if test -z "$root_uuid"
        echo "Failed to detect UUID of root device ($root_device)." >&2
        return 1
    end

    # --- START OF FIX FOR VARIABLE SUBSTITUTION IN limine.conf ---
    # Construct the Limine configuration content with Fish variables expanded
    set -l limine_conf_content "timeout: 5
quiet: no
remember_last_entry: no

/Void Linux
protocol: linux
kernel_path: boot():/vmlinuz-$kernel_ver
kernel_cmdline: root=UUID=$root_uuid rw loglevel=0 console=tty2
module_path: boot():/initramfs-$kernel_ver.img"

    # Write the Limine configuration file to the ESP using doas tee
    # 'tee' is used with 'doas' for writing to a file that requires root permissions
    echo "$limine_conf_content" | doas tee '/boot/efi/limine.conf' > /dev/null
    # --- END OF FIX ---

    echo "⚙️ Creating EFI boot entry with efibootmgr..."
    set -l esp_mountpoint "/boot/efi"

    # Find the device of the currently mounted ESP
    set -l esp_device (findmnt -no SOURCE -M "$esp_mountpoint")

    if test -z "$esp_device"
        echo "❌ Could not find the EFI System Partition mounted at $esp_mountpoint."
        return 1
    end

    # Extract disk and partition number using sed for broader compatibility
    # For /dev/nvme0n1p1, esp_disk will be /dev/nvme0n1
    # For /dev/sda1, esp_disk will be /dev/sda
    set -l esp_disk (echo "$esp_device" | sed -E 's/(p?[0-9]+)$//')
    # For /dev/nvme0n1p1, esp_part_num will be 1
    # For /dev/sda1, esp_part_num will be 1
    set -l esp_part_num (echo "$esp_device" | sed -E 's/^.*(p?[0-9]+)$/\1/' | sed -E 's/p//')

    if test -z "$esp_disk" -o -z "$esp_part_num"
        echo "❌ Failed to parse disk and partition number from $esp_device."
        return 1
    end

    echo "🔍 Using EFI System Partition: $esp_device (Disk: $esp_disk, Partition: $esp_part_num)"

    # Create the EFI boot entry using efibootmgr
    doas efibootmgr --create --disk "$esp_disk" --part "$esp_part_num" --loader '\\EFI\\BOOT\\BOOTX64.EFI' --label 'Limine' --unicode

    echo "✅ Boot setup complete!"
end
