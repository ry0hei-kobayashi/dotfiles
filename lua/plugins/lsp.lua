return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, {
            buffer = bufnr,
            silent = true,
            noremap = true,
            desc = desc,
          })
        end

        -- 最低限だけ残す
        map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        map("]d", vim.diagnostic.goto_next, "Next diagnostic")

        map("<leader>e", function()
          vim.diagnostic.open_float(0, {
            focus = false,
            scope = "line",
            border = "rounded",
            source = "if_many",
            close_events = {
              "BufLeave",
              "CursorMoved",
              "InsertEnter",
              "FocusLost",
            },
          })
        end, "Line diagnostics")         

      end

      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })

      vim.lsp.config("*", {
        capabilities = capabilities,
        root_markers = { ".git" },
      })

      vim.lsp.config("clangd", {
        on_attach = on_attach,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
          "--limit-references=0",
        },
        root_markers = {
          ".clangd",
          "compile_commands.json",
          "compile_flags.txt",
          "package.xml",
          "colcon.pkg",
          ".git",
        },
      })

      vim.lsp.config("ruff", {
        on_attach = on_attach,
        cmd = { "ruff", "server" },
        filetypes = { "python" },
        root_markers = {
          "pyproject.toml",
          "ruff.toml",
          ".ruff.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "package.xml",
          ".git",
        },
        init_options = {
          settings = {
            configuration = {
              preview = true,
              ["line-length"] = 100,
      
              lint = {
                select = {
                  "E",
                  "W",
                  "F",
                  "I",
                  "D",
                },
                ignore = {
                  "E203",
                  "D100",
                  "D103",
                  "D105",
                  "D107",
                  "D203",
                  "D212",
                  "D401",
                },
                pydocstyle = {
                  convention = "google",
                },
              },
      
              format = {
                ["quote-style"] = "single",
                ["indent-style"] = "space",
                ["line-ending"] = "auto",
              },
            },
          },
        },
      })

      -- vim.lsp.config("pyright", {
      --   on_attach = on_attach,
      --   root_markers = {
      --     "pyproject.toml",
      --     "setup.py",
      --     "setup.cfg",
      --     "requirements.txt",
      --     ".git",
      --   },
      -- })

      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
          },
        },
        root_markers = {
          ".luarc.json",
          ".luarc.jsonc",
          ".git",
        },
      })

      vim.lsp.config("bashls", {
        on_attach = on_attach,
        filetypes = { "sh", "bash", "zsh", "def" },
        root_markers = {
          ".git",
          ".bashrc",
          ".bash_profile",
        },
      })

      vim.lsp.config("gopls", {
        on_attach = on_attach,
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = {
          "go.work",
          "go.mod",
          ".git",
        },
      })

      vim.lsp.config("vtsls", {
        on_attach = on_attach,
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        root_markers = {
          "tsconfig.json",
          "package.json",
          "jsconfig.json",
          ".git",
        },
      })

      vim.lsp.enable("clangd")
      vim.lsp.enable("ruff")
      -- vim.lsp.enable("pyright")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("vtsls")
    end,
  },
}
