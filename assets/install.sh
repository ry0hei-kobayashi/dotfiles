#!/usr/bin/env bash
set -e

echo "==== Neovim development environment installer ===="

PREFIX="$HOME/.local"
BIN="$PREFIX/bin"

mkdir -p "$BIN"
mkdir -p "$PREFIX/nodejs"

################################
# PATH setup
################################

add_to_bashrc() {
    if ! grep -q "$1" "$HOME/.bashrc"; then
        echo "$1" >> "$HOME/.bashrc"
    fi
}

add_to_bashrc 'export PATH="$HOME/.local/bin:$PATH"'
add_to_bashrc 'export PATH="$HOME/.local/go/bin:$PATH"'
add_to_bashrc 'export PATH="$HOME/go/bin:$PATH"'

################################
# Neovim
################################

echo "Installing Neovim..."

# Pinned Neovim version. Change this single value to switch versions;
# the matching release is fetched from GitHub.
NVIM_VERSION="0.12.0"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.appimage"

# The AppImage is *extracted* (not run directly) so it needs no FUSE/libfuse2,
# which keeps it working on root-less hosts / containers. The extracted tree
# lives here and $BIN/nvim is a symlink to its AppRun launcher.
NVIM_DIR="$PREFIX/nvim"

# (Re)install unless the installed binary already matches the pinned version.
if [ ! -x "$BIN/nvim" ] || ! "$BIN/nvim" --version 2>/dev/null | head -n 1 | grep -qF "v${NVIM_VERSION}"; then
    echo "Downloading Neovim v${NVIM_VERSION}..."
    cd /tmp
    # `curl -f` already fails on HTTP errors; make a 404 (missing release
    # asset for this version) a hard, clearly-labelled failure.
    if ! curl -fL "$NVIM_URL" -o nvim.appimage; then
        echo "ERROR: failed to download Neovim from:" >&2
        echo "  $NVIM_URL" >&2
        echo "The release asset may not exist (HTTP 404). Check NVIM_VERSION / asset name." >&2
        rm -f nvim.appimage
        exit 1
    fi
    chmod +x nvim.appimage

    # --appimage-extract does NOT mount anything, so it works without FUSE.
    echo "Extracting Neovim AppImage (no FUSE required)..."
    rm -rf squashfs-root
    if ! ./nvim.appimage --appimage-extract >/dev/null; then
        echo "ERROR: failed to extract the Neovim AppImage." >&2
        rm -rf squashfs-root nvim.appimage
        exit 1
    fi

    rm -rf "$NVIM_DIR"
    mv squashfs-root "$NVIM_DIR"
    rm -f nvim.appimage
    ln -sf "$NVIM_DIR/AppRun" "$BIN/nvim"
fi

# Verify the installed binary matches the pinned version; fail otherwise.
INSTALLED_NVIM="$("$BIN/nvim" --version | head -n 1)"
echo "$INSTALLED_NVIM"
if ! echo "$INSTALLED_NVIM" | grep -qF "v${NVIM_VERSION}"; then
    echo "ERROR: expected Neovim v${NVIM_VERSION} but got: $INSTALLED_NVIM" >&2
    exit 1
fi

################################
# Node.js
################################

echo "Installing Node.js..."

NODE_VERSION="v22.16.0"
NODE_DIR="$PREFIX/nodejs"

if [ ! -f "$NODE_DIR/bin/node" ]; then
    cd /tmp
    curl -LO "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz"
    tar -xf "node-${NODE_VERSION}-linux-x64.tar.xz"

    rm -rf "$NODE_DIR"
    mkdir -p "$NODE_DIR"
    mv "node-${NODE_VERSION}-linux-x64"/* "$NODE_DIR/"
fi

ln -sf "$NODE_DIR/bin/node" "$BIN/node"
ln -sf "$NODE_DIR/bin/npm" "$BIN/npm"
ln -sf "$NODE_DIR/bin/npx" "$BIN/npx"

node -v

################################
# Deno
################################

echo "Installing Deno..."

if [ ! -f "$HOME/.local/bin/deno" ]; then
    curl -fsSL https://deno.land/install.sh | DENO_INSTALL="$PREFIX" sh
fi

################################
# Go
################################

echo "Installing Go..."

GO_VERSION="1.22.3"

if [ ! -d "$PREFIX/go" ]; then
    cd /tmp
    curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    tar -C "$PREFIX" -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
fi

export PATH="$PREFIX/go/bin:$PATH"

go version

################################
# LSP servers & formatters (managed by Mason)
################################

# Language servers and formatters are NOT installed here anymore.
# They are installed automatically by mason.nvim + mason-tool-installer
# on the first Neovim launch (see ensure_installed in lua/plugins/lsp.lua):
#   clangd, lua-language-server, gopls, bash-language-server, vtsls, ruff,
#   stylua, shfmt, prettier, clang-format, cmakelang.
#
# This script only provides the runtimes Mason itself depends on, because
# Mason cannot install language runtimes (Neovim / Node / Go / Deno):
#   - Node.js : vtsls, bash-language-server, prettier
#   - Go      : gopls (Mason runs `go install`) and gofmt
#   - Python  : ruff, clang-format, cmakelang (pip-based Mason packages)
echo "LSP servers / formatters are handled by Mason on first Neovim launch."

################################
# alias
################################

add_to_bashrc "alias vim='nvim'"

################################
# finish
################################

echo ""
echo "Installation complete"
echo "Restart your shell or run:"
echo "  source ~/.bashrc"
echo ""
echo "Then launch Neovim once and let Mason finish installing the language"
echo "servers and formatters (run :Mason to check progress), and restart Neovim."
