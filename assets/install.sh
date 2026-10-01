#!/usr/bin/env bash
set -e

echo "==== Neovim development environment installer ===="

PREFIX="$HOME/.local"
BIN="$PREFIX/bin"

mkdir -p "$BIN"
mkdir -p "$PREFIX/nodejs"

################################
# OS / arch detection
################################

OS_NAME="$(uname -s)"
ARCH_NAME="$(uname -m)"

case "$OS_NAME" in
    Linux)
        OS_KIND="linux"
        case "$ARCH_NAME" in
            x86_64)
                NVIM_ASSET="nvim-linux-x86_64"
                NODE_ARCH="linux-x64"
                GO_ARCH="linux-amd64"
                RG_TARGET="x86_64-unknown-linux-musl"
                FD_TARGET="x86_64-unknown-linux-musl"
                ;;
            aarch64|arm64)
                NVIM_ASSET="nvim-linux-arm64"
                NODE_ARCH="linux-arm64"
                GO_ARCH="linux-arm64"
                RG_TARGET="aarch64-unknown-linux-gnu"
                FD_TARGET="aarch64-unknown-linux-gnu"
                ;;
            *) echo "Unsupported Linux arch: $ARCH_NAME" >&2; exit 1 ;;
        esac
        ;;
    Darwin)
        OS_KIND="macos"
        case "$ARCH_NAME" in
            x86_64)
                NVIM_ASSET="nvim-macos-x86_64"
                NODE_ARCH="darwin-x64"
                GO_ARCH="darwin-amd64"
                RG_TARGET="x86_64-apple-darwin"
                FD_TARGET="x86_64-apple-darwin"
                ;;
            arm64)
                NVIM_ASSET="nvim-macos-arm64"
                NODE_ARCH="darwin-arm64"
                GO_ARCH="darwin-arm64"
                RG_TARGET="aarch64-apple-darwin"
                FD_TARGET="aarch64-apple-darwin"
                ;;
            *) echo "Unsupported macOS arch: $ARCH_NAME" >&2; exit 1 ;;
        esac
        ;;
    *)
        echo "Unsupported OS: $OS_NAME" >&2
        exit 1
        ;;
esac

echo "Detected OS: $OS_KIND / arch: $ARCH_NAME"

################################
# Toolchain sanity check (non-fatal)
################################
#
# Native builds (treesitter parsers, tiktoken for CopilotChat) and the
# pip-based Mason packages (ruff, clang-format, cmakelang) need a C compiler
# and python3. The installer does not install these itself: on HPC and other
# non-root hosts they come from `module load` or from an admin's apt/yum.

WARN_TOOLCHAIN=0
if ! command -v cc >/dev/null 2>&1; then WARN_TOOLCHAIN=1; fi
if ! command -v python3 >/dev/null 2>&1; then WARN_TOOLCHAIN=1; fi

if [ "$WARN_TOOLCHAIN" = "1" ]; then
    echo ""
    echo "WARNING: missing host toolchain (one of: cc, python3)."
    if [ "$OS_KIND" = "macos" ]; then
        echo "  Install Xcode from the App Store, or just the Command Line Tools:"
        echo "      xcode-select --install"
    else
        echo "  Debian/Ubuntu: sudo apt install build-essential python3 python3-pip"
        echo "  HPC: load equivalent modules (e.g. \`module load gcc python\`)."
    fi
    echo "  Continuing anyway - some build steps may fail later."
    echo ""
fi

################################
# Shell rc selection / PATH setup
################################

# Pick the rc file of the user's login shell (macOS defaults to zsh, but bash
# users on macOS and all Linux users get ~/.bashrc).
case "$(basename "${SHELL:-/bin/bash}")" in
    zsh) SHELL_RC="$HOME/.zshrc" ;;
    *)   SHELL_RC="$HOME/.bashrc" ;;
esac

touch "$SHELL_RC"

add_to_rc() {
    if ! grep -qF "$1" "$SHELL_RC"; then
        echo "$1" >> "$SHELL_RC"
    fi
}

