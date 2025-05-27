function update
    echo "✨ Starting system updates..."

    if xi -Suy
        echo "🧹 Clearing xbps cache..."
        doas xbps-remove -O
    else
        echo "✅ Everything is up to date."
    end

    echo "📦 Updating Flatpak apps..."

    # Capture Flatpak update output
    set flatpak_update_output (flatpak update 2>&1)
    if not string match -q "*Nothing to do.*" "$flatpak_update_output"
        echo "$flatpak_update_output"
    end

    # Capture Flatpak remove output
    set flatpak_remove_output (flatpak remove --unused 2>&1)
    if not string match -q "*Nothing unused to uninstall*" "$flatpak_remove_output"
        echo "$flatpak_remove_output" # Print output only if items were removed
    end

    read -P "🛡️ Do you want to update hblock list? (y/N) " -n 1 response
    echo

    if test (echo $response | tr '[:upper:]' '[:lower:]') = "y"
        echo "⚡ Updating hblock..."
        doas hblock
    end
    echo "🎉 Update completed! Your system is good to go!"
end
