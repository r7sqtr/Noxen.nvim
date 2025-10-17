local M = {}

-- Split dotted keys into table of parts
local function split_key(key)
	local parts = {}
	for part in key:gmatch("[^%.]+") do
		table.insert(parts, part)
	end
	return parts
end

-- Traverse a table with the provided key parts
local function resolve(tbl, parts)
	local value = tbl
	for _, part in ipairs(parts) do
		if type(value) ~= "table" then
			return nil
		end
		value = value[part]
		if value == nil then
			return nil
		end
	end
	return value
end

-- Default settings
M.defaults = {
	-- Directory to save notes
	notes_dir = "~/.noxen",

	-- Default template
	template = "default.md",

	-- Template directory
	templates_dir = "~/.noxen/templates",

	-- UI settings
	ui = {
		-- Popup position ("center", "bottom", "right")
		position = "center",

		-- Popup size
		width = 80,
		height = 20,

		-- Border style ("rounded", "single", "double", "solid", "none")
		border = "rounded",

		-- Title
		title = " noxen.nvim ",

		-- Auto save
		auto_save = true,

		-- Timeout for saving (ms)
		save_timeout = 1000,
	},

	-- Keymaps
	keymaps = {
		-- Toggle UI
		toggle = "<leader>mn",

		-- Create new note
		new = "<leader>mn",

		-- Find notes
		find = "<leader>mf",

		-- Search by tag
		tags = "<leader>mt",

		-- Switch project
		projects = "<leader>mp",
	},

	-- Tag settings
	tags = {
		-- Tag format ("hashtag" or "frontmatter")
		format = "hashtag",

		-- Tag delimiter
		delimiter = ",",
	},

	-- Frontmatter settings
	frontmatter = {
		-- Use frontmatter
		enabled = true,

		-- Default frontmatter
		default = {
			date = function()
				return os.date("%Y-%m-%d")
			end,
			tags = {},
		},
	},

	-- Search settings
	search = {
		-- Search engine ("snacks" or "telescope")
		engine = "snacks",

		-- Ignore patterns when searching
		ignore_patterns = {
			"%.git/",
			"node_modules/",
			"%.DS_Store",
		},
	},
}

-- Store current settings
M.options = {}

-- Initialize settings
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

	-- Expand paths (~ and environment variables)
	M.options.notes_dir = vim.fn.expand(M.options.notes_dir)
	M.options.templates_dir = vim.fn.expand(M.options.templates_dir)

	-- Create notes_dir if it does not exist
	if vim.fn.isdirectory(M.options.notes_dir) == 0 then
		vim.fn.mkdir(M.options.notes_dir, "p")
	end

	-- Create templates_dir if it does not exist
	if vim.fn.isdirectory(M.options.templates_dir) == 0 then
		vim.fn.mkdir(M.options.templates_dir, "p")
	end

	-- Create default template if it does not exist
	local default_template_path = M.options.templates_dir .. "/" .. M.options.template
	if vim.fn.filereadable(default_template_path) == 0 then
		M.create_default_template(default_template_path)
	end
end

-- Create default template
function M.create_default_template(path)
	local template_content = [[---
title:
date: {{date}}
tags: []
---
]]
	local f = io.open(path, "w")
	if f then
		f:write(template_content)
		f:close()
	end
end

-- Retrieve configuration values. Accepts dot notation for nested keys.
function M.get(key)
	if not key or key == "" then
		return next(M.options) and M.options or M.defaults
	end

	local parts = split_key(key)
	local value = resolve(M.options, parts)
	if value ~= nil then
		return value
	end

	return resolve(M.defaults, parts)
end

return M
