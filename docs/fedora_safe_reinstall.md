# Safely Reinstalling Fedora

This procedure treats "reflashing" as a clean Fedora operating-system installation
from a USB drive. It is **not** a BIOS/UEFI firmware update or a secure disk-erasure
procedure. A clean installation can permanently destroy files on the selected
disk. Do not proceed past a checkpoint until you can verify it.

If you only want a newer Fedora release, consider Fedora's supported upgrade
procedure instead. A reinstall is not required for a normal version upgrade.

## Existing Layout and Sharing Plan

On the machine inspected on 2026-11-06, Fedora 44 Workstation already has
separate ext4 filesystems: `/` on `/dev/nvme0n1p8` and `/home` on
`/dev/nvme0n1p9`. The home filesystem was approximately 600 GiB, with about
220 GiB used. The current account's numeric UID and primary GID were both
`1000`. The same disk also contains Windows/BitLocker and other partitions.
This is a snapshot, not an instruction to select those device names: verify
the current layout and UUIDs before making changes.

The recommended plan is to **preserve the existing `/home` filesystem**, install
Fedora onto the intended root filesystem, and configure the new system to mount
the existing filesystem at `/home` without formatting it. Access it from a live
USB as a separate data filesystem, preferably read-only; do not make a live
desktop use the installed user's entire home directory. A separate `/home`
survives a root reinstall only if the installer is explicitly told to preserve
it. It is not a backup and shares the same physical disk and failure risks.

Before attempting this, check the exact installer's manual storage capabilities.
If it cannot assign an existing filesystem to `/home` without formatting, or its
summary is ambiguous, cancel and use documentation or an installer that can
express that plan. Never substitute automatic whole-disk erase.

## 1. Prepare Before Changing Anything

Have the following available:

- AC power and enough uninterrupted time to back up, install, and restore.
- A USB drive large enough for the selected Fedora image. Writing the installer
  will erase that USB drive.
- A separate external backup disk with sufficient space. The installer USB is
  **not** your backup.
- Ideally, a second independent backup for irreplaceable files.
- Another device with internet access and a copy of this procedure.
- Login credentials, password-manager access, and offline recovery codes.
- Disk-encryption passphrases and recovery keys, including Windows BitLocker keys
  if the machine dual-boots.

For an employer-managed machine, confirm the reinstall and re-enrollment process
with its administrator first.

### Record the current machine

These commands inspect the running system; they do not repartition disks:

```bash
cat /etc/fedora-release
uname -m
lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS
findmnt /
findmnt /home
id -u
id -g
df -h
```

If `findmnt /home` produces no output, `/home` may simply be a directory within
the root filesystem rather than a separate mount. Inspect the `lsblk` output and
`findmnt /` instead; do not assume a separate home partition exists.

Save the output privately with your backup. Record or photograph:

- The intended installation disk's model, capacity, and serial number.
- All other internal disks and operating systems that must remain untouched.
- Whether the machine boots in UEFI or legacy BIOS mode. The presence of
  `/sys/firmware/efi` on the running installation indicates a UEFI boot.
- Partition and encryption layout, including any shared EFI System Partition.
- The filesystem UUID, type, size, mount point and disk for both `/` and `/home`;
  record the username and numeric UID and GID.
- Fedora edition, desktop, network requirements, and special drivers.

Disk names such as `/dev/sda` and `/dev/nvme0n1` can change when booting from USB.
Identify disks by model, capacity, and serial, not by device name alone.

## 2. Make and Verify Backups

### Back up the data that actually matters

Include files outside your usual Documents directory:

- Documents, photos, downloads, desktop files, and other users' home directories.
- Hidden configuration and application data, including relevant parts of
  `~/.config`, `~/.local/share`, and Flatpak data under `~/.var/app`.
- SSH and GPG keys, VPN profiles, certificates, and password-manager databases.
- Browser bookmarks and profiles, plus access to any browser-sync account.
- Git repositories, including uncommitted changes, untracked files, ignored
  configuration, local branches, and commits that have not been pushed.
- Virtual-machine images, containers' persistent volumes, and application data.
- Database exports made with the database's own backup tools.
- Important configuration under `/etc`, local work under `/opt` or `/usr/local`,
  scheduled jobs, and custom systemd units.
- Files on additional disks if they are also at risk during installation.

Quit applications before copying their data. Shut down virtual machines and use
application-aware backups for databases; copying active database files is not a
reliable database backup.

