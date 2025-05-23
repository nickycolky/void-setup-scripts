function ignore-setup
    echo "⚙️ Setting up /etc/xbps.d/10-ignore.conf..."

    # Ensure the directory exists
    doas mkdir -p /etc/xbps.d

    # Write the content to the 10-ignore.conf file
    doas sh -c "cat > '/etc/xbps.d/10-ignore.conf' <<'EOF'
ignorepkg=font-util
ignorepkg=hicolor-icon-theme
ignorepkg=ipw2100-firmware
ignorepkg=ipw2200-firmware
ignorepkg=cryptsetup
ignorepkg=cantarell-fonts
ignorepkg=gnome-initial-setup
ignorepkg=void-artwork
ignorepkg=e2fsprogs
ignorepkg=zd1211-firmware
ignorepkg=xfsprogs
ignorepkg=yelp
ignorepkg=void-live-audio
ignorepkg=void-docs
ignorepkg=void-docs-browse
ignorepkg=tmux
ignorepkg=mobile-broadband-provider-info
ignorepkg=mkfontscale
ignorepkg=mdocml
ignorepkg=man-pages
ignorepkg=linux
ignorepkg=linux-firmware-amd
ignorepkg=linux-firmware-broadcom
ignorepkg=linux-firmware-nvidia
ignorepkg=ibus-gtk+3
ignorepkg=ibus-gtk4
ignorepkg=grub
ignorepkg=grub-i386-efi
ignorepkg=grub-x86_64-efi
ignorepkg=gnome-user-docs
ignorepkg=font-alias
ignorepkg=font-adobe-source-code-pro
ignorepkg=folks
ignorepkg=f2fs-tools
ignorepkg=evince
ignorepkg=dracut
ignorepkg=dbus-x11
ignorepkg=sudo
ignorepkg=xorg-server
ignorepkg=xorg-server-common
EOF
" > /dev/null

    echo "✅ /etc/xbps.d/10-ignore.conf setup complete."
end
