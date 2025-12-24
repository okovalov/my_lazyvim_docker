-- if true then
--   return {}
-- end
return {
	"yetone/avante.nvim",
	lazy = false,
	opts = {
		provider = "deepseek", -- Set DeepSeek as the primary provider
		providers = {
			deepseek = {
				__inherited_from = "openai", -- Inherits OpenAI-compatible config
				endpoint = "https://api.deepseek.com", -- DeepSeek API endpoint
				model = "deepseek-coder", -- Use "deepseek-coder" for coding or "deepseek-chat" for general chat
				api_key_name = "DEEPSEEK_API_KEY", -- Env variable name for your API key
			},
			chatgpt5 = {
				__inherited_from = "openai", -- Inherits OpenAI-compatible config
				endpoint = "https://api.openai.com", -- OpenAI API endpoint
				model = "gpt-5", -- Use GPT-5 model
				api_key_name = "OPENAI_API_KEY", -- Env variable name for your API key
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		-- "echasnovski/mini.pick", -- for file_selector provider mini.pick
		"nvim-mini/mini.pick", -- for file_selector provider mini.pick
		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
		"ibhagwan/fzf-lua", -- for file_selector provider fzf
		"stevearc/dressing.nvim", -- for input provider dressing
		"folke/snacks.nvim", -- for input provider snacks
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"MunifTanjim/nui.nvim",
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			"nvim-mini/mini.pick", -- for file_selector provider mini.pick
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
