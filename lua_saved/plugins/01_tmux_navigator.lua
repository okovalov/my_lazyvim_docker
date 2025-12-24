return {
  -- tmux & split window navigation
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      {
        "<C-h>",
        ":TmuxNavigateLeft<cr>",
        desc = "window left",
      },
      {
        "<C-l>",
        ":TmuxNavigateRight<cr>",
        desc = "window right",
      },
      {
        "<C-j>",
        ":TmuxNavigateDown<cr>",
        desc = "window down",
      },
      {
        "<C-k>",
        ":TmuxNavigateUp<cr>",
        desc = "window up",
      },
    },
  },
}
