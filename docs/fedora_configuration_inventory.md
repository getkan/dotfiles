# Fedora Configuration Inventory

This is a selective, non-secret snapshot from the current Fedora 44 Workstation,
not a complete backup. Application profiles, credentials, private keys, data,
and system state are not captured here. See [the reinstall guide](fedora_safe_reinstall.md)
for encrypted backups and the home partition. Review the repository, including
already tracked files and Git history, for private information before publishing.

The existing managed home and system files are already symlinked into this
repository on the current system. Qt 5 and Qt 6 appearance preferences have
also been captured under `config/home/<user>/.config/qt5ct/` and `qt6ct/`.
These reference specific theme packages and paths which may not exist on a new
system. The installer will link them like other managed files; review them and
install compatible themes first if you intend to use them.

Additional managed preferences include GNOME Terminal selection, Terminator,
and Clipse configuration and theme. Terminator's saved
window position, size, title and session identifiers are intentionally omitted.
Clipse's clipboard history, log and temporary files are not included. Installing
the managed files backs up existing destination files and replaces them with
links; review the preferences before running the installer on another system.

The monitor layout in `~/.config/monitors.xml` is intentionally not committed:
it includes hardware identifiers. If needed, back it up privately with the
encrypted home backup and restore it only on compatible hardware. Review and
reconfigure displays after restoring.

## Selected GNOME settings

Recorded from GNOME Shell 50.6. These are selected settings only, not a complete
dconf export or extension configuration. To apply them, run the following as
the logged-in desktop user, not with `sudo`, after confirming the schemas and
keys exist on the new desktop. Skip settings that are incompatible with it.
This intentionally changes the corresponding existing desktop preferences:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 11'
gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 12'
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface enable-animations true
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:close'
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
gsettings set org.gnome.mutter dynamic-workspaces true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.interface clock-show-seconds false
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
gsettings set org.gnome.desktop.interface scaling-factor 1
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
gsettings set org.gnome.desktop.interface toolkit-accessibility false
gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy'
gsettings set org.gnome.mutter edge-tiling false
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.mutter overlay-key 'Super_L'
gsettings set org.gnome.desktop.peripherals.touchpad edge-scrolling-enabled false
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad send-events 'enabled'
gsettings set org.gnome.desktop.peripherals.touchpad speed 0.60000000000000009
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
```

The enabled GNOME extension was `tilingshell@ferrarodomenico.com` (Tiling
Shell). Install a version compatible with the new GNOME release before enabling
it. Selected preferences from Tiling Shell 18.0 are saved in
[`tilingshell.dconf`](../config/desktop/tilingshell.dconf). After reviewing the
file and confirming compatibility with the installed extension version, restore
them as the logged-in user from the repository root:

```bash
dconf load /org/gnome/shell/extensions/tilingshell/ < config/desktop/tilingshell.dconf
```

This overwrites the listed keys, not the whole dconf database. The recorded
monitor/workspace selections reference `Layout 1`, which is not present in the
recorded layouts; choose an existing layout in Tiling Shell after restoring.
Version and internal override state were intentionally excluded. Monitor
arrangements and other GNOME settings are not fully captured.

## Flatpak applications

Application IDs and origins recorded on the current system; versions are omitted
because they will change. Reinstall selectively from trusted, compatible
remotes; application data is not included.

| Application ID | Origin |
| --- | --- |
| `com.mattjakeman.ExtensionManager` | flathub |
| `com.sublimemerge.App` | flathub |
| `info.febvre.Komikku` | flathub |
| `it.mijorus.gearlever` | flathub |
| `net.ankiweb.Anki` | flathub |
| `nl.hjdskes.gcolor3` | fedora |
| `org.gimp.GIMP` | fedora |
| `org.gnome.Extensions` | fedora |
| `page.kramo.Sly` | flathub |

## Enabled DNF repository identifiers

These are identifiers, not repository definitions or credentials. Availability
and compatibility vary by Fedora release. Do not copy old repo files blindly.

```text
code
copr:copr.fedorainfracloud.org:azandure:clipse
copr:copr.fedorainfracloud.org:lihaohong:yazi
copr:copr.fedorainfracloud.org:phracek:PyCharm
copr:copr.fedorainfracloud.org:scottames:ghostty
docker-ce-stable
expressvpn-repo
fedora
fedora-cisco-openh264
k6
microsoft-edge-dev
remi
remi-modular
rpmfusion-free
rpmfusion-free-updates
rpmfusion-nonfree
rpmfusion-nonfree-updates
sublime-text
updates
```

The installed RPM package list, other application preferences, system services,
and machine-specific settings are not fully inventoried here. Save those
separately with the commands in the reinstall guide, review them for sensitive
information, and keep private material in the encrypted backup.
