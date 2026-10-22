# Yaran Tiling Linux — Sway Minimal Phase 1

This profile starts a Debian 13 (Trixie) AMD64 implementation of the Ubuntu
Sway Remix approach. It is an initial engineering profile, not a release claim
that every laptop has already been validated.

## Scope

- Sway/Wayland with a modular system configuration under /etc/sway.
- Waybar, foot, wofi, mako, SwayOSD, NetworkManager, PipeWire/WirePlumber,
  a PolicyKit agent, common firmware, and Persian-capable fonts.
- Calamares graphical installation and the existing GRUB/Plymouth branding.
- Explicit key bindings for Super+Enter, Super+KP_Enter, volume/mute, and
  brightness.
- No KDE Plasma desktop packages in this profile.

The existing 2.0 manifests and their tests are retained during the transition
as a comparison/fallback. The new profile is named
Yaran-2.1-amd64-sway-minimal.json.

## Validation required before treating the image as ready

CI runs manifest validation, policy tests, shell syntax checks, and the image
builder. That is not equivalent to a full desktop boot test. Before a public
release, boot the generated ISO in QEMU, complete a Calamares install to a
virtual disk, boot the installed system, and verify at least:

1. Live login, networking, terminal launcher, Waybar, notifications, and the
   installer launcher.
2. Super+Enter and numeric-keypad Super+KP_Enter.
3. Volume up/down/mute and brightness up/down with the OSD visible.
4. Suspend/resume and lid-close behaviour on physical laptop hardware.
5. A fresh Calamares-created user receives Sway defaults and APP, Projects,
   and Pictures directories.

Brightness support depends on the actual backlight controller and firmware;
passing CI cannot certify every laptop model.