Use an existing trusted backup tool or copy files to the external disk. Preserve
hidden files, permissions, and symbolic links where needed. If the destination
filesystem cannot preserve Linux metadata, use a backup tool or archive format
that can, rather than treating a plain file copy as a complete system backup.

Encrypt backups containing private keys, passwords, or personal data, and keep
the decryption credentials somewhere accessible without this machine.

**Snapshots on the disk being reinstalled are not an independent backup.** This
includes Btrfs snapshots and a separate home subvolume on that same disk.

### Inventory and back up system files outside `/home`

The current request is to identify system configuration and data outside
`/home`. Preserving `/home` is a separate installation step and does **not**
protect it against disk failure, installer mistakes, or accidental deletion;
back it up separately if its contents matter. The repository and this checklist
are not the backup itself.

On the inspected machine, `/` is ext4 and was approximately 42 GiB used, while
`/boot/efi` is a separate filesystem. Confirm this again with `findmnt` and
`df -h` before sizing the backup. Other separate filesystems and external
devices must be explicitly identified and backed up when relevant; do not
assume a backup of `/` automatically includes them. The Windows and recovery
partitions require their own appropriate backup procedures.

Use the following checklist to choose what must be retained. Paths may be
absent, and services can store data in custom locations. Inspect the active
configuration and all mounts rather than assuming these paths are exhaustive:

- **System configuration and credentials:** back up `/etc` with permissions,
  ownership, ACLs, extended attributes and SELinux labels. In particular check
  NetworkManager connection profiles and Wi-Fi passwords in
  `/etc/NetworkManager/system-connections/`; SSH server configuration and host
  keys in `/etc/ssh/`; certificates and private keys in `/etc/pki/` and any
  custom certificate paths; VPN configuration and credentials in `/etc/openvpn/`,
  `/etc/wireguard/` or vendor-specific locations; and service credentials and
  environment files referenced by custom systemd units.
- **Accounts and system access:** `/etc/passwd`, `/etc/group`, `/etc/shadow`,
  `/etc/gshadow`, `/etc/sudoers` and `/etc/sudoers.d/` contain account details,
  password hashes or authorization rules. Record needed UID/GID mappings and
  administrator setup. Do not publish these files or blindly overwrite the new
  installation's accounts. Back up `/root`, including any root-owned SSH keys,
  scripts, configuration and application data.
- **Storage and boot configuration:** retain `/etc/fstab`, `/etc/crypttab`,
  relevant LVM, RAID, multipath and filesystem settings, and `/boot` for
  reference. Separately back up the mounted EFI System Partition at `/boot/efi`
  and record UEFI boot entries with `efibootmgr -v` if available. Preserve disk
  encryption passphrases and recovery keys offline, independently of the
  encrypted backup. These files and records are not a replacement for a
  tested full-disk image, partition table, or boot recovery procedure.
- **Services and scheduled jobs:** preserve local systemd units and overrides
  under `/etc/systemd/`, cron and anacron configuration and crontabs, timer
  settings, custom scripts, firewall rules, SELinux local customizations, and
  any required service-specific configuration and secrets. Record enabled
  services and timers with `systemctl list-unit-files --state=enabled` and
  `systemctl list-timers --all`; these outputs may contain private details.
- **Installed applications and local data:** review `/opt`, `/usr/local`,
  `/srv`, `/var/lib`, `/var/spool` and any application-specific locations for
  locally installed tools, custom binaries, service state, mail, print queues,
  and data. For this machine, check Docker, containerd and Podman storage,
  libvirt VM images, system Flatpak data and ExpressVPN state where present.
  Storage roots can be configured outside their default paths or on separate
  filesystems; inspect service configuration and mounts.
- **Databases, containers and virtual machines:** create application-consistent
  database exports, including roles and restore instructions as applicable.
  Back up container volumes, image/build definitions, compose files and required
  secrets; stop workloads or use their supported backup method. Shut down VMs
  or use a consistent snapshot/export procedure, and retain their definitions,
  disks and encryption keys. A live copy of changing files alone is not proof
  that any of these can be restored.
- **System package and hardware setup:** save package and repository
  inventories described below, installed driver details, kernel/module options,
  custom udev rules, printer configuration, and any local repository signing
  keys. Back up custom content under `/usr/local` and `/opt`; distribution
  packages should generally be reinstalled from trusted compatible sources.

