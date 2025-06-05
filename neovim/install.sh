#!/bin/bash

#neovim-setup
mkdir -p ~/.local/bin
#curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
cp nvim.appimage ~/.local/bin/nvim
nvim --version

#nodejs
cd ~/.local/bin
VERSION="v22.16.0"
FILENAME="node-${VERSION}-linux-x64.tar.xz"
DIRNAME="node-${VERSION}-linux-x64"
cd ~
curl -LO "https://nodejs.org/dist/${VERSION}/${FILENAME}"
tar -xf "$FILENAME"
mkdir -p ~/.local/nodejs
mv "$DIRNAME"/* ~/.local/nodejs/
mkdir -p ~/.local/bin
ln -sf ~/.local/nodejs/bin/node ~/.local/bin/node
ln -sf ~/.local/nodejs/bin/npm ~/.local/bin/npm
ln -sf ~/.local/nodejs/bin/npx ~/.local/bin/npx
node -v

#deno setup
curl -fsSL https://deno.land/install.sh | DENO_INSTALL=$HOME/.local sh

#go setup
curl -LO https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
tar -C ~/.local -xzf go1.22.3.linux-amd64.tar.gz
export PATH="$HOME/.local/go/bin:$PATH"
GO111MODULE=on go install golang.org/x/tools/gopls@latest

# npm packages
npm install -g @vtsls/language-server

echo '' >> ~/.bashrc
echo 'alias vim='nvim'' >> ~/.bashrc
echo 'export PATH="$HOME/.local/go/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

source ~/.bashrc
