function initial-setup
    echo "🚀 Starting initial setup: Installing xtools-minimal and Git..."
    # Using 'sudo xbps-install -y' directly because 'xi' is not available yet
    # as 'xtools-minimal' is being installed here.
    sudo xbps-install -y xtools-minimal git curl
    if test $status -ne 0
        echo "❌ Failed to install xtools-minimal and git. Aborting initial setup."
        return 1
    end

    echo "Changing default shell to fish..."
    set current_user (whoami)
    set current_shell (getent passwd $current_user | cut -d: -f7)

    if test "$current_shell" = "/usr/bin/fish"
        echo "Fish is already the default shell for '$current_user'. Skipping chsh."
    else
        # Using 'sudo chsh' directly
        sudo chsh -s /usr/bin/fish $current_user
        if test $status -ne 0
            echo "❌ Failed to change default shell to fish. You might need to do this manually."
        else
            echo "✅ Default shell changed to fish for '$current_user'."
            echo "Please log out and log back in for the new shell to take effect."
        end
    end

    echo "✅ Initial setup complete."
end
