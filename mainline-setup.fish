function mainline-setup
    echo "📦 Installing latest mainline kernel..."
    xi -yU linux-mainline

    echo "🗑 Cleaning up older kernel files in /boot..."

    # Get the *absolute latest* kernel version currently in /boot after install
    # This assumes the newly installed mainline kernel will be the highest version.
    set current_mainline_kernel_version (basename (ls -1 /boot/vmlinuz-6.* | sort -V | tail -n 1) | string replace -r '^vmlinuz-' '')

    if test -z "$current_mainline_kernel_version"
        echo "❌ No kernel found in /boot after installation. Skipping old kernel cleanup."
        return 1 # Exit the function if no kernel is found
    end

    echo "🔍 Latest kernel version detected in /boot: $current_mainline_kernel_version"

    # Find all config, initramfs, and vmlinuz files
    # Exclude files that match the exact latest mainline kernel version
    # Iterate safely by getting all files and then filtering
    set -q all_kernel_files (ls /boot/{config,initramfs,vmlinuz}-* 2>/dev/null)

    if test -n "$all_kernel_files"
        for file in $all_kernel_files
            set filename (basename $file)
            set file_kernel_version (echo "$filename" | string replace -r '^(config|initramfs|vmlinuz)-' '' | string replace -r '\.img$' '')

            # If the file's kernel version is NOT the current mainline kernel version, remove it.
            # This is an aggressive cleanup: it removes *all* kernels except the one just installed.
            if test "$file_kernel_version" != "$current_mainline_kernel_version"
                echo "🗑 Removing old kernel file: $filename"
                doas rm "$file"
            end
        end
    else
        echo "ℹ️ No kernel files found in /boot to clean up (or none matching expected patterns)."
    end

    echo "🗑 Running 'del linux'..."
    del linux -y

    echo "✅ Mainline kernel setup complete!"
end