# Append a multi-line block to the rc file, idempotent via a marker.
# Usage: add_block_to_rc <marker> <<'EOF' ... EOF (block on stdin)
add_block_to_rc() {
    local marker="$1"
    if ! grep -qF "$marker" "$SHELL_RC"; then
        printf '\n%s\n' "$marker" >> "$SHELL_RC"
        cat >> "$SHELL_RC"
    else
        # discard the heredoc body so the caller's stdin is consumed
        cat >/dev/null
    fi
}

add_to_rc 'export PATH="$HOME/.local/bin:$PATH"'
add_to_rc 'export PATH="$HOME/.local/go/bin:$PATH"'
add_to_rc 'export PATH="$HOME/go/bin:$PATH"'

# The lines above only affect *future* shells. Export the same PATH for this
# script so the tools installed below are found without a shell restart.
export PATH="$BIN:$PREFIX/go/bin:$HOME/go/bin:$PATH"

################################
# Neovim
################################

echo "Installing Neovim..."

# Pinned Neovim version. Change this single value to switch versions;
# the matching release is fetched from GitHub.
NVIM_VERSION="0.12.0"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_ASSET}.tar.gz"

# The official release tarball is used on every platform. It needs no
# FUSE/libfuse2 (unlike running an AppImage), works on root-less hosts and
# containers, and is the only form shipped for macOS and Linux arm64.
NVIM_DIR="$PREFIX/nvim"

# (Re)install unless the installed binary already matches the pinned version.
if [ ! -x "$BIN/nvim" ] || ! "$BIN/nvim" --version 2>/dev/null | head -n 1 | grep -qF "v${NVIM_VERSION}"; then
    echo "Downloading Neovim v${NVIM_VERSION} (${NVIM_ASSET})..."
    cd /tmp
    # `curl -f` already fails on HTTP errors; make a 404 (missing release
    # asset for this version) a hard, clearly-labelled failure.
    if ! curl -fL "$NVIM_URL" -o "${NVIM_ASSET}.tar.gz"; then
        echo "ERROR: failed to download Neovim from:" >&2
        echo "  $NVIM_URL" >&2
        echo "The release asset may not exist (HTTP 404). Check NVIM_VERSION / asset name." >&2
        rm -f "${NVIM_ASSET}.tar.gz"
        exit 1
    fi

    rm -rf "/tmp/${NVIM_ASSET}"
    if ! tar -xzf "${NVIM_ASSET}.tar.gz"; then
        echo "ERROR: failed to extract ${NVIM_ASSET}.tar.gz." >&2
        rm -rf "/tmp/${NVIM_ASSET}" "${NVIM_ASSET}.tar.gz"
        exit 1
    fi

    rm -rf "$NVIM_DIR"
    mv "/tmp/${NVIM_ASSET}" "$NVIM_DIR"
    rm -f "${NVIM_ASSET}.tar.gz"

    if [ "$OS_KIND" = "macos" ]; then
        # Gatekeeper quarantine: clear the xattr so the binary runs without a prompt.
        xattr -dr com.apple.quarantine "$NVIM_DIR" 2>/dev/null || true
    fi

    ln -sf "$NVIM_DIR/bin/nvim" "$BIN/nvim"
fi

# Verify the installed binary matches the pinned version; fail otherwise.
INSTALLED_NVIM="$("$BIN/nvim" --version | head -n 1)"
echo "$INSTALLED_NVIM"
if ! echo "$INSTALLED_NVIM" | grep -qF "v${NVIM_VERSION}"; then
    echo "ERROR: expected Neovim v${NVIM_VERSION} but got: $INSTALLED_NVIM" >&2
    exit 1
fi

