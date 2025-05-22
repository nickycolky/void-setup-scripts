function initramfs-setup
    echo "📦 Installing mkinitcpio..."
    xi -S mkinitcpio

    echo "🔄 Reconfiguring initramfs for the latest mainline kernel..."

    # Find the latest kernel version (e.g., 6.14.6_1)
    set full_kernel_version (basename (ls -1 /boot/vmlinuz-6.* | sort -V | tail -n 1) | string replace -r '^vmlinuz-' '')

    if test -z "$full_kernel_version"
        echo "❌ No kernel found in /boot. Cannot reconfigure initramfs."
        return 1
    end

    # Extract the major.minor version (e.g., 6.14 from 6.14.6_1)
    # This uses sed to capture everything before the third dot or underscore.
    set major_minor_kernel_version (echo "$full_kernel_version" | sed -r 's/^([0-9]+\.[0-9]+)(\.[0-9]+)?(_[0-9]+)?$/\1/')

    if test -z "$major_minor_kernel_version"
        echo "❌ Could not parse major.minor kernel version from '$full_kernel_version'. Cannot reconfigure initramfs."
        return 1
    end

    echo "🔍 Detected latest kernel: $full_kernel_version (reconfiguring as: linux$major_minor_kernel_version)"

    # Reconfigure the initramfs using the truncated version
    doas xbps-reconfigure -f linux$major_minor_kernel_version

    echo "✅ Initramfs setup complete!"
end
