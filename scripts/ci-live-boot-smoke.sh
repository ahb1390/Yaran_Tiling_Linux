#!/bin/bash
# Boot the ACTUAL generated live ISO in QEMU, then prove the Sway Super+Enter
# binding launches a terminal. This is separate from the tiny GRUB-fixture test.
set -euo pipefail

iso=${1:?Usage: ci-live-boot-smoke.sh ISO_PATH}
[ -s "$iso" ] || { echo "live-boot-smoke: ISO not found or empty: $iso" >&2; exit 1; }
for command in Xvfb qemu-system-x86_64 python3; do
    command -v "$command" >/dev/null 2>&1 || {
        echo "live-boot-smoke: missing tool: $command" >&2
        exit 1
    }
done
python3 -c 'from PIL import Image' >/dev/null 2>&1 || {
    echo 'live-boot-smoke: python3-pil is required' >&2
    exit 1
}

out_dir=$(dirname "$iso")
host_log="$out_dir/ci-live-boot-qemu.log"
serial_log="$out_dir/ci-live-boot-serial.log"
screenshot="$out_dir/ci-live-boot-screenshot.ppm"
first_graphical="$out_dir/ci-live-boot-first-graphical-screen.ppm"
first_graphical_captured=0
work=$(mktemp -d /tmp/yaran-live-boot-smoke.XXXXXX)
monitor="$work/monitor.sock"
display_number=99
display=":$display_number"
xvfb_pid=
qemu_pid=

cleanup() {
    if [ -n "$qemu_pid" ] && kill -0 "$qemu_pid" 2>/dev/null; then
        kill "$qemu_pid" 2>/dev/null || true
        wait "$qemu_pid" 2>/dev/null || true
    fi
    if [ -n "$xvfb_pid" ] && kill -0 "$xvfb_pid" 2>/dev/null; then
        kill "$xvfb_pid" 2>/dev/null || true
        wait "$xvfb_pid" 2>/dev/null || true
    fi
    rm -rf -- "$work"
}
trap cleanup EXIT

rm -f "$screenshot" "$first_graphical" "$serial_log" "$host_log"
Xvfb "$display" -screen 0 1280x800x24 -nolisten tcp -ac >"$work/xvfb.log" 2>&1 &
xvfb_pid=$!
for _ in $(seq 1 20); do
    [ -S "/tmp/.X11-unix/X$display_number" ] && break
    if ! kill -0 "$xvfb_pid" 2>/dev/null; then
        cat "$work/xvfb.log" >&2
        echo 'live-boot-smoke: Xvfb failed to start' >&2
        exit 1
    fi
    sleep 1
done
[ -S "/tmp/.X11-unix/X$display_number" ] || {
    cat "$work/xvfb.log" >&2
    echo 'live-boot-smoke: Xvfb display socket did not appear' >&2
    exit 1
}

export DISPLAY="$display"
qemu-system-x86_64 \
    -machine pc,accel=tcg -cpu max -smp 2 -m 4096 \
    -vga virtio -display gtk,gl=off \
    -boot order=d,menu=off -cdrom "$iso" \
    -nic user,model=virtio-net-pci \
    -monitor "unix:$monitor,server,nowait" \
    -serial "file:$serial_log" \
    -no-reboot -no-shutdown >"$host_log" 2>&1 &
qemu_pid=$!

take_monitor_action() {
    local action=$1
    local extra=${2:-}
    python3 - "$monitor" "$action" "$extra" <<'PY'
import socket
import sys
import time

monitor, action, extra = sys.argv[1:4]
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.settimeout(8)
sock.connect(monitor)

def read_prompt():
    result = bytearray()
    deadline = time.monotonic() + 8
    while b"(qemu)" not in result:
        if time.monotonic() > deadline:
            raise RuntimeError("QEMU monitor prompt timeout: " + result.decode(errors="replace"))
        chunk = sock.recv(4096)
        if not chunk:
            raise RuntimeError("QEMU monitor disconnected")
        result.extend(chunk)
    return bytes(result)

try:
    read_prompt()
    command = ("screendump " + extra) if action == "screendump" else ("sendkey " + action)
    sock.sendall((command + "\n").encode())
    reply = read_prompt().decode(errors="replace")
    if "invalid" in reply.lower() or "unknown" in reply.lower() or "error" in reply.lower():
        raise RuntimeError("QEMU monitor command failed: " + reply)
finally:
    sock.close()
PY
}

graphical_screen() {
    python3 - "$screenshot" <<'PY'
from PIL import Image
import sys

path = sys.argv[1]
try:
    image = Image.open(path).convert("RGB").resize((160, 100))
except Exception as exc:
    print(f"live-boot-smoke: screenshot could not be read: {exc}")
    raise SystemExit(1)
pixels = list(image.getdata())
lit = sum(1 for r, g, b in pixels if max(r, g, b) > 24)
ratio = lit / max(1, len(pixels))
colors = len(set(pixels))
print(f"live-boot-smoke: screen lit-pixel ratio={ratio:.3f}, colors={colors}")
# A blinking cursor on an otherwise black screen cannot pass this threshold.
raise SystemExit(0 if ratio >= 0.025 and colors >= 100 else 1)
PY
}

screen_changed() {
    python3 - "$work/before.ppm" "$screenshot" <<'PY'
from PIL import Image, ImageChops
import sys

before = Image.open(sys.argv[1]).convert("RGB").resize((160, 100))
after = Image.open(sys.argv[2]).convert("RGB").resize((160, 100))
difference = ImageChops.difference(before, after)
pixels = list(difference.getdata())
changed = sum(1 for r, g, b in pixels if max(r, g, b) >= 24)
ratio = changed / max(1, len(pixels))
print(f"live-boot-smoke: changed-pixel ratio after Super+Enter={ratio:.3f}")
# Opening foot should change a substantial part of the Sway desktop.
raise SystemExit(0 if ratio >= 0.04 else 1)
PY
}

echo "live-boot-smoke: booting actual image: $iso"
for second in $(seq 1 150); do
    if ! kill -0 "$qemu_pid" 2>/dev/null; then
        echo "live-boot-smoke: QEMU exited before Sway became ready" >&2
        tail -n 100 "$host_log" >&2 || true
        tail -n 100 "$serial_log" >&2 || true
        exit 1
    fi
    sleep 1
    if [ "$second" -lt 60 ] || [ $((second % 15)) -ne 0 ]; then
        continue
    fi

    echo "live-boot-smoke: checking live display after ${second}s"
    take_monitor_action screendump "$screenshot"
    if ! graphical_screen; then
        continue
    fi

    if [ "$first_graphical_captured" -eq 0 ]; then
        cp "$screenshot" "$first_graphical"
        first_graphical_captured=1
        echo 'live-boot-smoke: saved first graphical screen for diagnostics'
    fi
    cp "$screenshot" "$work/before.ppm"
    take_monitor_action meta_l-ret
    sleep 4
    take_monitor_action screendump "$screenshot"
    if screen_changed; then
        echo 'live-boot-smoke: PASS — graphical Sway desktop is responsive to Super+Enter'
        exit 0
    fi
    echo 'live-boot-smoke: display is visible but Super+Enter did not produce the expected terminal change; continuing boot checks'
done

echo 'live-boot-smoke: FAIL — the live Sway desktop did not pass the graphical/keyboard smoke test' >&2
echo 'live-boot-smoke: QEMU host log:' >&2
tail -n 120 "$host_log" >&2 || true
echo 'live-boot-smoke: guest serial log:' >&2
tail -n 120 "$serial_log" >&2 || true
exit 1
