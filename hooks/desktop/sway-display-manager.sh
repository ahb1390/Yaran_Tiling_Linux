#!/bin/bash
set -euo pipefail

echo 'Configuring SDDM and installing the pinned Slice greeter theme'

[ -x /usr/bin/sddm ] || {
    echo 'sway-display-manager: /usr/bin/sddm is missing' >&2
    exit 1
}

# Pin the upstream revision so CI and future image builds use identical theme
# sources. Slice is licensed CC BY-SA 4.0; retain its license and attribution.
slice_commit=98996b49e0d5657f94cc0cfb71480da76c83b008
tmp_dir=$(mktemp -d /tmp/yaran-sddm-slice.XXXXXX)
trap 'rm -rf "$tmp_dir"' EXIT
curl --fail --location --retry 3 --retry-delay 2 \
  "https://codeload.github.com/EricKotato/sddm-slice/tar.gz/${slice_commit}" \
  --output "$tmp_dir/slice.tar.gz"
tar -xzf "$tmp_dir/slice.tar.gz" -C "$tmp_dir"
slice_source="$tmp_dir/sddm-slice-${slice_commit}"
[ -s "$slice_source/Main.qml" ] && [ -s "$slice_source/LICENSE" ] || {
    echo 'sway-display-manager: downloaded Slice theme is incomplete' >&2
    exit 1
}
theme_dir=/usr/share/sddm/themes/sddm-slice
install -d -m 0755 "$theme_dir"
cp -a "$slice_source/." "$theme_dir/"
# Keep the Yaran visual identity while using Slice's supported user config.
cat > "$theme_dir/theme.conf.user" <<'EOF'
[General]
font=Noto Sans
background=/usr/share/wallpapers/Yaran Emblem/contents/images/1585x992.png
bg_mode=fill
parallax_bg_shift=0
color_bg=#07110f
color_main=#e7f5ec
color_dimmed=#9dbfac
color_contrast=#10251b
manual=false
EOF
[ -s "$theme_dir/Main.qml" ] && [ -s "$theme_dir/theme.conf" ] && [ -s "$theme_dir/LICENSE" ] || {
    echo 'sway-display-manager: failed to install Slice theme or license' >&2
    exit 1
}
[ -s "/usr/share/wallpapers/Yaran Emblem/contents/images/1585x992.png" ] || {
    echo 'sway-display-manager: Yaran SDDM wallpaper is missing' >&2
    exit 1
}
[ -s /usr/share/wayland-sessions/sway.desktop ] || {
    echo 'sway-display-manager: Sway session file is missing' >&2
    exit 1
}
grep -Eq '^Exec=(/usr/bin/)?sway([[:space:]]|$)' /usr/share/wayland-sessions/sway.desktop || {
    echo 'sway-display-manager: unexpected Sway session entry' >&2
    exit 1
}

graphical_target=
for candidate in /lib/systemd/system/graphical.target /usr/lib/systemd/system/graphical.target; do
    if [ -e "$candidate" ]; then graphical_target=$candidate; break; fi
done
[ -n "$graphical_target" ] || {
    echo 'sway-display-manager: systemd graphical.target is missing' >&2
    exit 1
}

install -d -m 0755 /etc/sddm.conf.d /etc/X11 /etc/systemd/system
# Make this hook self-sufficient: never assume a previous hook created the
# canonical file. Preserve the required live autologin values explicitly.
cat > /etc/sddm.conf <<'EOF'
[Autologin]
User=admin
Session=sway.desktop
Relogin=false

[General]
DisplayServer=x11

[Theme]
ThemeDir=/usr/share/sddm/themes
Current=sddm-slice
EOF
rm -f /etc/sddm.conf.d/10-yaran-display-manager.conf \
      /etc/sddm.conf.d/zz-yaran-live-autologin.conf
printf '%s\n' '/usr/bin/sddm' > /etc/X11/default-display-manager
ln -sfn "$graphical_target" /etc/systemd/system/default.target

grep -qx 'Current=sddm-slice' /etc/sddm.conf
grep -qx 'User=admin' /etc/sddm.conf
grep -qx 'Session=sway.desktop' /etc/sddm.conf
grep -qx 'Relogin=false' /etc/sddm.conf
echo 'sway-display-manager: Slice theme, canonical SDDM autologin config and graphical.target configured'
