-- Customize Treesitter

---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	opts = {
		ensure_installed = {
			"lua",
			"vim",
			"toml",
			"markdown",
			"nix",
			"python",
			"rust",
			-- add more arguments for adding more treesitter parsers
		},
	},
}
