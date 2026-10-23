#!/bin/bash
set -euo pipefail

echo 'Configuring SDDM for Yaran Sway live desktop'

# Require the display manager and greeter theme before configuring graphical
# boot. This avoids depending on an optional package recommendation or on a
# desktop task setting the default systemd target.
[ -x /usr/bin/sddm ] || {
    echo 'sway-display-manager: /usr/bin/sddm is missing' >&2
    exit 1
}

staged_theme=/.temp_assets/yaran-sway/usr/share/sddm/themes/yaran-greeter
[ -s "$staged_theme/Main.qml" ] && [ -s "$staged_theme/theme.conf" ] || {
    echo 'sway-display-manager: staged Yaran SDDM theme is missing or incomplete' >&2
    exit 1
}
theme_dir=/usr/share/sddm/themes/yaran-greeter
install -d -m 0755 "$theme_dir"
cp -a "$staged_theme/." "$theme_dir/"
[ -s "$theme_dir/Main.qml" ] && [ -s "$theme_dir/theme.conf" ] || {
    echo 'sway-display-manager: failed to install the Yaran SDDM theme' >&2
    exit 1
}
[ -s "/usr/share/wallpapers/Yaran Emblem/contents/images/1585x992.png" ] || {
    echo 'sway-display-manager: Yaran SDDM wallpaper is missing' >&2
    exit 1
}

graphical_target=
for candidate in /lib/systemd/system/graphical.target /usr/lib/systemd/system/graphical.target; do
    if [ -e "$candidate" ]; then
        graphical_target=$candidate
        break
    fi
done
[ -n "$graphical_target" ] || {
    echo 'sway-display-manager: systemd graphical.target is missing' >&2
    exit 1
}

install -d -m 0755 /etc/sddm.conf.d /etc/X11 /etc/systemd/system
# Keep all Yaran-specific SDDM settings in one file so no package-generated or
# alphabetically loaded drop-in can silently select a different theme/session.
rm -f /etc/sddm.conf.d/10-yaran-display-manager.conf \
      /etc/sddm.conf.d/zz-yaran-live-autologin.conf
[ -s /etc/sddm.conf ] || {
    echo 'sway-display-manager: autologin configuration missing from /etc/sddm.conf' >&2
    exit 1
}
grep -qx 'Session=sway.desktop' /etc/sddm.conf || {
    echo 'sway-display-manager: canonical SDDM config does not select sway.desktop' >&2
    exit 1
}
cat >> /etc/sddm.conf <<'EOF'

[General]
DisplayServer=x11

[Theme]
ThemeDir=/usr/share/sddm/themes
Current=yaran-greeter
EOF

# Explicitly select SDDM for Debian display-manager-aware tooling and boot to
# graphical.target rather than relying on a minimal debootstrap default.
printf '%s\n' '/usr/bin/sddm' > /etc/X11/default-display-manager
ln -sfn "$graphical_target" /etc/systemd/system/default.target

grep -qx 'Current=yaran-greeter' /etc/sddm.conf || {
    echo 'sway-display-manager: Yaran theme is not selected in /etc/sddm.conf' >&2
    exit 1
}
grep -qx 'User=admin' /etc/sddm.conf || {
    echo 'sway-display-manager: live autologin user is missing from /etc/sddm.conf' >&2
    exit 1
}
echo 'sway-display-manager: canonical SDDM config, Yaran greeter and graphical.target configured'
