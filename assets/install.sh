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
                NODE_ARCH="linux-x64"
                GO_ARCH="linux-amd64"
                RG_TARGET="x86_64-unknown-linux-musl"
                FD_TARGET="x86_64-unknown-linux-musl"
                ;;
            aarch64|arm64)
                NODE_ARCH="linux-arm64"
                GO_ARCH="linux-arm64"
                RG_TARGET="aarch64-unknown-linux-gnu"
                FD_TARGET="aarch64-unknown-linux-gnu"
                ;;
            *) echo "Unsupported Linux arch: $ARCH_NAME"; exit 1 ;;
        esac
        ;;
    Darwin)
        OS_KIND="macos"
        case "$ARCH_NAME" in
            x86_64)
                NODE_ARCH="darwin-x64"
                GO_ARCH="darwin-amd64"
                RG_TARGET="x86_64-apple-darwin"
                FD_TARGET="x86_64-apple-darwin"
                ;;
            arm64)
                NODE_ARCH="darwin-arm64"
                GO_ARCH="darwin-arm64"
                RG_TARGET="aarch64-apple-darwin"
                FD_TARGET="aarch64-apple-darwin"
                ;;
            *) echo "Unsupported macOS arch: $ARCH_NAME"; exit 1 ;;
        esac
        ;;
    *)
        echo "Unsupported OS: $OS_NAME"
        exit 1
        ;;
esac

echo "Detected OS: $OS_KIND / arch: $ARCH_NAME"

################################
# Toolchain sanity check (non-fatal)
################################
#
# Native builds during this install (treesitter parsers, tiktoken for
# CopilotChat) need a C compiler and python3. The installer itself does not
# attempt to install these — on HPC and other non-root environments, users
# usually obtain them via `module load` or apt/yum done by an admin.

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
    echo "  Continuing anyway — some build steps below may fail."
    echo ""
fi

################################
# Shell rc selection
################################

if [ "$OS_KIND" = "macos" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

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

export PATH="$HOME/.local/bin:$HOME/.local/go/bin:$HOME/go/bin:$PATH"

################################
# Neovim
################################

echo "Installing Neovim..."

NVIM_VERSION="v0.12.0"

# Download the pinned tarball from GitHub releases for both Linux and macOS.
# This avoids the AppImage's libfuse2 dependency on Linux (important for
# non-root / HPC environments) and gives arm64 support on both platforms.
case "${OS_KIND}-${ARCH_NAME}" in
    linux-x86_64)         NVIM_ASSET="nvim-linux-x86_64" ;;
    linux-aarch64|linux-arm64) NVIM_ASSET="nvim-linux-arm64" ;;
    macos-arm64)          NVIM_ASSET="nvim-macos-arm64" ;;
    macos-x86_64)         NVIM_ASSET="nvim-macos-x86_64" ;;
    *) echo "Unsupported OS/arch for Neovim: ${OS_KIND}-${ARCH_NAME}"; exit 1 ;;
esac

NVIM_DIR="$PREFIX/nvim-${NVIM_VERSION}"
if [ ! -x "$NVIM_DIR/bin/nvim" ]; then
    cd /tmp
    curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ASSET}.tar.gz"
    rm -rf "/tmp/${NVIM_ASSET}"
    tar -xzf "${NVIM_ASSET}.tar.gz"
    rm -rf "$NVIM_DIR"
    mv "${NVIM_ASSET}" "$NVIM_DIR"
    if [ "$OS_KIND" = "macos" ]; then
        # Gatekeeper quarantine — clear xattr so the binary runs without prompt.
        xattr -dr com.apple.quarantine "$NVIM_DIR" 2>/dev/null || true
    fi
fi
ln -sf "$NVIM_DIR/bin/nvim" "$BIN/nvim"

"$BIN/nvim" --version | head -n 1

