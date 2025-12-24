return {
  -- git integration
  {
    "lewis6991/gitsigns.nvim", -- show line modifications on left hand side
    keys = {
      {
        "<leader>ghN",
        function()
          require("gitsigns").next_hunk()
        end,
        desc = "next hunk",
      },
      {
        "<leader>ghP",
        function()
          require("gitsigns").prev_hunk()
        end,
        desc = "prev hunk",
      },

      {
        "<leader>ghS",
        function()
          require("gitsigns").stage_buffer()
        end,
        desc = "stage buffer",
      },
    },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = true,
      on_attach = function(buffer)
        -- local gs = package.loaded.gitsigns
        local gs = require("gitsigns")

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        -- map("n","<leader>ghN" , gs.next_hunk, "Next Hunk")
        -- map("n","<leader>ghP" , gs.prev_hunk, "Prev Hunk")

       
        -- Navigation
        map('n', '<leader>ghN', function()
          if vim.wo.diff then
            vim.cmd.normal({'<leader>ghN', bang = true})
          else
            gs.nav_hunk('next')
          end
        end, "Next Hunk")

        -- map("n","<leader>ghP" , gs.nav_hunk('prev'), "Prev Hunk")
        map('n', '<leader>ghP', function()
          if vim.wo.diff then
            vim.cmd.normal({'<leader>ghP', bang = true})
          else
            gs.nav_hunk('prev')
          end
        end, "Prev Hunk")
        --
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        

        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        -- map("n", "<leader>ghu", gs.reset_hunk, "Undo Stage Hunk")

        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghB", gs.toggle_current_line_blame, "Blame toggle")
        map("n", "<leader>ghB", gs.toggle_current_line_blame, "Blame toggle")
        map("n", "<leader>ghW", gs.toggle_word_diff, "Word diff toggle")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
}
