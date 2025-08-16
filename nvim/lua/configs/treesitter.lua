pcall(function()
  dofile(vim.g.base46_cache .. "syntax")
  dofile(vim.g.base46_cache .. "treesitter")
end)

return {
  ensure_installed = { "lua", "luadoc", "comment" },
  auto_install = true,

  modules = {
    auto_install = true,
  },

  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = { "ruby" },
  },

  indent = { enable = true, disable = { "ruby" } },
}
