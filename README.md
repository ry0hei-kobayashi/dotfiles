# Neovim config for ROS + AI

## Directory layout

- `init.lua`
- `lua/config/*.lua`: basic editor settings
- `lua/plugins/*.lua`: plugin definitions split by role

## Included features

- LSP: `clangd`, `ruff`, `lua_ls`, `bashls`, `gopls`, `vtsls`, `jsonls`, `yamlls`, `lemminx`
- Markdown preview: `iamcco/markdown-preview.nvim`
- Terminal: `akinsho/toggleterm.nvim`
- File tree: `preservim/nerdtree`
- ROS support: `taDachs/ros-nvim`
- AI: `zbirenbaum/copilot.lua`, `CopilotC-Nvim/CopilotChat.nvim`, `jackMort/ChatGPT.nvim`

## Installation

`assets/install.sh` installs everything under `$HOME/.local` (no root required),
so it also suits HPC and shared-machine setups. It auto-detects the platform
(Linux / macOS, x86_64 / arm64) and provides:

- the language runtimes Mason cannot install itself: Neovim (pinned, fetched as
  the official release tarball, no AppImage / FUSE dependency), Node.js, Go, Deno
- `ripgrep` and `fd` for Telescope

It then copies this repository's config (`init.lua`, `lua/`, `ftdetect/`,
`syntax/`, `filetype.vim`, `lazy-lock.json`) into `~/.config/nvim` (or
`$XDG_CONFIG_HOME/nvim`). An existing config is moved to
`~/.config/nvim.bak.<timestamp>` first; if `~/.config/nvim` already *is* this
repository (a clone or symlink), the copy is skipped.

```bash
bash assets/install.sh
source ~/.bashrc   # or ~/.zshrc if your login shell is zsh
```

PATH / alias lines are appended to the rc file of your login shell
(`~/.zshrc` for zsh, `~/.bashrc` otherwise). The installer also drops a shell
function so that `sudo nvim FILE` transparently rewrites to `sudoedit FILE`
(with `EDITOR=~/.local/bin/nvim`): the file is opened as your user (config /
plugins / undo state stay under `$HOME`) and only the write back goes through root.

Language servers and formatters (`clangd`, `lua-language-server`, `gopls`,
`bash-language-server`, `vtsls`, `ruff`, `json-lsp`, `yaml-language-server`,
`lemminx`, `stylua`, `shfmt`, `prettier`, `clang-format`, `cmakelang`) are
installed automatically by `mason.nvim` + `mason-tool-installer` on the first
Neovim launch.

After running the script:

1. Launch Neovim. Mason starts downloading the tools in the background.
2. Run `:Mason` to watch progress until all tools are installed.
3. Restart Neovim.

### Prerequisites (must already be present)

`curl`, `tar`, `unzip`, `git`, `python3` / `pip`, and a C compiler. The C
compiler is needed for Treesitter parser compilation and CopilotChat's tiktoken
build; `python3` / `pip` for the pip-based Mason packages (`ruff`,
`clang-format`, `cmakelang`). The installer warns if `cc` or `python3` is
missing but continues.

#### Ubuntu (root available)

```bash
sudo apt update
sudo apt install -y git curl unzip build-essential cmake python3 python3-pip
```

#### Ubuntu / HPC (no root)

Use the cluster's module system:

```bash
module load gcc python
# or whatever your site provides
```

#### macOS

```bash
xcode-select --install   # C/C++ toolchain (clang, clang-format)
```

If a Homebrew Neovim is also installed, the installer warns that it may shadow
`~/.local/bin/nvim`; remove it with `brew uninstall neovim` or make sure
`~/.local/bin` comes first in `PATH`.

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

`assets/install.sh` copies this directory to `~/.config/nvim` (you can also
clone or symlink it there by hand). Then start Neovim. `lazy.nvim`
bootstraps itself and installs the plugins; Mason installs the language
servers and formatters (see [Installation](#installation)).

Install Treesitter parsers if needed:

```vim
:TSInstall cpp python lua markdown yaml json
```
