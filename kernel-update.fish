function kernel-update
    doas true

    # Identify latest files in /boot
    set latest_kernel (find /boot -maxdepth 1 -type f -name "vmlinuz-*" | sort -V | tail -n 1)
    set latest_initramfs (find /boot -maxdepth 1 -type f -name "initramfs-*" | sort -V | tail -n 1)
    set latest_configname (basename (find /boot -maxdepth 1 -type f -name "config-*" | sort -V | tail -n 1))

    if test -z "$latest_kernel" -o -z "$latest_initramfs"
        echo "Could not find required files in /boot. Exiting..." >&2
        return 1
    end

    set latest_kernelname (basename $latest_kernel)
    set latest_initramfsname (basename $latest_initramfs)

    # Get root UUID
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

    # Hashes
    set kernel_hash (b2sum $latest_kernel | cut -d ' ' -f 1)
    set initramfs_hash (b2sum $latest_initramfs | cut -d ' ' -f 1)

    echo "Latest Kernel:      $latest_kernelname"
    echo "Hash:        $kernel_hash"
    echo "                                    "
    echo "Latest Initramfs:   $latest_initramfsname"
    echo "Hash:     $initramfs_hash"
    echo "                                    "
    echo "Root UUID:          $root_uuid"
    echo "                                    "
    echo "Here is the proposed configuration for Limine:"
    echo "-------------------------------------------------------"

    echo "timeout: 0
quiet: yes
remember_last_entry: no
wallpaper: boot():/Void-logo3.png

/Void Linux
protocol: linux
kernel_path: boot():/$latest_kernelname#$kernel_hash
kernel_cmdline: root=UUID=$root_uuid rw loglevel=0 console=tty2
module_path: boot():/$latest_initramfsname#$initramfs_hash" | doas tee /boot/limine.conf.new

    echo "Do you want to overwrite limine.conf with this new configuration? (y/N): "
    if confirm_action_n
        doas mv /boot/limine.conf.new /boot/limine.conf
        echo "limine.conf successfully updated."

        doas find /boot/EFI/BOOT -type f -delete
        doas cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI

        set b2sum_limine (b2sum /boot/limine.conf | cut -d ' ' -f 1)
        doas limine enroll-config /boot/EFI/BOOT/BOOTX64.EFI $b2sum_limine
        doas sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI

        echo "Do you want to remove old kernel files? (Y/n): "
        if confirm_action
            doas find /boot -maxdepth 1 -type f \( -name "vmlinuz-*" -o -name "initramfs-*.img" -o -name "config-*" \) \
                ! -name "$latest_kernelname" ! -name "$latest_initramfsname" ! -name "$latest_configname" -delete
            echo "Old kernel files have been deleted."
        end
        cd /boot && ls
    else
        echo "Operation cancelled. limine.conf was not changed."
        echo "Do you want to keep limine.conf.new? (Y/n): "
        if confirm_action
            cd /boot && ls
        else
            doas rm /boot/limine.conf.new
        end
    end
end
