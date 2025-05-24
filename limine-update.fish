function limine-update
    # Save current directory
    set current_dir (pwd)

        cd /usr/share/limine
        rmexcept -y BOOTX64.EFI

        doas find /boot/EFI/BOOT -type f -delete

        # Copy new bootloader
        doas cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI

        # Calculate b2sum of limine.conf
        set b2sum_limine (b2sum /boot/limine.conf | cut -d ' ' -f 1)

        # Enroll config with calculated b2sum
        doas limine enroll-config /boot/EFI/BOOT/BOOTX64.EFI $b2sum_limine

        # Sign the new bootloader
        doas sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI

        # Get updated Limine version
        set limine_version (limine --version | awk '/^Limine [0-9]+\.[0-9]+\.[0-9]+/ {print $2; exit}')

        echo "Limine bootloader updated. Return to your home directory? (Y/n)"

        if confirm_action
            cd ~
        else
            cd $current_dir
        end
    end