# Warn if another nvim earlier in PATH would shadow the one we just installed —
# typically a stale Homebrew or apt install of an older version (e.g. 0.10.x)
# which breaks plugins that require >= 0.11 like telescope.nvim.
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
    curl -LO "https://nodejs.org/dist/${NODE_VERSION}/${NODE_PKG}"
    tar -xf "$NODE_PKG"

    rm -rf "$NODE_DIR"
    mkdir -p "$NODE_DIR"
    mv "node-${NODE_VERSION}-${NODE_ARCH}"/* "$NODE_DIR/"
fi

ln -sf "$NODE_DIR/bin/node" "$BIN/node"
ln -sf "$NODE_DIR/bin/npm" "$BIN/npm"
ln -sf "$NODE_DIR/bin/npx" "$BIN/npx"

"$BIN/node" -v

################################
# ripgrep
################################

echo "Installing ripgrep..."

RG_VERSION="14.1.1"

if [ ! -x "$BIN/rg" ]; then
    cd /tmp
    RG_DIR="ripgrep-${RG_VERSION}-${RG_TARGET}"
    RG_PKG="${RG_DIR}.tar.gz"
    curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${RG_PKG}"
    rm -rf "$RG_DIR"
    tar -xzf "$RG_PKG"
    cp "$RG_DIR/rg" "$BIN/rg"
    chmod +x "$BIN/rg"
fi

"$BIN/rg" --version | head -n 1

################################
# fd
################################

echo "Installing fd..."

FD_VERSION="v10.2.0"

if [ ! -x "$BIN/fd" ]; then
    cd /tmp
    FD_DIR="fd-${FD_VERSION}-${FD_TARGET}"
    FD_PKG="${FD_DIR}.tar.gz"
    curl -LO "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/${FD_PKG}"
    rm -rf "$FD_DIR"
    tar -xzf "$FD_PKG"
    cp "$FD_DIR/fd" "$BIN/fd"
    chmod +x "$BIN/fd"
fi

"$BIN/fd" --version | head -n 1

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
    GO_PKG="go${GO_VERSION}.${GO_ARCH}.tar.gz"
    curl -LO "https://go.dev/dl/${GO_PKG}"
    tar -C "$PREFIX" -xzf "$GO_PKG"
fi

export PATH="$PREFIX/go/bin:$PATH"

go version

################################
# LSP
################################

echo "Installing language servers..."

go install golang.org/x/tools/gopls@latest
"$BIN/npm" install -g @vtsls/language-server

################################
# Python formatters
################################

echo "Installing python formatters..."

PIP_BIN=""
if command -v pip3 >/dev/null 2>&1; then
    PIP_BIN="pip3"
elif command -v pip >/dev/null 2>&1; then
    PIP_BIN="pip"
fi

if [ -n "$PIP_BIN" ]; then
    if [ "$OS_KIND" = "macos" ] && command -v pipx >/dev/null 2>&1; then
        pipx install autopep8 || true
        pipx install isort || true
        pipx install ruff || true
    else
        # Both Homebrew-managed macOS Python and recent Debian/Ubuntu enforce
        # PEP 668 — install with --user --break-system-packages.
        "$PIP_BIN" install --user --break-system-packages autopep8 isort ruff || \
            "$PIP_BIN" install --user autopep8 isort ruff
    fi

    # Ensure the user-site bin dir is on PATH (macOS: ~/Library/Python/X.Y/bin).
    PY_USER_BIN="$(python3 -c 'import site,sys; print(site.getuserbase()+"/bin")' 2>/dev/null || echo "")"
    if [ -n "$PY_USER_BIN" ]; then
        add_to_rc "export PATH=\"$PY_USER_BIN:\$PATH\""
        export PATH="$PY_USER_BIN:$PATH"
    fi
else
    echo "pip not found; skipping python formatter install."
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
# nvim: plugins + Mason LSPs
################################

if [ -d "$HOME/.config/nvim" ]; then
    echo "Syncing Lazy plugins and Mason language servers..."
    # Lazy! sync installs all plugins; MasonInstall pulls language servers that
    # are not provided by the system (lua_ls, bashls, lemminx).
    "$BIN/nvim" --headless \
        "+Lazy! sync" \
        "+sleep 2" \
        "+MasonInstall lua-language-server bash-language-server lemminx" \
        "+sleep 2" \
        "+qa!" 2>&1 | tail -n 20 || true
else
    echo "~/.config/nvim not found; skipping plugin/Mason setup."
    echo "Copy or symlink this repo to ~/.config/nvim and re-run, or run :Lazy + :Mason manually."
fi

################################
# finish
################################

echo ""
echo "Installation complete"
echo "Restart your shell or run:"
echo "source $SHELL_RC"