For broad recovery coverage, use a trusted backup tool to capture the root
filesystem to a verified encrypted external disk with sufficient free space,
including hidden files, symlinks and Linux metadata. Deliberately exclude
`/home`, virtual/runtime filesystems such as `/proc`, `/sys`, `/dev`, `/run`
and `/tmp`, and the backup destination itself. Ensure the tool reports errors
and does not accidentally follow mount points or symlinks into excluded trees.
Back up the EFI filesystem and any other required persistent mounts separately.
To obtain a consistent system filesystem copy, prefer a clean shutdown followed
by an offline backup from trusted live media; a running system can change while
being copied. The backup must preserve symlinks as links: for example, this
machine's managed files under `/etc` point into the repository under `/home`,
so their targets are **not** included when `/home` is excluded. Back up that
repository separately if the links need to work after recovery.

Encrypt the backup before copying sensitive files, protect its passphrase
separately, and do not put this archive, its secrets, or private inventories in
Git. Check the backup log for unreadable files and skipped mounts. Verify by
restoring representative system configs, symlinks and metadata to a separate
location, and by testing database/VM/application restores where feasible. This
system-only backup does not cover home data, separately mounted filesystems not
backed up, unsaved live service state, firmware, or an exact bootable disk image.
Do not claim complete recovery until each required source and restore path has
been checked.

### Record software for selective restoration

On a conventional DNF-based Fedora installation:

```bash
dnf repoquery --userinstalled
dnf repolist --enabled
```

If Flatpak is installed:

```bash
flatpak list --app
flatpak remotes --show-details
```

Save these lists with the backup. For an Atomic Desktop such as Silverblue or
Kinoite, record `rpm-ostree status` instead of relying on a DNF package inventory,
and record any Toolbx or other development-container setup separately.

These lists are an inventory, not a script to reinstall every old package.
Do not copy repository credentials or publish private system configuration.
The [configuration inventory](fedora_configuration_inventory.md) records
selected desktop settings and software identifiers; it does not contain all
settings or replace the private inventory and backup.

### Git repository and secrets

The existing managed dotfiles are already linked into this repository on this
machine; edits made through those links are edits to the repository. This does
not capture all desktop settings, installed applications, home data, or system
configuration. Review `git status` and `git diff`, including untracked files,
before staging anything.

The project's `.env` is ignored and has been removed from the Git index while
the local file remains. The repository also tracks historical `.backup/` files.
An ignore rule does not protect files already tracked, and removing a
file from a later commit does not remove it from earlier history. Review these
files, the rest of the repository, and any history that would be published
before pushing. The installer only accepts its documented settings in `.env`,
not arbitrary secret entries. If credentials have
already been exposed, revoke or rotate them; removing a file alone is not
sufficient. Keep secrets, SSH/GPG keys, password-manager data, browser profiles,
and private configuration in the encrypted off-machine backup instead. Record
where each secret belongs and how to restore it, without recording its value
in the repository. A private GitHub repository is not an encrypted backup.

### Prove restoration works

1. Confirm the external backup disk is actually mounted. Verify its identity and
   free space in the file manager or with `lsblk` and `df -h`; a directory named
   "backup" on the internal disk does not count.
2. Check the backup tool's completion status and logs for errors or skipped files.
3. Disconnect and reconnect the backup disk, then unlock it if encrypted.
4. Restore representative files into a temporary directory, not over originals.
5. Open restored documents and photos, compare important files with their
   originals, and verify that keys and database exports are present.
6. Confirm that the backup passphrase, password manager, and recovery codes are
   accessible from another device or offline.

**Checkpoint: stop if any important data has no verified, readable off-machine
copy.** If recovering the exact previous system is essential, also create and
validate a full-disk image using a trusted imaging tool before reinstalling.
A file backup alone does not restore the old bootloader or complete system.

## 3. Download and Verify Fedora

