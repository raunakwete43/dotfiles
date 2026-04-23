return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "mason-org/mason.nvim",
      ---@module 'mason.settings'
      ---@type MasonSettings
      ---@diagnostic disable-next-line: missing-fields
      opts = {},
    },
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    { "folke/neodev.nvim", opts = {} },
  },
  event = "BufReadPre",
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end
        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
        -- map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

        -- map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/documentHighlight", event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
            end,
          })
        end

        if client and client:supports_method("textDocument/inlayHint", event.buf) then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    require("configs.lspconfig").defaults()

    local lspconfig = require "lspconfig"

    -- EXAMPLE
    local nvlsp = require "configs.lspconfig"

    require("mason").setup()

    ---@type table<string, vim.lsp.Config>
    local servers = {
      clangd = {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
        settings = {
          clangd = {
            InlayHints = {
              Designators = true,
              Enabled = true,
              ParameterNames = true,
              DeducedTypes = true,
            },
            fallbackFlags = { "-std=c++20" },
          },
        },
      },

      rust_analyzer = {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = true,
            cargo = {
              allFeatures = true,
            },
            procMacro = {
              enable = true,
            },
          },
        },
      },

      gopls = {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
        settings = {
          gopls = {
            hints = {
              rangeVariableTypes = true,
              parameterNames = true,
              constantValues = true,
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              functionTypeParameters = true,
            },
          },
        },
      },

      basedpyright = {
        on_attach = function(client, bufnr)
          -- client.handlers["textDocument/publishDiagnostics"] = function(...) end
          nvlsp.on_attach(client, bufnr)
        end,
        capabilities = nvlsp.capabilities,
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      },
      tailwindcss = {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
        workspace_required = false,
      },

      ruff = {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
        filetypes = { "python" },
        trace = "messages",
        init_options = {
          settings = {
            logLevel = "debug",
            lint = {
              args = {
                "--select=ARG,F,E,I001",
                "--line-length=88",
              },
            },
          },
        },
      },

      vtsls = {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
        root_dir = lspconfig.util.root_pattern "package.json",
        single_file_support = true,
        settings = {
          javascript = {
            inlayHints = {
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },

          typescript = {
            inlayHints = {
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
        },
      },

      --      ansiblels = {
      --        on_attach = nvlsp.on_attach,
      --        capabilities = nvlsp.capabilities,
      --        filetypes = { "yaml.ansible", "yaml.ansible.j2" },
      --      },

      marksman = {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
        filetypes = { "markdown", "mdx", "md" },
      },
    }

    -- lsps with default config
    -- for _, lsp in ipairs(servers) do
    --   lspconfig[lsp].setup {
    --     on_attach = nvlsp.on_attach,
    --     on_init = nvlsp.on_init,
    --     capabilities = nvlsp.capabilities,
    --   }
    -- end

    -- require("mason-lspconfig").setup {
    --   automatic_enable = false,
    --   ensure_installed = servers,
    --   handlers = {
    --     function(server_name)
    --       require("lspconfig")[server_name].setup {
    --         on_attach = nvlsp.on_attach,
    --         on_init = nvlsp.on_init,
    --         capabilities = nvlsp.capabilities,
    --       }
    --     end,
    --   },
    -- }

    -- require("mason-lspconfig").setup {
    --   ensure_installed = servers,
    --   automatic_enable = true,
    -- }

    -- lspconfig.pyright.setup {
    --   settings = {
    --     pyright = {
    --       disableOrganizeImports = true,
    --     },
    --     python = {
    --       analysis = {
    --         ignore = { "*" },
    --       },
    --     },
    --   },
    -- }

    require("mason-tool-installer").setup { ensure_installed = vim.tbl_keys(servers) }

    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end,
}
