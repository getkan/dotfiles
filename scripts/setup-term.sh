#!/usr/bin/env bash
#
# Sets up the terminal environment: zsh, Oh My Zsh, zsh-autosuggestions,
# Starship, tmux, and Ghostty. Safe to re-run (each step is skipped if already done).
#
# Called from install.sh. The Starship config itself lives at
# config/home/<user>/.config/starship.toml and is installed by install.sh's normal
# config-mirroring step, not by this script.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_info() { echo -e "${YELLOW}→${NC} $1"; }

# Detect and set the package manager in PKG_MANAGER.
detect_package_manager() {
	if command -v dnf >/dev/null 2>&1; then
		PKG_MANAGER="dnf"
	elif command -v apt-get >/dev/null 2>&1; then
		PKG_MANAGER="apt"
	elif command -v pacman >/dev/null 2>&1; then
		PKG_MANAGER="pacman"
	else
		return 1
	fi
}

# Install one or more packages using the detected package manager.
install_packages() {
	case "$PKG_MANAGER" in
	apt)
		sudo apt-get update
		sudo apt-get install -y "$@"
		;;
	dnf)
		sudo dnf install -y "$@"
		;;
	pacman)
		sudo pacman -S --noconfirm "$@"
		;;
	*)
		print_error "Unsupported package manager: $PKG_MANAGER"
		return 1
		;;
	esac
}

# Install Ghostty build dependencies for the detected package manager.
install_ghostty_dependencies() {
	case "$PKG_MANAGER" in
	apt)
		install_packages \
			libgtk-4-dev \
			libadwaita-1-dev \
			build-essential \
			pkg-config \
			git \
			zig
		;;
	dnf)
		sudo dnf groupinstall -y "Development Tools"
		install_packages \
			gtk4-devel \
			libadwaita-devel \
			pkg-config \
			git \
			zig
		;;
	pacman)
		install_packages \
			base-devel \
			gtk4 \
			libadwaita \
			pkg-config \
			git \
			zig
		;;
	*)
		print_error "Unsupported package manager: $PKG_MANAGER"
		return 1
		;;
	esac
}

install_zsh() {
	if command -v zsh &>/dev/null; then
		print_status "zsh is already installed"
	else
		print_info "Installing zsh..."
		install_packages zsh
		print_status "zsh installed successfully"
	fi
}

install_oh_my_zsh() {
	if [ -d "$HOME/.oh-my-zsh" ]; then
		print_status "Oh My Zsh is already installed"
	else
		print_info "Installing Oh My Zsh..."
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		print_status "Oh My Zsh installed successfully"
	fi
}

install_zsh_autosuggestions() {
	local dir="${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	if [ -d "$dir" ]; then
		print_status "zsh-autosuggestions is already installed"
	else
		print_info "Installing zsh-autosuggestions..."
		git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
		print_status "zsh-autosuggestions installed successfully"
	fi
}

install_starship() {
	if command -v starship &>/dev/null; then
		print_status "Starship is already installed"
	else
		print_info "Installing Starship..."
		curl -sS https://starship.rs/install.sh | sh -s -- -y
		print_status "Starship installed successfully"
	fi
}

install_tmux() {
	if command -v tmux &>/dev/null; then
		print_status "tmux is already installed"
	else
		print_info "Installing tmux..."
		install_packages tmux
		print_status "tmux installed successfully"
	fi
}

install_ghostty() {
	if command -v ghostty &>/dev/null; then
		print_status "Ghostty is already installed"
	else
		print_info "Installing Ghostty dependencies..."
		install_ghostty_dependencies

		print_info "Building Ghostty from source..."
		local tmp_dir
		tmp_dir=$(mktemp -d)
		git clone https://github.com/mitchellh/ghostty.git "$tmp_dir/ghostty"
		(cd "$tmp_dir/ghostty" && zig build -p "$HOME/.local" -Doptimize=ReleaseFast)
		rm -rf "$tmp_dir"

		print_status "Ghostty installed successfully"
	fi
}

set_default_shell() {
	if [ "$SHELL" != "$(command -v zsh)" ]; then
		print_info "Setting zsh as default shell..."
		chsh -s "$(command -v zsh)"
		print_status "Default shell changed to zsh"
	else
		print_status "zsh is already the default shell"
	fi
}

configure_zshrc() {
	if ! grep -q 'eval "\$(starship init zsh)"' "$HOME/.zshrc"; then
		print_info "Adding Starship init to .zshrc..."
		{
			echo ""
			echo "# Starship prompt initialization"
			echo 'eval "$(starship init zsh)"'
		} >>"$HOME/.zshrc"
		print_status "Starship added to .zshrc"
	else
		print_status "Starship already configured in .zshrc"
	fi

	if grep -q "plugins=(" "$HOME/.zshrc" && ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
		print_info "Enabling zsh-autosuggestions plugin..."
		sed -i 's/plugins=(/plugins=(zsh-autosuggestions /' "$HOME/.zshrc"
		print_status "zsh-autosuggestions enabled"
	else
		print_status "zsh-autosuggestions already enabled (or no plugins= line found)"
	fi
}

main() {
	echo "================================"
	echo "Terminal Environment Setup"
	echo "================================"

	if [[ "$OSTYPE" != "linux-gnu"* ]]; then
		print_error "This script is designed for Linux. You are on $OSTYPE"
		return 1
	fi

	if ! detect_package_manager; then
		print_error "No supported package manager found (dnf, apt, or pacman)"
		return 1
	fi
	print_info "Detected package manager: $PKG_MANAGER"

	install_zsh
	install_oh_my_zsh
	install_zsh_autosuggestions
	install_starship
	install_tmux
	install_ghostty
	set_default_shell
	configure_zshrc

	print_status "Terminal setup complete. Restart your terminal to apply all changes."
}

main "$@"
