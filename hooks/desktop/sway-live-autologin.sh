#!/bin/bash
set -euo pipefail

live_user=$(getent passwd admin | cut -d: -f1 || true)
if [ -z "$live_user" ]; then
    echo 'sway-live-autologin: no live account found' >&2
    exit 1
fi

session_file=/usr/share/wayland-sessions/sway.desktop
if [ ! -s "$session_file" ]; then
    echo "sway-live-autologin: Sway session file is missing: $session_file" >&2
    exit 1
fi
if ! grep -Eq '^Exec=(/usr/bin/)?sway([[:space:]]|$)' "$session_file"; then
    echo "sway-live-autologin: unexpected Sway session entry: $session_file" >&2
    exit 1
fi
session_name=$(basename "$session_file")

install -d -m 0755 /etc/sddm.conf.d
cat > /etc/sddm.conf.d/zz-yaran-live-autologin.conf <<EOF
[Autologin]
User=$live_user
Session=$session_name
Relogin=false
EOF

echo "sway-live-autologin: enabled SDDM autologin for $live_user into Sway"
