-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>") -- in insert mode "jk" is set to be <ESC> so it takes you back to N mode
