function sb-setup
    echo "🔒 Make sure you're in Secure Boot Setup Mode. Otherwise, reboot to BIOS"

    echo "🗑️ 0.1. Removing GRUB and associated packages..."
    doas xbps-remove dracut grub grub-i386-efi grub-x86_64-efi -y

    echo "🗑️ 0.2. Removing old GRUB EFI directories from /boot/EFI..."
    doas rm -rf /boot/EFI/void_grub

    echo "📦 1. Installing sbctl, sbsigntool, and efitools..."
    if xi -y sbctl sbsigntool efitools
        echo "✅ Packages installed successfully."
    else
        echo "❌ Failed to install required packages. Aborting setup."
        return 1
    end

    echo "🔑 2. Creating Secure Boot keys..."
    if doas sbctl create-keys
        echo "✅ Secure Boot keys created."
    else
        echo "❌ Failed to create Secure Boot keys. Aborting setup."
        return 1
    end

    echo "🔓 3. Attempting to remove immutability from EFI variable 'db' (if applicable)..."
    if doas chattr -i /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f
        echo "✅ Immutability removed from db variable."
    else
        echo "⚠️ Could not remove immutability from db variable. This might be normal or indicate an issue."
    end

    echo "🔓 4. Attempting to remove immutability from EFI variable 'KEK' (if applicable)..."
    if doas chattr -i /sys/firmware/efi/efivars/KEK-8be4df61-93ca-11d2-aa0d-00e098032b8c
        echo "✅ Immutability removed from KEK variable."
    else
        echo "⚠️ Could not remove immutability from KEK variable. This might be normal or indicate an issue."
    end

    echo "📝 5. Enrolling Secure Boot keys, including Microsoft's 3rd-party UEFI CA certificate..."
    if doas sbctl enroll-keys --microsoft
        echo "✅ Secure Boot keys enrolled."
    else
        echo "❌ Failed to enroll Secure Boot keys. Aborting setup."
        return 1
    end

    echo "✍️ 6. Signing kernel(s) with new Secure Boot keys..."
    if doas sbctl sign -s /boot/vmlinuz-*
        echo "✅ Kernel(s) signed successfully."
    else
        echo "❌ Failed to sign kernel(s). Aborting setup."
        return 1
    end

    echo "🔄 7. Running kernel-update script..."
    kernel-update
    echo "✅ kernel-update executed."

    echo "✅ 8. Verifying Secure Boot setup..."
    if doas sbctl verify
        echo "🎉 Secure Boot setup verified successfully! Your system should now boot with Secure Boot enabled."
    else
        echo "❗ Secure Boot verification failed. Please review the output above for errors."
    end

    echo "⚙️ 9. Updating /etc/default/sbsigntool-kernel-hook configuration..."
    set -l sbsigntool_hook_lines \
        "SBSIGN_EFI_KERNEL=1" \
        "" \
        "# The key and certificate to sign" \
        "EFI_KEY_FILE=/var/lib/sbctl/keys/db/db.key" \
        "EFI_CERT_FILE=/var/lib/sbctl/keys/db/db.pem" \
        "EFI_KEEP_UNSIGNED=0" \
        "# Don't uncomment this option unless you know what you're doing" \
        "# EFI_SIGN_ENGINE="

    printf "%s\n" $sbsigntool_hook_lines | doas tee /etc/default/sbsigntool-kernel-hook > /dev/null
    echo "✅ /etc/default/sbsigntool-kernel-hook updated."

    echo ""
    echo "💡 Secure Boot setup is complete. A reboot is required for changes to take full effect."
    read -P "Do you want to reboot now? (y/N) " confirm_reboot

    if test (echo "$confirm_reboot" | tr '[:upper:]' '[:lower:]') = "y"
        echo "Rebooting now..."
        doas reboot
    else
        echo "Reboot cancelled. Please remember to reboot your system soon."
    end
end
