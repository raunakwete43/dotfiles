dofile(vim.g.base46_cache .. "whichkey")

return {
  icons = {
    mappings = false,
  },
  spec = {

    { '<leader>e', group = '[E]xplorer',        mode = { 'n', 'x' } },
    { '<leader>c', group = '[C]ode' },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>t', group = '[T]oggle',          mode = { 'n', 'v' } },
    { '<leader>f', group = '[F]lutter',         mode = { 'n', 'v' } },
    { '<leader>b', group = '[B]uffer Navigate', mode = { 'n', 'v' } },
    { '<leader>h', group = 'Git [H]unk',        mode = { 'n', 'v' } },

    { 'sa',        group = 'Mini Surround' },
  },
}
