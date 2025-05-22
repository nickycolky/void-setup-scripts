function flatpak-setup
    echo "📦 Installing Flatpak..."
    xi flatpak -y

    echo "🔗 Adding Flathub remote (if not already added)..."
    doas flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    echo "📥 Installing PinApp from Flathub..."
    flatpak install flathub io.github.fabrialberio.pinapp -y

    echo "✅ Flatpak setup complete."
end
