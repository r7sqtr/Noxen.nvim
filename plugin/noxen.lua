-- Skip if the plugin is already loaded
if vim.g.loaded_noxen then
	return
end
vim.g.loaded_noxen = 1

-- Lazy-load the Noxen module
local function noxen()
	return require("noxen")
end

-- Command: NoxenNew - Create a new note
vim.api.nvim_create_user_command("NoxenNew", function(opts)
	local title = opts.args ~= "" and opts.args or nil
	noxen().new({ title = title })
end, {
	nargs = "?",
	desc = "Noxen: Create a new note",
})

-- Command: NoxenFind - Find notes
vim.api.nvim_create_user_command("NoxenFind", function(opts)
	local project = opts.args ~= "" and opts.args or nil
	noxen().find({ project = project })
end, {
	nargs = "?",
	desc = "Noxen: Find notes",
})

-- Command: NoxenGrep - Search notes by content
vim.api.nvim_create_user_command("NoxenGrep", function(opts)
	local search_term = opts.args ~= "" and opts.args or nil
	noxen().grep(search_term)
end, {
	nargs = "?",
	desc = "Noxen: Search notes by content",
})

-- Command: NoxenTags - Search notes by tag
vim.api.nvim_create_user_command("NoxenTags", function(opts)
	local tag = opts.args ~= "" and opts.args or nil
	noxen().tags(tag)
end, {
	nargs = "?",
	desc = "Noxen: Search notes by tag",
})

-- Command: NoxenProjects - Switch project
vim.api.nvim_create_user_command("NoxenProjects", function(opts)
	local project = opts.args ~= "" and opts.args or nil
	noxen().projects(project)
end, {
	nargs = "?",
	desc = "Noxen: Switch project",
})

-- Command: NoxenToggle - Toggle UI
vim.api.nvim_create_user_command("NoxenToggle", function()
	noxen().toggle()
end, {
	desc = "Noxen: Toggle UI",
})

-- Command: NoxenOpen - Open UI
vim.api.nvim_create_user_command("NoxenOpen", function(opts)
	local filepath = opts.args ~= "" and vim.fn.expand(opts.args) or nil
	noxen().open(filepath)
end, {
	nargs = "?",
	complete = "file",
	desc = "Noxen: Open UI",
})

-- Command: NoxenClose - Close UI
vim.api.nvim_create_user_command("NoxenClose", function()
	noxen().close()
end, {
	desc = "Noxen: Close UI",
})

-- Command: NoxenQuick - Create quick note
vim.api.nvim_create_user_command("NoxenQuick", function()
	noxen().quick_note()
end, {
	desc = "Noxen: Create quick note",
})

-- Command: NoxenDelete - Delete note
vim.api.nvim_create_user_command("NoxenDelete", function(opts)
	local filepath = opts.args ~= "" and vim.fn.expand(opts.args) or nil
	noxen().delete(filepath)
end, {
	nargs = "?",
	complete = "file",
	desc = "Noxen: Delete note",
})

-- Command: NoxenInfo - Show plugin info
vim.api.nvim_create_user_command("NoxenInfo", function()
	local n = noxen()
	local config = n.get_config()

	local info = {
		"noxen.nvim v" .. n.version,
		"",
		"Configuration:",
		"  notes_dir: " .. config.notes_dir,
		"  template: " .. config.template,
		"  search_engine: " .. config.search.engine,
		"",
		"Current:",
		"  project: " .. (n.current_project() or "default"),
		"  note: " .. (n.current_note() or "none"),
	}

	vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end, {
	desc = "Noxen: Show plugin info",
})
