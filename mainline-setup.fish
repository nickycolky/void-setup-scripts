function mainline-setup
    echo "📦 Installing latest mainline kernel..."
    xi -yU linux-mainline

    echo "🗑 Cleaning up older kernel files in /boot..."

    set current_mainline_kernel_version (basename (command ls -1 /boot/vmlinuz-6.* 2>/dev/null | sort -V | tail -n 1) | string replace -r '^vmlinuz-' '')

    if test -z "$current_mainline_kernel_version"
        echo "❌ No kernel found in /boot after installation. Skipping old kernel cleanup."
        return 1
    end

    echo "🔍 Latest kernel version detected in /boot: $current_mainline_kernel_version"

    set all_kernel_files /boot/{config,initramfs,vmlinuz}-*

    if test (count $all_kernel_files) -gt 0
        for file in $all_kernel_files
            set filename (basename $file)
            set file_kernel_version (echo "$filename" | string replace -r '^(config|initramfs|vmlinuz)-' '' | string replace -r '\.img$' '')

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
