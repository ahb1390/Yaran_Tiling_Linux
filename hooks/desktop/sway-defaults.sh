#!/bin/bash
set -euo pipefail

echo 'Installing Yaran Sway defaults'
install -d -m 0755 /etc/sway /etc/sway/config.d
cp -a /.temp_assets/yaran-sway/etc/sway/. /etc/sway/
cp -a /.temp_assets/yaran-sway/etc/skel/. /etc/skel/
install -d -m 0755 /usr/share/wallpapers
cp -a /.temp_assets/wallpapers/. /usr/share/wallpapers/

install -d -m 0755 /usr/share/backgrounds/yaran
install -m 0644 "/usr/share/wallpapers/Yaran Emblem/contents/images/1585x992.png" /usr/share/backgrounds/yaran/yaran-wallpaper.png
install -Dm 0644 /.temp_assets/yaran-sway/usr/share/applications/install-yaran.desktop /usr/share/applications/install-yaran.desktop
install -Dm 0644 /.temp_assets/yaran-sway/usr/share/icons/hicolor/scalable/apps/yaran.svg /usr/share/icons/hicolor/scalable/apps/yaran.svg

install -d -m 0755 /etc/environment.d
cat > /etc/environment.d/90-yaran-sway.conf <<'EOF'
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_DESKTOP=sway
XDG_SESSION_TYPE=wayland
EOF

# New users inherit these directories from /etc/skel.
install -d -m 0755 /etc/skel/APP /etc/skel/Projects /etc/skel/Pictures
install -m 0644 /.temp_assets/skel-Projects-README.txt /etc/skel/Projects/README.txt

# The live account predates the skel setup, so seed its home explicitly.
live_home=$(getent passwd admin | cut -d: -f6 || true)
if [ -n "$live_home" ] && [ -d "$live_home" ]; then
    install -d -m 0755 "$live_home/.config" "$live_home/APP" "$live_home/Projects" "$live_home/Pictures"
    cp -a /etc/skel/.config/. "$live_home/.config/"
    install -m 0644 /etc/skel/Projects/README.txt "$live_home/Projects/README.txt"
    chown -R admin:admin "$live_home/.config" "$live_home/APP" "$live_home/Projects" "$live_home/Pictures"
    usermod -aG audio,video admin
fi

fc-cache -f