1. Start at [Fedora's official website](https://fedoraproject.org/) and select a
   currently supported release, the intended edition, and the correct CPU
   architecture. Do not assume an Intel/AMD image is suitable for ARM hardware.
2. Prefer Fedora Media Writer, obtained through Fedora's official download
   instructions, to download and write the installer.
3. If downloading an ISO manually, follow
   [Fedora's verification instructions](https://fedoraproject.org/security/).
   Verify the checksum file's signature with the appropriate Fedora signing key,
   check its fingerprint against Fedora's published fingerprint, and then verify
   the ISO against that authenticated checksum.
4. Do not proceed if the signature or checksum check fails. A matching checksum
   from an unauthenticated source alone does not prove the image is genuine.

Avoid third-party installer images and commands that download and execute scripts.

## 4. Write the Installer USB

1. Disconnect the backup disk and other unnecessary removable storage.
2. Plug in only the USB drive intended for the installer.
3. In Fedora Media Writer, confirm the selected image and the destination USB's
   identity and capacity before approving the write.
4. Wait for writing and any offered verification to complete successfully.
5. Eject the USB safely.

**Checkpoint: the USB-writing target must never be the internal system disk or
your backup disk.** This guide deliberately avoids raw `dd` commands because a
mistyped destination can overwrite the wrong disk.

## 5. Boot the Live Environment and Check Hardware

1. Leave the backup disk disconnected.
2. Use the firmware's one-time boot menu to boot the installer USB. For a current
   UEFI installation, choose its UEFI entry rather than a legacy/CSM entry.
3. Keep Secure Boot enabled unless official guidance for your hardware requires
   a specific change. Standard Fedora installation media supports Secure Boot.
4. If the boot menu offers a media-test option, run it and investigate any error.
5. Use the live session, where available, before starting installation.
6. Check display, keyboard, touchpad, Wi-Fi or Ethernet, audio, and access to the
   expected internal disk. Confirm that you have a workable network connection.

For editions without a live desktop, use the installer's available hardware
checks and consult that edition's installation documentation.

If essential hardware does not work, stop and investigate before erasing the
existing installation. Do not combine this reinstall with speculative firmware,
storage-controller, or RAID-mode changes.

## 6. Install With an Explicit Disk Plan

Installer labels and screens vary by Fedora release and edition. Follow the
displayed actions and storage summary, not an assumed sequence of button names.

### Safest straightforward case: replace Fedora on a dedicated disk

1. If practical and you know how to do so safely, power off and disconnect
   non-target internal data disks before installation. Otherwise, leave them
   unselected and scrutinize the storage summary.
2. Select only the intended Fedora installation disk, matching its model,
   capacity, and serial number to your inventory.
3. Choose the clean-install/replace layout only after confirming that every
   needed file from that disk is backed up.
4. Enable disk encryption if offered and appropriate. Store the passphrase
   independently; do not depend on automatic unlock as your only recovery path.
5. Review the final storage changes before approving installation. Confirm every
   partition to be deleted or formatted belongs to the intended target.

### Dual boot, multiple operating systems, or preserving partitions

- Do not choose an "erase disk" or equivalent whole-disk option.
- Identify Windows, recovery, vendor, shared EFI, and data partitions beforehand.
- Do not format a shared EFI System Partition. Reusing it for boot files is
  different from formatting it.
- On Windows, save the BitLocker recovery key before changing boot configuration.
  Follow Microsoft's guidance for suspending protection when necessary, and
  resume it after verifying Windows boots.
- Do not assume keeping `/home` is a backup. Reusing a partition or Btrfs
  subvolume requires understanding the existing layout and explicit control over
  which filesystems are formatted.
- If the proposed changes are unclear, cancel and consult Fedora's installation
  documentation or someone who can review the actual layout.

### Preserve this machine's existing `/home`

Do this only after the backup checkpoint and confirming the live installer has
an explicit manual/custom partitioning option:

1. Re-run `lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,UUID,MOUNTPOINTS` and match
   the physical disk and recorded filesystem UUIDs. The running live system's
   `/home` belongs to the live session and is **not** the installed home.
2. Select the intended Fedora disk and manual/custom storage. Identify the
   existing ext4 home filesystem by its recorded UUID, size and parent disk,
   not by the temporary device name or a partition number alone.
3. Assign that existing filesystem to `/home`, explicitly select reuse/preserve
   and **do not format or delete it**. If the interface does not clearly allow
   this, cancel. An existing filesystem may require an explicit mount-point
   assignment; merely leaving the partition untouched does not mount it.
4. Assign the intended Fedora root filesystem to `/` and format only that root
   filesystem if a clean installation is intended. Preserve the existing EFI
   filesystem without formatting it, and keep Windows, recovery and all other
   partitions untouched. Do not select automatic erase or reclaim disk space.
5. Before accepting changes, inspect the installer's complete storage summary:
   `/home` must be the previously identified filesystem, mounted at `/home`,
   with no format or deletion action. `/` must be the intended root filesystem.
   Stop if any action or mount point is uncertain.
6. Create the intended user with the same username and, where possible, the
   same numeric UID and primary GID recorded above. A matching name alone is
   insufficient; Linux permissions use numeric IDs. Do not recursively change
   ownership as a shortcut. Verify ownership and resolve mismatches selectively.
7. After booting the installed system, confirm `findmnt /home`, `lsblk -f`,
   `id -u`, and `id -g` match the recorded plan. Check that the installer added
   the correct persistent `/home` mount in the new system's `/etc/fstab`; do
   not copy the old fstab over it. Verify the home mount before writing files
   there, and investigate any SELinux labels as described below.

If reusing the old home is undesirable, a clean installation with a newly
created separate home filesystem followed by a selective restore from the
verified backup is an alternative. It still requires a reviewed manual storage
plan and must not overwrite partitions belonging to other systems.

**Final destructive-action checkpoint**

- [ ] Off-machine backups were restored successfully.
- [ ] The backup disk is disconnected.
- [ ] The target disk's identity matches the recorded inventory.
- [ ] All deletion and formatting operations are understood and intended.
- [ ] Other operating systems and data disks are excluded from destructive changes.
- [ ] Encryption credentials and account-recovery methods are available.

Only then approve installation. Keep the machine on AC power and do not interrupt
the installer. When prompted, reboot and remove the installer USB.

## 7. Validate the New System Before Restoring Everything

1. Boot from the internal disk without the USB.
2. Confirm that login works and disk encryption can be unlocked.
3. Check networking, display, audio, external monitors, suspend/resume, and any
   essential peripherals.
4. Install updates using the edition's supported updater, then reboot.
   On conventional DNF-based Fedora:

   ```bash
   sudo dnf upgrade --refresh
   ```

   On an rpm-ostree-based Atomic Desktop:

   ```bash
   rpm-ostree upgrade
   ```

   If Flatpak is installed, update its applications with `flatpak update`.
   Review and resolve update errors rather than assuming the system is current.
5. Reinstall applications from trusted sources. Add third-party repositories and
   drivers deliberately; confirm release compatibility and any Secure Boot
   signing/enrollment requirements.
6. If dual-booting, confirm the other operating system still boots and verify
   BitLocker protection is in the intended state.

## 8. Restore Data Selectively

1. Reconnect and unlock the backup disk only after the installation is complete.
2. Restore personal files first, then application data and selected settings.
3. Avoid blindly restoring all of `/etc`, the old root filesystem, boot files,
   `/etc/fstab`, or old repository definitions over the new installation.
4. Restore hidden application settings selectively; old settings can reproduce
   the problems that motivated reinstalling.
5. Check file ownership and permissions, especially if the new account has a
   different numeric user ID. Preserve restrictive permissions on private keys.
   Do not apply blanket recursive permission changes to your home directory.
6. If restored home files have SELinux access problems, investigate labels.
   After confirming the files are in their intended locations, Fedora's
   `restorecon` can restore standard home-directory labels:

   ```bash
   sudo restorecon -RFv /home/YOUR_USERNAME
   ```

   Replace `YOUR_USERNAME` with the actual account name. This restores policy
   labels, not file ownership or application-specific permissions.
7. Validate databases by importing exports into a compatible database version,
   rather than dropping raw files into the new server's data directory.
8. Check representative documents, development projects, SSH access, password
   manager access, browser data, and essential applications.
9. Re-enable scheduled backups and perform a fresh backup of the working system.

Keep the pre-install backup untouched until you have used the new system for
normal work and verified that nothing important is missing. Do not erase your
only recovery copy just because the desktop boots.

## 9. Access the Home Filesystem From a Live USB

This works only when the live Linux system supports the filesystem and storage
stack. The present home filesystem is ext4; an encrypted, LVM, RAID, or Btrfs
layout has additional unlock and assembly steps. A different distribution may
use different tools, policies, and device names. A live system may discard its
own changes at shutdown unless it has persistence configured; writes to the
internal home filesystem, however, persist immediately.

1. Shut down the installed OS cleanly; do not use a hibernated or actively
   mounted filesystem. Boot a trusted live USB and choose its live session.
   Do not log into the installed account or set the live account's home to the
   preserved directory. Check for automatic mounts before proceeding.
2. Identify the home filesystem again using `lsblk -f`, `findmnt`, its recorded
   UUID, filesystem type, size and parent disk. Do not use the live session's
   own `/home` as evidence. Verify it is not already mounted. If it is mounted,
   inspect the mount options; do not unmount an actively used filesystem.
3. For an **unmounted ext4** home filesystem, mount it read-only without ext4
   journal replay. Replace `YOUR-HOME-UUID` with the verified UUID, and ensure
   `/mnt/fedora-home` is not already a mount point:

   ```bash
   sudo mkdir -p /mnt/fedora-home
   if findmnt --mountpoint /mnt/fedora-home; then
     echo "Mount point already in use; stop and investigate." >&2
   else
     sudo mount -t ext4 -o ro,noload /dev/disk/by-uuid/YOUR-HOME-UUID /mnt/fedora-home &&
       findmnt -no SOURCE,FSTYPE,OPTIONS --mountpoint /mnt/fedora-home
   fi
   ```

   If the mount point is already in use, the command refuses to mount over it.
   Confirm the final output identifies the intended ext4 filesystem and includes
   `ro`. If mounting
   fails, stop and investigate rather than retrying with repair or write
   options. `noload` avoids journal writes but an unclean filesystem may show
   an inconsistent view; boot the installed OS and shut it down cleanly first.
4. The installed user's files are under `/mnt/fedora-home/YOUR_USERNAME`.
   Read-only mounting does not bypass Unix permissions: a live user's numeric
   UID/GID may differ. Use the live system's administrator privileges only
   when needed to read or copy files; never recursively `chown` the shared home
   just to make the live user match. Keep private data protected.
5. Close files and applications, then unmount when finished:

   ```bash
   sudo umount /mnt/fedora-home
   ```

   If it is busy, close the processes using it and retry; do not force
   unmount. If a trusted live session must write data, take a verified backup
   first, unmount the read-only mount, mount the identified filesystem normally
   using the live system's documented procedure, and unmount cleanly afterward.
   Writes are real changes to the installed system, not disposable live-session
   changes.

Sharing a full home directory between installations can cause incompatible
GNOME/dconf, browser, Flatpak, and application-profile migrations or
simultaneous-write corruption. A safer cross-distribution workflow is to keep
each OS's own home and application settings, and selectively access shared
documents/projects on the preserved filesystem or a dedicated data filesystem.
Never use the same profile concurrently, including from multiple booted systems.
Check permissions and SELinux labeling on Fedora if files written by another OS
are inaccessible; do not disable SELinux or blanket-change ownership.

## 10. If Something Goes Wrong

| Situation | Safe next action |
|---|---|
| Backup cannot be read or decrypted | Stop before installation; fix access and repeat a restore check. |
| Download verification or media test fails | Download/write again using official sources; replace the USB if failures persist. |
| Installer cannot identify the intended disk | Cancel; investigate storage hardware and configuration without formatting anything. |
| Unexpected partitions appear in the deletion summary | Cancel and compare with the recorded disk inventory. |
| Installation fails | Record the error, preserve logs privately, and boot the live USB to investigate before retrying. |
| New installation will not boot | Use the USB/live environment to inspect the disk and consult Fedora boot-recovery documentation; avoid blind repartitioning. |
| The wrong disk may have been erased | Stop using that disk immediately. Do not reinstall onto it or restore files to it; consider professional recovery. |
| Files are missing after restoration | Preserve the backup, inspect its inventory and logs, and restore to a separate location before making further changes. |
| Home filesystem missing or mounted at the wrong place | Stop writing to `/home`; compare `findmnt` and filesystem UUIDs with the recorded plan and repair the mount configuration before restoring data. |
| Live USB cannot read the shared home | Check filesystem support, encryption, mount state and numeric ownership; do not format it or change ownership recursively. |

If the old system has already been overwritten, returning to it requires a
verified system image or a new installation plus data restoration. There is no
general "undo reinstall" operation.

## Official References

- [Fedora downloads and editions](https://fedoraproject.org/)
- [Fedora image verification and signing keys](https://fedoraproject.org/security/)
- [Fedora documentation](https://docs.fedoraproject.org/)
- [Fedora Quick Docs](https://docs.fedoraproject.org/en-US/quick-docs/)

Use documentation matching your chosen Fedora edition and release, especially
for installer storage screens, Atomic Desktop management, and boot recovery.