# Warn if another nvim earlier in PATH would shadow the one we just installed,
# typically a stale Homebrew or apt install of an older version (e.g. 0.10.x)
# which breaks plugins that require >= 0.11.
OTHER_NVIM="$(PATH="$(echo "$PATH" | sed -E "s|(^|:)$BIN(:|$)|\1|g")" command -v nvim 2>/dev/null || true)"
if [ -n "$OTHER_NVIM" ] && [ "$OTHER_NVIM" != "$BIN/nvim" ]; then
    echo ""
    echo "WARNING: another nvim is in PATH: $OTHER_NVIM"
    other_ver="$("$OTHER_NVIM" --version 2>/dev/null | head -n 1)"
    echo "    version: $other_ver"
    echo "    this may shadow $BIN/nvim depending on how PATH is loaded."
    case "$OTHER_NVIM" in
        /usr/local/bin/nvim|/opt/homebrew/bin/nvim)
            echo "    To remove the Homebrew copy: brew uninstall neovim"
            ;;
        /usr/bin/nvim)
            echo "    To remove the apt copy:      sudo apt remove neovim"
            ;;
    esac
    echo ""
fi

################################
# Node.js
################################

echo "Installing Node.js..."

NODE_VERSION="v22.16.0"
NODE_DIR="$PREFIX/nodejs"

