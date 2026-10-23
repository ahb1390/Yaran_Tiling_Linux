#!/bin/bash
set -euo pipefail

# Stage image assets before chroot. This profile intentionally avoids
# Plasma-specific artwork and desktop defaults.
install -d -m 0755 "$ROOTFS/.temp_assets/yaran-sway"
cp -a ./assets/yaran-sway/. "$ROOTFS/.temp_assets/yaran-sway/"
install -d -m 0755 "$ROOTFS/.temp_assets/yaran-sway/usr/share/sddm/themes/yaran-greeter"
cp -a ./assets/yaran-plasma-theme/usr/share/sddm/themes/yaran-greeter/. \
    "$ROOTFS/.temp_assets/yaran-sway/usr/share/sddm/themes/yaran-greeter/"
cp -a ./assets/wallpapers "$ROOTFS/.temp_assets/"
cp -a ./assets/calamares "$ROOTFS/.temp_assets/"
cp -a ./assets/fastfetch "$ROOTFS/.temp_assets/"
cp -a ./assets/bash "$ROOTFS/.temp_assets/"
cp -a ./assets/grub-theme "$ROOTFS/.temp_assets/"
cp -a ./assets/plymouth "$ROOTFS/.temp_assets/"
cp -a ./assets/skel-Projects-README.txt "$ROOTFS/.temp_assets/"
install -Dm 0644 ./yaran.svg "$ROOTFS/.temp_assets/yaran-sway/usr/share/icons/hicolor/scalable/apps/yaran.svg"

# Keep installer branding scoped to this Sway profile.
branding="$ROOTFS/.temp_assets/calamares/branding/Yaran/branding.desc"
if [ -f "$branding" ]; then
    sed -i 's/productName: *"Yaran Linux"/productName:         "Yaran Tiling Linux"/; s/productVersion: *"2.0"/productVersion:      "2.1"/' "$branding"
    sed -i 's|https://github.com/ahb1390/Yaran_linux|https://github.com/ahb1390/Yaran_Tiling_Linux|g' "$branding"
fi
