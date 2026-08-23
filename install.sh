#!/usr/bin/env bash
#
# Fedora dotfiles installer.
#
# config/home/  mirrors $HOME  (e.g. config/home/.bashrc -> ~/.bashrc)
# config/etc/   mirrors /etc   (e.g. config/etc/udev/rules.d/10-wakeup.rules -> /etc/udev/rules.d/10-wakeup.rules)
#
# Every file is symlinked into place so the repo stays the single source of
# truth. Safe to re-run (idempotent).

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${DOTFILES_DIR}/.backup/$(date +%Y%m%d-%H%M%S)"

log() { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1" >&2; }

require_fedora() {
	if [[ ! -f /etc/os-release ]] || ! grep -q '^ID=fedora' /etc/os-release; then
		warn "This script is intended for Fedora; continuing anyway."
	fi
}

# Symlink $1 (source in repo) -> $2 (destination path), backing up any
# existing non-symlink file/dir at the destination first. Pass "sudo" as $3
# to perform the filesystem operations as root.
link_file() {
	local src="$1" dest="$2" as="${3:-}"

	if [[ -L "$dest" ]] && [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
		log "Already linked: $dest"
		return
	fi

	if [[ -e "$dest" || -L "$dest" ]]; then
		${as} mkdir -p "$(dirname "${BACKUP_DIR}/${dest#/}")"
		log "Backing up existing $dest"
		${as} mv "$dest" "${BACKUP_DIR}/${dest#/}"
	fi

	${as} mkdir -p "$(dirname "$dest")"
	${as} ln -sf "$src" "$dest"
	log "Linked $dest -> $src"
}

# Symlink every file under $1 (a directory mirroring some root) into $2
# (that root), preserving the relative directory structure.
link_tree() {
	local src_root="$1" dest_root="$2" as="${3:-}"
	[[ -d "$src_root" ]] || return 0

	while IFS= read -r -d '' file; do
		local rel="${file#"$src_root"/}"
		link_file "$file" "${dest_root}/${rel}" "$as"
	done < <(find "$src_root" -type f -print0)
}

install_home_files() {
	link_tree "${DOTFILES_DIR}/config/home" "${HOME}"
}

install_etc_files() {
	link_tree "${DOTFILES_DIR}/config/etc" "/etc" sudo

	if [[ -d "${DOTFILES_DIR}/config/etc/udev" ]]; then
		log "Reloading udev rules"
		sudo udevadm control --reload-rules
	fi
}

install_backgrounds() {
	local dest="${HOME}/.local/share/backgrounds"
	mkdir -p "$dest"
	for f in "${DOTFILES_DIR}"/img/backgrounds/*; do
		link_file "$f" "${dest}/$(basename "$f")"
	done
}

setup_terminal() {
	log "Setting up terminal"
	"${DOTFILES_DIR}/scripts/setup-term.sh"
}

main() {
	require_fedora
	install_home_files
	install_etc_files
	install_backgrounds
	setup_terminal
	log "Done."
}

main "$@"
