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

## Recommended system packages

Ubuntu example:

```bash
sudo apt update
sudo apt install -y neovim git curl ripgrep fd-find build-essential cmake npm python3-pip luarocks
```

For language servers / tools:

```bash
npm install -g pyright bash-language-server vscode-langservers-extracted @olrtg/emmet-language-server
pip install pynvim
```

For C/C++:

```bash
sudo apt install -y clangd clang-format
```

For XML:
- install `lemminx` via `:Mason`

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

Then start Neovim and run:

```vim
:Lazy sync
:Mason
```

Install Treesitter parsers if needed:

```vim
:TSInstall cpp python lua markdown yaml json xml ros
```
