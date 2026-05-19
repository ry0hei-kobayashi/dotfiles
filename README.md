# Neovim config for ROS + AI

## Directory layout

- `init.lua`
- `lua/config/*.lua`: basic editor settings
- `lua/plugins/*.lua`: plugin definitions split by role

## Included features

- LSP: `clangd`, `pyright`, `lua_ls`, `bashls`, `cmake`, `jsonls`, `yamlls`, `lemminx`
- Markdown preview: `iamcco/markdown-preview.nvim`
- Terminal: `akinsho/toggleterm.nvim`
- File tree: `preservim/nerdtree`
- ROS support: `taDachs/ros-nvim`
- AI: `zbirenbaum/copilot.lua`, `CopilotC-Nvim/CopilotChat.nvim`, `jackMort/ChatGPT.nvim`

## Prerequisites

The bundled `assets/install.sh` handles Neovim, Node, Go, Deno, ripgrep, fd, gopls, vtsls, Mason LSPs (lua-language-server, bash-language-server, lemminx) and Python formatters — all under `$HOME/.local`, no sudo required.

You only need to ensure the **host C compiler and Python 3** are available before running it:

### Ubuntu (root available)

```bash
sudo apt update
sudo apt install -y git curl build-essential python3 python3-pip
# Optional: clangd/clang-format for C/C++ (Mason can also install clangd).
sudo apt install -y clangd clang-format
```

### Ubuntu / HPC (no root)

Use the cluster's module system:

```bash
module load gcc python
# or whatever your site provides
```

### macOS

```bash
xcode-select --install   # C/C++ toolchain (clang, clang-format)
```

## ROS notes

This config is designed for ROS 1 / ROS 2 editing:

- `package.xml`, `*.launch`, `*.launch.xml`, `*.xacro` are treated as XML.
- `*.msg`, `*.srv`, `*.action` are treated as ROS definitions.
- `ros-nvim` adds ROS-specific commands and Telescope integration.
- For best C++ completion in catkin/colcon workspaces, generate `compile_commands.json`.

### catkin example

```bash
catkin config --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
catkin build
```

### colcon example

```bash
colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

If `compile_commands.json` is generated under `build/`, create a symlink in the package or workspace root if needed.

## AI setup

### GitHub Copilot

Inside Neovim:

```vim
:Copilot auth
```

`copilot.lua` recommends Neovim 0.11+ and Node.js v22+ when using the default Node-based LSP backend.

### Copilot Chat

Enable Copilot Chat in your GitHub Copilot settings first.

### ChatGPT.nvim

Set your OpenAI API key before starting Neovim:

```bash
export OPENAI_API_KEY="your_api_key_here"
```

Add it to `~/.bashrc` or `~/.zshrc` if you want it persistent.

## Keymaps

- `<leader>e`: toggle NERDTree
- `<leader>nf`: locate current file in NERDTree
- `<leader>tt`: toggle terminal
- `<leader>tf`: floating terminal
- `<leader>mp`: markdown preview toggle
- `gd`, `gr`, `K`: LSP navigation / hover
- `<leader>rn`: rename
- `<leader>ca`: code action
- `<leader>lf`: format
- `<leader>tr`: ROS Telescope finder
- `<leader>rol`: open included ROS launch file
- `<leader>rdi`: show ROS interface definition
- `<leader>aa`: open ChatGPT.nvim
- `<leader>ac`: toggle Copilot Chat
- `<leader>ap`: open Copilot panel

## Install

Copy the directory to:

```bash
~/.config/nvim
```

### Bundled installer

`assets/install.sh` provisions Neovim, Node.js, Go, Deno, ripgrep, fd, gopls, vtsls, and Python formatters under `$HOME/.local`. It auto-detects Linux/macOS and arch (x86_64 / arm64):

```bash
cd assets
./install.sh
```

Everything is installed under `$HOME/.local` (no root / sudo required) — suitable for HPC and shared-machine setups. Neovim is fetched as a tarball from the official GitHub release (no AppImage / FUSE dependency). PATH / alias lines are appended to `~/.bashrc` on Linux and `~/.zshrc` on macOS.

The installer also drops a shell function so that `sudo nvim FILE` transparently rewrites to `sudoedit FILE` (with `EDITOR=~/.local/bin/nvim`). This lets you edit root-owned files using your user-level Neovim install — the file is opened as your user (config / plugins / undo state stay under `$HOME`) and only the write back to disk goes through root.

Prerequisites the installer does **not** install (it warns if they are missing):

- `cc` (C compiler) — needed for Treesitter parser compilation and CopilotChat's tiktoken build.
- `python3` + `pip3` — needed for installing ruff / isort / autopep8.

On Ubuntu: `sudo apt install build-essential python3 python3-pip`.
On HPC: `module load gcc python` (or equivalent).
On macOS: `xcode-select --install`.

### Plugin / parser setup

Then start Neovim and run:

```vim
:Lazy sync
:Mason
```

Install Treesitter parsers if needed:

```vim
:TSInstall cpp python lua markdown yaml json xml ros
```

