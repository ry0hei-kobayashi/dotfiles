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

# (Re)download unless the installed binary already matches the pinned version.
if [ ! -x "$BIN/nvim" ] || ! "$BIN/nvim" --version 2>/dev/null | head -n 1 | grep -qF "v${NVIM_VERSION}"; then
    echo "Downloading Neovim v${NVIM_VERSION}..."
    curl -fL "$NVIM_URL" -o "$BIN/nvim"
    chmod +x "$BIN/nvim"
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
# LSP
################################

echo "Installing language servers..."

go install golang.org/x/tools/gopls@latest
npm install -g @vtsls/language-server

# clangd (C/C++ language server)
CLANGD_VERSION="22.1.0"
if [ ! -x "$BIN/clangd" ] || ! "$BIN/clangd" --version 2>/dev/null | grep -qF "$CLANGD_VERSION"; then
    cd /tmp
    curl -fL -o clangd.zip "https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/clangd-linux-${CLANGD_VERSION}.zip"
    rm -rf "$PREFIX/clangd"
    mkdir -p "$PREFIX/clangd"
    unzip -oq clangd.zip -d "$PREFIX/clangd"
    ln -sf "$PREFIX/clangd/clangd_${CLANGD_VERSION}/bin/clangd" "$BIN/clangd"
fi
"$BIN/clangd" --version | head -n 1

# lua-language-server
LUALS_VERSION="3.18.2"
if [ ! -x "$BIN/lua-language-server" ] || ! "$BIN/lua-language-server" --version 2>/dev/null | grep -qF "$LUALS_VERSION"; then
    cd /tmp
    curl -fL -o lua-ls.tar.gz "https://github.com/LuaLS/lua-language-server/releases/download/${LUALS_VERSION}/lua-language-server-${LUALS_VERSION}-linux-x64.tar.gz"
    rm -rf "$PREFIX/lua-language-server"
    mkdir -p "$PREFIX/lua-language-server"
    tar -xzf lua-ls.tar.gz -C "$PREFIX/lua-language-server"
    ln -sf "$PREFIX/lua-language-server/bin/lua-language-server" "$BIN/lua-language-server"
fi
"$BIN/lua-language-server" --version

################################
# Formatters
################################

echo "Installing formatters..."

pip install --user autopep8 isort ruff clang-format cmakelang --break-system-packages

# Node-based formatter / language server
npm install -g prettier bash-language-server

# Go-based formatter (shfmt). gofmt ships with the Go toolchain above.
go install mvdan.cc/sh/v3/cmd/shfmt@latest

################################
# stylua (Lua formatter)
################################

echo "Installing stylua..."

STYLUA_VERSION="2.5.2"
if [ ! -x "$BIN/stylua" ] || ! "$BIN/stylua" --version 2>/dev/null | grep -qF "$STYLUA_VERSION"; then
    cd /tmp
    curl -fL -o stylua.zip "https://github.com/JohnnyMorganz/StyLua/releases/download/v${STYLUA_VERSION}/stylua-linux-x86_64.zip"
    unzip -o stylua.zip stylua -d "$BIN"
    chmod +x "$BIN/stylua"
fi
"$BIN/stylua" --version

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
echo "source ~/.bashrc"
