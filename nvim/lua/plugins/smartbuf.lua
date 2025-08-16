return {
  'johann2357/nvim-smartbufs',
  keys = {
    {
      '<leader>b1',
      function()
        require('nvim-smartbufs').goto_buffer(1)
      end,
      desc = '[B]uffer 1',
    },
    {
      '<leader>b2',
      function()
        require('nvim-smartbufs').goto_buffer(2)
      end,
      desc = '[B]uffer 2',
    },
    {
      '<leader>b3',
      function()
        require('nvim-smartbufs').goto_buffer(3)
      end,
      desc = '[B]uffer 3',
    },
    {
      '<leader>b4',
      function()
        require('nvim-smartbufs').goto_buffer(4)
      end,
      desc = '[B]uffer 4',
    },
    {
      '<leader>b5',
      function()
        require('nvim-smartbufs').goto_buffer(5)
      end,
      desc = '[B]uffer 5',
    },
    {
      '<leader>b6',
      function()
        require('nvim-smartbufs').goto_buffer(6)
      end,
      desc = '[B]uffer 6',
    },
    {
      '<leader>b7',
      function()
        require('nvim-smartbufs').goto_buffer(7)
      end,
      desc = '[B]uffer 7',
    },
    {
      '<leader>b8',
      function()
        require('nvim-smartbufs').goto_buffer(8)
      end,
      desc = '[B]uffer 8',
    },
    {
      '<leader>b9',
      function()
        require('nvim-smartbufs').goto_buffer(9)
      end,
      desc = '[B]uffer 9',
    },

    {
      '<leader>bc1',
      function()
        require('nvim-smartbufs').goto_terminal(1)
      end,
      desc = '[B]uffer terminal 1',
    },
    {
      '<leader>bc2',
      function()
        require('nvim-smartbufs').goto_terminal(2)
      end,
      desc = '[B]uffer terminal 2',
    },
    {
      '<leader>bc3',
      function()
        require('nvim-smartbufs').goto_terminal(3)
      end,
      desc = '[B]uffer terminal 3',
    },
    {
      '<leader>bc4',
      function()
        require('nvim-smartbufs').goto_terminal(4)
      end,
      desc = '[B]uffer terminal 4',
    },
    {
      '<leader>bqq',
      function()
        require('nvim-smartbufs').close_current_buffer()
      end,
      desc = '[B]uffer close current',
    },
    {
      '<leader>bq1',
      function()
        require('nvim-smartbufs').close_buffer(1)
      end,
      desc = '[B]uffer close 1',
    },
    {
      '<leader>bq2',
      function()
        require('nvim-smartbufs').close_buffer(2)
      end,
      desc = '[B]uffer close 2',
    },
    {
      '<leader>bq3',
      function()
        require('nvim-smartbufs').close_buffer(3)
      end,
      desc = '[B]uffer close 3',
    },
    {
      '<leader>bq4',
      function()
        require('nvim-smartbufs').close_buffer(4)
      end,
      desc = '[B]uffer close 4',
    },
    {
      '<leader>bq5',
      function()
        require('nvim-smartbufs').close_buffer(5)
      end,
      desc = '[B]uffer close 5',
    },
    {
      '<leader>bq6',
      function()
        require('nvim-smartbufs').close_buffer(6)
      end,
      desc = '[B]uffer close 6',
    },
    {
      '<leader>bq7',
      function()
        require('nvim-smartbufs').close_buffer(7)
      end,
      desc = '[B]uffer close 7',
    },
    {
      '<leader>bq8',
      function()
        require('nvim-smartbufs').close_buffer(8)
      end,
      desc = '[B]uffer close 8',
    },
    {
      '<leader>bq9',
      function()
        require('nvim-smartbufs').close_buffer(9)
      end,
      desc = '[B]uffer close 9',
    },
  },
}
