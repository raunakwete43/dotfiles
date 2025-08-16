local M = {}
local map = vim.keymap.set
local _, fzf = pcall(require, "fzf-lua")

-- export on_attach & capabilities
M.on_attach = function(client, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  -- map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  -- map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  -- map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
  map("n", "gD", fzf.lsp_declarations, opts "Go to declaration")
  map("n", "gd", fzf.lsp_definitions, opts "Go to definition")
  map("n", "gi", fzf.lsp_implementations, opts "Go to implementation")
  map("n", "<leader>sh", vim.lsp.buf.signature_help, opts "Show signature help")
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts "List workspace folders")

  -- map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
  map("n", "<leader>D", fzf.lsp_typedefs, opts "Go to type definition")
  map("n", "<leader>rn", require "nvchad.lsp.renamer", opts "NvRenamer")

  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
  -- map("n", "gr", vim.lsp.buf.references, opts "Show references")
  map("n", "gr", fzf.lsp_references, opts "Show references")
  -- map("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts "[D]ocument [S]ymbols")
  map("n", "<leader>ds", fzf.lsp_document_symbols, opts "[D]ocument [S]ymbols")
  map("n", "<leader>ws", fzf.lsp_workspace_symbols, opts "[D]ocument [S]ymbols")

  if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    map("n", "<leader>th", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, opts "[T]oggle Inlay [H]ints")
  end
end

-- disable semanticTokens
M.on_init = function(client, _)
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}


local cmp_capabilities = {}
local success, cmp = pcall(require, 'blink.cmp')

if success then
  -- If 'blink.cmp' is available, get the LSP capabilities
  cmp_capabilities = cmp.get_lsp_capabilities() or {}
end

M.capabilities = vim.tbl_extend('force', M.capabilities, cmp_capabilities or {})


M.defaults = function()
  dofile(vim.g.base46_cache .. "lsp")
  require("nvchad.lsp").diagnostic_config()

  require("lspconfig").lua_ls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        completion = {
          callSnippet = "Replace",
        },
      },
    },
    -- settings = {
    --   Lua = {
    --     diagnostics = {
    --       globals = { "vim" },
    --     },
    --     workspace = {
    --       library = {
    --         vim.fn.expand "$VIMRUNTIME/lua",
    --         vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
    --         vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
    --         vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
    --         "${3rd}/luv/library",
    --       },
    --       maxPreload = 100000,
    --       preloadFileSize = 10000,
    --     },
    --   },
    -- },
  }
end

return M
