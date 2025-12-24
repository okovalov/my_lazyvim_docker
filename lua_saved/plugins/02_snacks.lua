return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    quickfile = { enabled = false },
    picker = {
      -- enabled = false, -- enable the picker
      sources = {
        explorer = {
          layout = {
            auto_hide = { "input" },
          },
          exclude = { ".git" },
          include = { ".env", ".dockerignore", ".gitignore" },
        },
      },
      previewers = {
        diff = {
          builtin = false, -- use Neovim for previewing diffs (true) or use an external tool (false)
          cmd = { "delta" }, -- example to show a diff with delta
        },
        git = {
          builtin = true, -- use Neovim for previewing git output (true) or use git (false)
          args = {}, -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
        },
        file = {
          max_size = 1024 * 1024, -- 1MB
          max_line_length = 500, -- max line length
          ft = nil, ---@type string? filetype for highlighting. Use `nil` for auto detect
        },
        man_pager = nil, ---@type string? MANPAGER env to use for `man` preview
      },
    },
  },
}
