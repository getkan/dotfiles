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
```

The enabled GNOME extension was `tilingshell@ferrarodomenico.com` (Tiling
Shell). Install a version compatible with the new GNOME release before enabling
it. Its individual preferences are not captured here.

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

The installed RPM package list, other application preferences, extensions'
settings, system services, and machine-specific settings are not inventoried
here. Save those separately with the commands in the reinstall guide, review
them for sensitive information, and keep private material in the encrypted backup.
