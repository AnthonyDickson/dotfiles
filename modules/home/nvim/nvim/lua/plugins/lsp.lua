return {
	"neovim/nvim-lspconfig",
	opts = {
		inlay_hints = { enabled = false },
		diagnostics = {
			float = {
				border = "rounded",
			},
		},
		servers = {
			clangd = {
				mason = false,
			},
		},
	},
}
