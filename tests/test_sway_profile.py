"""Regression tests for the Yaran Tiling Linux Sway Minimal profile."""
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST_PATH = ROOT / "Yaran-2.1-amd64-sway-minimal.json"


class SwayManifestTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cfg = json.loads(MANIFEST_PATH.read_text())

    def test_manifest_targets_debian_trixie_amd64(self):
        self.assertEqual(self.cfg["suite"], "trixie")
        self.assertEqual(self.cfg["architecture"], "amd64")
        self.assertEqual(self.cfg["os_release"]["VARIANT_ID"], "sway-minimal")

    def test_core_desktop_packages_are_present(self):
        required = {
            "sway", "swaybg", "swayidle", "swaylock", "swayosd", "waybar",
            "foot", "wofi", "mako-notifier", "brightnessctl",
            "network-manager", "network-manager-gnome",
            "pipewire", "pipewire-pulse", "pipewire-audio", "wireplumber",
            "xdg-desktop-portal", "xdg-desktop-portal-wlr", "xdg-desktop-portal-gtk",
            "sddm", "calamares", "polkitd", "lxqt-policykit",
            "fonts-vazirmatn", "fonts-noto-core", "fonts-noto-cjk",
            "fonts-noto-color-emoji", "firmware-misc-nonfree", "bluez-firmware",
        }
        self.assertTrue(required <= set(self.cfg["packages"]),
                        f"missing core packages: {sorted(required - set(self.cfg['packages']))}")

    def test_sway_profile_does_not_ship_a_plasma_desktop(self):
        packages = set(self.cfg["packages"])
        forbidden = {
            "kde-plasma-desktop", "plasma-workspace", "kwin-x11", "kwin-wayland",
            "powerdevil", "plasma-pa", "plasma-nm", "bluedevil",
            "xdg-desktop-portal-kde", "dolphin", "konsole",
        }
        self.assertFalse(packages & forbidden, f"unexpected KDE packages: {sorted(packages & forbidden)}")
        self.assertTrue(forbidden <= set(self.cfg["exclude_packages"]))

    def test_package_manifest_is_deduplicated_and_uses_debian_sources(self):
        packages = self.cfg["packages"]
        self.assertEqual(len(packages), len(set(packages)))
        self.assertFalse(self.cfg["vendor_repositories"])
        self.assertFalse(any("backports" in src for src in self.cfg["apt_sources"]))
        for source in self.cfg["apt_sources"]:
            self.assertIn("debian.org", source)

    def test_keybindings_and_modular_config_exist(self):
        config = ROOT / "assets/yaran-sway/etc/sway/config.d"
        keys = (config / "30-yaran-keybindings.conf").read_text()
        for item in (
            "bindsym --to-code $mod+Return exec $term",
            "bindsym --to-code $mod+KP_Enter exec $term",
            "XF86AudioRaiseVolume", "XF86AudioLowerVolume", "XF86AudioMute",
            "XF86MonBrightnessUp", "XF86MonBrightnessDown",
        ):
            with self.subTest(binding=item):
                self.assertIn(item, keys)
        for module in ("10-yaran-inputs.conf", "20-yaran-autostart.conf",
                       "40-yaran-appearance.conf", "50-yaran-power.conf"):
            self.assertTrue((config / module).is_file(), f"missing module: {module}")

    def test_profile_hooks_are_ordered_and_verification_runs_last(self):
        pre = self.cfg["pre_chroot_scripts"]
        post = self.cfg["post_install_scripts"]
        self.assertIn("hooks/desktop/stage-sway-assets.sh", pre)
        self.assertLess(post.index("hooks/desktop/sway-defaults.sh"),
                        post.index("hooks/desktop/sway-live-autologin.sh"))
        self.assertLess(post.index("hooks/desktop/grub-theme.sh"),
                        post.index("hooks/desktop/plymouth-theme.sh"))
        self.assertEqual(post[-1], "hooks/common/verify-sway-image.sh")
        for script in pre + post:
            self.assertTrue((ROOT / script).is_file(), f"missing hook: {script}")

    def test_home_defaults_have_app_and_projects_folders(self):
        defaults = (ROOT / "hooks/desktop/sway-defaults.sh").read_text()
        self.assertIn("/etc/skel/APP", defaults)
        self.assertIn("/etc/skel/Projects", defaults)
        self.assertIn("install -d -m 0755 /usr/share/wallpapers", defaults)
        self.assertIn('"$live_home/.config"', defaults)

    def test_installer_keeps_graphical_calamares_and_sway_login(self):
        self.assertIn("calamares", self.cfg["packages"])
        self.assertIn("sddm", self.cfg["packages"])
        login = (ROOT / "hooks/desktop/sway-live-autologin.sh").read_text()
        self.assertIn("Session=sway", login)
        calamares = (ROOT / "assets/calamares/settings.conf").read_text()
        self.assertIn("partition", calamares)
        self.assertIn("finished", calamares)


if __name__ == "__main__":
    unittest.main()
