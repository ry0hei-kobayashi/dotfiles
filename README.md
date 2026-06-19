# Neovim config for ROS + AI

## Directory layout

- `init.lua`
- `lua/config/*.lua`: basic editor settings
- `lua/plugins/*.lua`: plugin definitions split by role

## Included features

- LSP: `clangd`, `ruff`, `lua_ls`, `bashls`, `gopls`, `vtsls`
- Markdown preview: `iamcco/markdown-preview.nvim`
- Terminal: `akinsho/toggleterm.nvim`
- File tree: `preservim/nerdtree`
- ROS support: `taDachs/ros-nvim`
- AI: `zbirenbaum/copilot.lua`, `CopilotC-Nvim/CopilotChat.nvim`, `jackMort/ChatGPT.nvim`

## Installation

`assets/install.sh` installs everything under `$HOME/.local` (no root required).
It provides only the language runtimes — Neovim, Node.js, Go, Deno — because
Mason cannot install those itself.

```bash
bash assets/install.sh
source ~/.bashrc
```

Language servers and formatters (`clangd`, `lua-language-server`, `gopls`,
`bash-language-server`, `vtsls`, `ruff`, `stylua`, `shfmt`, `prettier`,
`clang-format`, `cmakelang`) are installed automatically by
`mason.nvim` + `mason-tool-installer` on the first Neovim launch.

After running the script:

1. Launch Neovim. Mason starts downloading the tools in the background.
2. Run `:Mason` to watch progress until all tools are installed.
3. Restart Neovim.

### Prerequisites (must already be present)

`curl`, `tar`, `unzip`, `git`, `python3` / `pip`, and a C/C++ toolchain
(`build-essential`, `cmake`) for ROS C++ work. On Ubuntu:

```bash
sudo apt install -y git curl unzip ripgrep fd-find build-essential cmake python3-pip
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

Leader is `<Space>`.

General / windows:

- `<leader>w` / `<leader>q`: save / quit
- `<C-h/j/k/l>`: move between windows
- `<Esc>`: clear search highlight

Files (Telescope):

- `<leader>ff` / `<leader>fg` / `<leader>fb`: find files / live grep / buffers
- `<leader>fh` / `<leader>fw` / `<leader>fr` / `<leader>fo`: help / grep word / resume / oldfiles

LSP (lspsaga):

- `gd` / `gD`: peek / goto definition
- `gt` / `gT`: peek / goto type definition
- `K`: hover doc
- `gj` / `gk`: next / prev diagnostic jump
- `[d` / `]d`: prev / next diagnostic
- `<leader>e`: show line diagnostics (float)
- `<leader>rn`: rename
- `<leader>f`: format (conform)

Other:

- `<C-n>`: toggle NERDTree
- `<C-t>`: toggle terminal (toggleterm); `<Esc>` leaves terminal mode
- `<leader>mp` / `<leader>ms`: markdown preview toggle / stop

## Setup

Place this directory at `~/.config/nvim`, then start Neovim. `lazy.nvim`
bootstraps itself and installs the plugins; Mason installs the language
servers and formatters (see [Installation](#installation)).

Install Treesitter parsers if needed:

```vim
:TSInstall cpp python lua markdown yaml json
```
