#!/bin/bash
# Sway-specific checks; separate from the legacy Plasma verifier.
set -euo pipefail

fail=0
problem() { echo "verify-sway-image: FAIL: $*" >&2; fail=1; }
ok() { echo "verify-sway-image: ok: $*"; }
has_package() {
    # Avoid a dpkg-query | grep -q pipeline: under pipefail the consumer can
    # exit early and turn a successful query into a SIGPIPE failure.
    status=$(dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null || true)
    [ "$status" = installed ]
}

for pkg in sway swaybg swayidle swaylock swayosd waybar foot wofi mako-notifier \
           brightnessctl grim slurp wl-clipboard xwayland \
           network-manager network-manager-gnome \
           pipewire pipewire-pulse pipewire-audio wireplumber \
           xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
           rtkit alsa-ucm-conf libspa-0.2-bluetooth \
           sddm calamares polkitd lxqt-policykit upower power-profiles-daemon \
           fonts-vazirmatn fonts-noto-core fonts-noto-cjk fonts-noto-color-emoji \
           firmware-misc-nonfree bluez-firmware zram-tools; do
    has_package "$pkg" || problem "required Sway profile package missing: $pkg"
done

for file in /etc/sway/config /etc/sway/variables \
            /etc/sway/config.d/10-yaran-inputs.conf \
            /etc/sway/config.d/20-yaran-autostart.conf \
            /etc/sway/config.d/30-yaran-keybindings.conf \
            /etc/sway/config.d/40-yaran-appearance.conf \
            /etc/sway/config.d/50-yaran-power.conf \
            /etc/skel/.config/sway/config \
            /etc/skel/.config/waybar/config.jsonc \
            /etc/skel/.config/waybar/style.css \
            /etc/skel/.config/mako/config; do
    [ -s "$file" ] || problem "required Sway configuration missing or empty: $file"
done

keys=/etc/sway/config.d/30-yaran-keybindings.conf
grep -Fq 'bindsym --to-code $mod+Return exec $term' "$keys" || problem 'Super+Enter terminal binding missing'
grep -Fq 'bindsym --to-code $mod+KP_Enter exec $term' "$keys" || problem 'Super+KP_Enter numeric keypad binding missing'
grep -Fq 'XF86AudioRaiseVolume' "$keys" || problem 'volume-up key binding missing'
grep -Fq 'XF86AudioLowerVolume' "$keys" || problem 'volume-down key binding missing'
grep -Fq 'XF86AudioMute' "$keys" || problem 'audio-mute key binding missing'
grep -Fq 'XF86MonBrightnessUp' "$keys" || problem 'brightness-up key binding missing'
grep -Fq 'XF86MonBrightnessDown' "$keys" || problem 'brightness-down key binding missing'
grep -Fq 'exec swayosd-server' /etc/sway/config.d/20-yaran-autostart.conf || problem 'SwayOSD server is not started'
grep -Fq 'exec waybar' /etc/sway/config.d/20-yaran-autostart.conf || problem 'Waybar is not started'
grep -Fq 'exec mako' /etc/sway/config.d/20-yaran-autostart.conf || problem 'notification daemon is not started'

[ -s /usr/share/wayland-sessions/sway.desktop ] || problem 'Sway Wayland session file missing'
grep -qx 'Theme=yaran' /etc/plymouth/plymouthd.conf 2>/dev/null || problem 'Plymouth theme is not selected'
[ -s /usr/share/plymouth/themes/yaran/yaran.script ] || problem 'Yaran Plymouth script missing'
[ -s /usr/share/plymouth/themes/yaran/background.png ] || problem 'Yaran Plymouth background missing'
[ -s /usr/share/grub/themes/yaran/theme.txt ] || problem 'Yaran GRUB theme missing'
[ -s /usr/share/grub/themes/yaran/background.png ] || problem 'Yaran GRUB background missing'
[ -x /usr/local/bin/yaran-update ] || problem 'yaran-update helper missing'
[ -s /usr/share/applications/install-yaran.desktop ] || problem 'Calamares launcher is missing'
[ -d /etc/skel/APP ] || problem '/etc/skel/APP is missing'
[ -d /etc/skel/Projects ] || problem '/etc/skel/Projects is missing'
[ -f /etc/environment.d/90-yaran-sway.conf ] || problem 'Sway XDG environment is missing'

# Validate the complete effective config without a running Wayland session.
# Sway still expects XDG_RUNTIME_DIR even in config-check mode, and a build
# chroot has no logged-in user's runtime directory. Create a private temporary
# runtime directory so the check validates the config rather than failing on
# missing session environment.
if command -v sway >/dev/null 2>&1; then
    runtime_dir=$(mktemp -d /tmp/yaran-sway-config-check.XXXXXX)
    chmod 0700 "$runtime_dir"
    # Run Sway's validator against a headless/pixman backend; the chroot has
    # no physical seat, display server, or logind user session. These wlroots
    # variables prevent config validation from trying to open real hardware.
    export WLR_BACKENDS=headless
    export WLR_RENDERER=pixman
    export WLR_LIBINPUT_NO_DEVICES=1
    if validation_output=$(XDG_RUNTIME_DIR="$runtime_dir" sway -C -c /etc/sway/config 2>&1); then
        ok 'Sway configuration parses successfully with the headless backend'
    else
        problem "Sway configuration validation failed: $validation_output"
    fi
    rm -rf -- "$runtime_dir"
fi

for pkg in kde-plasma-desktop plasma-workspace powerdevil plasma-pa plasma-nm bluedevil xdg-desktop-portal-kde; do
    if has_package "$pkg"; then
        problem "KDE/Plasma package must not ship in Sway Minimal: $pkg"
    fi
done

if [ "$fail" -ne 0 ]; then
    echo 'verify-sway-image: Sway Minimal image failed consistency checks' >&2
    exit 1
fi
echo 'verify-sway-image: all Sway profile checks passed'
