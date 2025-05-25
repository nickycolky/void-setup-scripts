function flatpak-setup
    echo "🔗 Adding Flathub remote (if not already added)..."
    doas flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    echo "📥 Installing PinApp from Flathub..."
    flatpak install io.github.fabrialberio.pinapp com.spotify.Client com.mattjakeman.ExtensionManager -y

    echo "✅ Flatpak setup complete."
end
