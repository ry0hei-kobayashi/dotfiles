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

if [ ! -f "$BIN/nvim" ]; then
    cp nvim.appimage "$BIN/nvim"
    chmod +x "$BIN/nvim"
fi

"$BIN/nvim" --version | head -n 1

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

################################
# Python formatters
################################

echo "Installing python formatters..."

pip install --user autopep8 isort --break-system-packages

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
