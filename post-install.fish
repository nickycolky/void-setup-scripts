function post-install
    echo "🚀 Starting Void Linux Post-Installation Setup..."
    echo "------------------------------------------------"
    echo ""

    # 1. Core System Configuration & Privilege Escalation
    echo "➡️ Running doas-setup (installing and configuring doas)..."
    doas-setup
    if test $status -ne 0
        echo "❌ doas-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "➡️ Running ignore-setup (configuring xbps package ignores)..."
    ignore-setup
    if test $status -ne 0
        echo "❌ ignore-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    # 2. Kernel and Bootloader Setup
    echo "➡️ Running mainline-setup (installing mainline kernel and cleaning up old ones)..."
    mainline-setup
    if test $status -ne 0
        echo "❌ mainline-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "➡️ Running initramfs-setup (installing mkinitcpio and rebuilding initramfs)..."
    initramfs-setup
    if test $status -ne 0
        echo "❌ initramfs-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "➡️ Running boot-setup (configuring Limine bootloader and EFI entries)..."
    boot-setup
    if test $status -ne 0
        echo "❌ boot-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    # 3. System Runtime Configuration
    echo "➡️ Running rc-setup (setting up rc.local and rc.shutdown scripts)..."
    rc-setup
    if test $status -ne 0
        echo "❌ rc-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "➡️ Running acpi-setup (installing screensaver and configuring ACPI handler)..."
    acpi-setup
    if test $status -ne 0
        echo "❌ acpi-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    # 4. Application/Environment Setup
    echo "➡️ Running flatpak-setup (installing Flatpak and configuring Flathub)..."
    flatpak-setup
    if test $status -ne 0
        echo "❌ flatpak-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "➡️ Running pipewire-setup (installing and configuring PipeWire)..."
    pipewire-setup
    if test $status -ne 0
        echo "❌ pipewire-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "➡️ Running fish-setup (installing Starship and configuring fish shell)..."
    fish-setup
    if test $status -ne 0
        echo "❌ fish-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "➡️ Running fastfetch-setup (configuring fastfetch for terminal display)..."
    fastfetch-setup
    if test $status -ne 0
        echo "❌ fastfetch-setup failed. Aborting further setup."
        return 1
    end
    echo ""

    echo "💡 Post-install setup is complete. Please reboot into BIOS to continue setting up Secure Boot."
    read -P "Do you want to reboot now? (y/N) " confirm_reboot

    if test (echo "$confirm_reboot" | tr '[:upper:]' '[:lower:]') = "y"
        echo "Rebooting now..."
        loginctl reboot --firmware-setup
    else
        echo "Reboot cancelled."
    end
end
