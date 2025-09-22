return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    { "folke/neodev.nvim", opts = {} },
  },
  event = "BufReadPre",
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight",
            { clear = false })
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
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach",
              { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
            end,
          })
        end
      end,
    })

    require("configs.lspconfig").defaults()

    local lspconfig = require "lspconfig"

    -- EXAMPLE
    local servers = { "clangd", "lua_ls", "ruff", "pyright", "gopls", "rust_analyzer" }
    local nvlsp = require "configs.lspconfig"

    require("mason").setup()
    require("mason-tool-installer").setup { ensure_installed = servers }
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


    lspconfig.clangd.setup {
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
      }
    }

    lspconfig.rust_analyzer.setup {
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
    }

    lspconfig.gopls.setup {
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
        }
      }
    }


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

    lspconfig.basedpyright.setup({
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
            typeCheckingMode = "basic"
          }
        }
      }
    })

    lspconfig.tailwindcss.setup {
      on_attach = nvlsp.on_attach,
      capabilities = nvlsp.capabilities,
      workspace_required = false,
    }

    lspconfig.ruff.setup {
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
    }


    lspconfig.vtsls.setup {
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
    }


    lspconfig.ansiblels.setup {
      on_attach = nvlsp.on_attach,
      capabilities = nvlsp.capabilities,
      filetypes = { "yaml.ansible", "yaml.ansible.j2" },
    }

    lspconfig.marksman.setup {
      on_attach = nvlsp.on_attach,
      capabilities = nvlsp.capabilities,
      filetypes = { "markdown", "mdx", "md" },
    }
  end,
}
