#!/bin/bash
set -euo pipefail

printf 'Yaran Tiling Linux 2.1.1 \\n \\l\n' > /etc/issue
printf 'Yaran Tiling Linux 2.1.1\n' > /etc/issue.net

install -d -m 0755 /etc/default/grub.d
cat > /etc/default/grub.d/50-yaran.cfg <<'EOF'
GRUB_DISTRIBUTOR="Yaran Tiling Linux 2.1.1"
GRUB_THEME="/usr/share/grub/themes/yaran/theme.txt"
GRUB_BACKGROUND="/usr/share/grub/themes/yaran/background.png"
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
EOF