if [ ! -f "$NODE_DIR/bin/node" ]; then
    cd /tmp
    NODE_PKG="node-${NODE_VERSION}-${NODE_ARCH}.tar.xz"
    curl -fLO "https://nodejs.org/dist/${NODE_VERSION}/${NODE_PKG}"
    tar -xf "$NODE_PKG"

    rm -rf "$NODE_DIR"
    mkdir -p "$NODE_DIR"
    mv "node-${NODE_VERSION}-${NODE_ARCH}"/* "$NODE_DIR/"
    rm -rf "node-${NODE_VERSION}-${NODE_ARCH}" "$NODE_PKG"
fi

ln -sf "$NODE_DIR/bin/node" "$BIN/node"
ln -sf "$NODE_DIR/bin/npm" "$BIN/npm"
ln -sf "$NODE_DIR/bin/npx" "$BIN/npx"

"$BIN/node" -v

################################
# ripgrep / fd (Telescope live_grep / find_files)
################################

echo "Installing ripgrep..."

RG_VERSION="14.1.1"

if [ ! -x "$BIN/rg" ]; then
    cd /tmp
    RG_DIR="ripgrep-${RG_VERSION}-${RG_TARGET}"
    RG_PKG="${RG_DIR}.tar.gz"
    curl -fLO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${RG_PKG}"
    rm -rf "$RG_DIR"
    tar -xzf "$RG_PKG"
    cp "$RG_DIR/rg" "$BIN/rg"
    chmod +x "$BIN/rg"
    rm -rf "$RG_DIR" "$RG_PKG"
fi

"$BIN/rg" --version | head -n 1

echo "Installing fd..."

FD_VERSION="v10.2.0"

if [ ! -x "$BIN/fd" ]; then
    cd /tmp
    FD_DIR="fd-${FD_VERSION}-${FD_TARGET}"
    FD_PKG="${FD_DIR}.tar.gz"
    curl -fLO "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/${FD_PKG}"
    rm -rf "$FD_DIR"
    tar -xzf "$FD_PKG"
    cp "$FD_DIR/fd" "$BIN/fd"
    chmod +x "$BIN/fd"
    rm -rf "$FD_DIR" "$FD_PKG"
fi

"$BIN/fd" --version | head -n 1

################################
# Deno
################################

echo "Installing Deno..."

if [ ! -x "$BIN/deno" ]; then
    # -y skips the installer's interactive shell-setup prompt (it would block
    # waiting on /dev/tty); --no-modify-path because PATH is handled above.
    curl -fsSL https://deno.land/install.sh | DENO_INSTALL="$PREFIX" sh -s -- -y --no-modify-path
fi

"$BIN/deno" --version | head -n 1

################################
# Go
################################

echo "Installing Go..."

GO_VERSION="1.22.3"

if [ ! -d "$PREFIX/go" ]; then
    cd /tmp
    GO_PKG="go${GO_VERSION}.${GO_ARCH}.tar.gz"
    curl -fLO "https://go.dev/dl/${GO_PKG}"
    tar -C "$PREFIX" -xzf "$GO_PKG"
    rm -f "$GO_PKG"
fi

"$PREFIX/go/bin/go" version

################################
# LSP servers & formatters (managed by Mason)
################################

# Language servers and formatters are NOT installed here anymore.
# They are installed automatically by mason.nvim + mason-tool-installer
# on the first Neovim launch (see ensure_installed in lua/plugins/lsp.lua):
#   clangd, lua-language-server, gopls, bash-language-server, vtsls, ruff,
#   json-lsp, yaml-language-server, lemminx,
#   stylua, shfmt, prettier, clang-format, cmakelang.
#
# This script only provides the runtimes Mason itself depends on, because
# Mason cannot install language runtimes (Neovim / Node / Go / Deno):
#   - Node.js : vtsls, bash-language-server, json-lsp, yaml-language-server, prettier
#   - Go      : gopls (Mason runs `go install`) and gofmt
#   - Python  : ruff, clang-format, cmakelang (pip-based Mason packages)
echo "LSP servers / formatters are handled by Mason on first Neovim launch."

################################
# Neovim config -> ~/.config/nvim
################################

# Copy this repository's Neovim configuration into place so it is usable
# immediately after the install. An existing config is moved aside first.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_CONFIG_BACKUP=""
CONFIG_ENTRIES="init.lua filetype.vim lazy-lock.json lua ftdetect syntax"

echo "Installing Neovim config to $NVIM_CONFIG..."

if [ -e "$NVIM_CONFIG" ] && [ "$(cd "$NVIM_CONFIG" 2>/dev/null && pwd -P)" = "$(cd "$REPO_DIR" && pwd -P)" ]; then
    # ~/.config/nvim *is* this repository (clone or symlink): nothing to copy.
    echo "$NVIM_CONFIG already points at this repository; skipping copy."
else
    if [ -e "$NVIM_CONFIG" ] || [ -L "$NVIM_CONFIG" ]; then
        NVIM_CONFIG_BACKUP="${NVIM_CONFIG}.bak.$(date +%Y%m%d-%H%M%S)"
        mv "$NVIM_CONFIG" "$NVIM_CONFIG_BACKUP"
        echo "Existing config moved to $NVIM_CONFIG_BACKUP"
    fi
    mkdir -p "$NVIM_CONFIG"
    for entry in $CONFIG_ENTRIES; do
        cp -R "$REPO_DIR/$entry" "$NVIM_CONFIG/"
    done
    echo "Copied: $CONFIG_ENTRIES"
fi

################################
# alias / sudo nvim -> sudoedit
################################

add_to_rc "alias vim='nvim'"

# `sudo nvim FILE` rewrites to `sudoedit FILE` with EDITOR pointing at the
# user-local nvim. sudoedit copies the file to a tmp path, opens it as the
# invoking user (so plugins/state stay under $HOME), and writes back via root.
# Other sudo invocations fall through to the real sudo.
add_block_to_rc '# >>> dotfiles: sudo nvim -> sudoedit >>>' <<'BLOCK'
sudo() {
    if [ "$1" = "nvim" ] || [ "$1" = "vim" ]; then
        shift
        EDITOR="$HOME/.local/bin/nvim" command sudoedit "$@"
    else
        command sudo "$@"
    fi
}
# <<< dotfiles: sudo nvim -> sudoedit <<<
BLOCK

################################
# finish
################################

echo ""
echo "Installation complete"
echo "Neovim config: $NVIM_CONFIG"
if [ -n "$NVIM_CONFIG_BACKUP" ]; then
    echo "Previous config backed up to: $NVIM_CONFIG_BACKUP"
fi
echo "Restart your shell or run:"
echo "  source $SHELL_RC"
echo ""
echo "Then launch Neovim once and let Mason finish installing the language"
echo "servers and formatters (run :Mason to check progress), and restart Neovim."
