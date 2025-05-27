function update
    set xbps_full_output (doas xbps-install -Suy 2>&1)
    if string match -q "*Size to download:*" "$xbps_full_output"
        echo "$xbps_full_output"
        echo "🧹 Clearing xbps cache..."
        doas xbps-remove -O
    else
        echo "✅ Void packages are up to date."
    end

    set flatpak_update_output (flatpak update -y 2>&1)
    if not string match -q "*Nothing to do.*" "$flatpak_update_output"
        echo "$flatpak_update_output"
        echo "🧹 Removing unused Flatpak runtimes..." 
        flatpak remove --unused -y
    else
        echo "✅ Flatpaks are up to date."
    end

    read -P "🛡️ Do you want to update hblock list? (y/N) " -n 1 response
    echo

    if test (echo $response | tr '[:upper:]' '[:lower:]') = "y"
        echo "⚡ Updating hblock..."
        doas hblock
    end
    echo "🎉 Update complete. Your system is good to go!"
end
