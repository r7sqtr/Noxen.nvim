local config = require("noxen.config")
local utils = require("noxen.utils")

local M = {}

-- Check search engine
local function get_search_engine()
	local engine = config.get("search.engine")

	if engine == "snacks" then
		local has_snacks, snacks = pcall(require, "snacks")
		if has_snacks then
			return "snacks", snacks
		end
	end

	if engine == "telescope" or engine == "snacks" then
		local has_telescope, telescope = pcall(require, "telescope.builtin")
		if has_telescope then
			return "telescope", telescope
		end
	end

	return nil, nil
end

-- Open note through UI (fallback to buffer if UI is unavailable)
local function open_note(filepath)
	if not filepath then
		return
	end

	local notes_dir = config.get("notes_dir")
	local normalized = vim.fn.fnamemodify(filepath, ":p")
	if vim.fn.filereadable(normalized) == 0 then
		local candidate = vim.fs.normalize(vim.fs.joinpath(notes_dir, filepath))
		if vim.fn.filereadable(candidate) == 1 then
			normalized = candidate
		end
	end

	local notes = require("noxen.notes")
	vim.schedule(function()
		notes.open_note(normalized)
	end)
end

-- Extract filepath from Telescope entry and open it
local function open_note_from_entry(entry)
	if not entry then
		return
	end

	local filepath = entry.path or entry.filename or entry.file or entry.value or entry[1]
	open_note(filepath)
end

-- Search notes (snacks.nvim)
local function search_with_snacks(notes_dir)
	local has_snacks, snacks = pcall(require, "snacks")
	if not has_snacks then
		utils.notify("snacks.nvim not found", vim.log.levels.ERROR)
		return
	end

	-- Use snacks.nvim picker
	local picker_ok, picker = pcall(require, "snacks.picker")
	if not picker_ok then
		utils.notify("snacks.nvim picker feature not found", vim.log.levels.ERROR)
		return
	end

	picker.pick({
		source = "files",
		cwd = notes_dir,
		prompt = "🔍 Search notes:",
		format = "file",
		actions = {
			confirm = function(picker_ctx, item)
				if item and item.file then
					picker_ctx:close()
					open_note(item.file)
				end
			end,
		},
	})
end

-- Search notes (Telescope.nvim)
local function search_with_telescope(notes_dir)
	local has_telescope, telescope = pcall(require, "telescope.builtin")
	if not has_telescope then
		utils.notify("Telescope.nvim not found", vim.log.levels.ERROR)
		return
	end

	telescope.find_files({
		prompt_title = "🔍 Search notes",
		cwd = notes_dir,
		previewer = true,
		layout_strategy = "horizontal",
		attach_mappings = function(_, map)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			actions.select_default:replace(function(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				open_note_from_entry(selection)
			end)

			return true
		end,
	})
end

-- Search notes
function M.find_notes(opts)
	opts = opts or {}
	local notes_dir = config.get("notes_dir")

	-- If project is specified
	if opts.project then
		notes_dir = notes_dir .. "/" .. opts.project
	end

	local engine, _ = get_search_engine()

	if engine == "snacks" then
		search_with_snacks(notes_dir)
	elseif engine == "telescope" then
		search_with_telescope(notes_dir)
	else
		-- Fallback: use vim.ui.select
		M.fallback_find_notes(notes_dir)
	end
end

-- Fallback search (vim.ui.select)
function M.fallback_find_notes(notes_dir)
	local notes = require("noxen.notes")
	local note_files = notes.get_notes({ recursive = true })

	if #note_files == 0 then
		utils.notify("No notes found", vim.log.levels.WARN)
		return
	end

	-- Extract file names for display
	local display_items = {}
	for _, file in ipairs(note_files) do
		local relative_path = file:gsub(notes_dir .. "/", "")
		table.insert(display_items, relative_path)
	end

	vim.ui.select(display_items, {
		prompt = "Select a note:",
	}, function(choice, idx)
		if choice and idx then
			notes.open_note(note_files[idx])
		end
	end)
end

-- Grep search (snacks.nvim)
local function grep_with_snacks(notes_dir, search_term)
	local has_snacks, snacks = pcall(require, "snacks")
	if not has_snacks then
		utils.notify("snacks.nvim not found", vim.log.levels.ERROR)
		return
	end

	local picker_ok, picker = pcall(require, "snacks.picker")
	if not picker_ok then
		utils.notify("snacks.nvim picker feature not found", vim.log.levels.ERROR)
		return
	end

	picker.pick({
		source = "grep",
		cwd = notes_dir,
		prompt = "🔍 Search content:",
		search = search_term or "",
		actions = {
			confirm = function(picker_ctx, item)
				if item and item.file then
					picker_ctx:close()
					open_note(item.file)
				end
			end,
		},
	})
end

-- Grep search (Telescope.nvim)
local function grep_with_telescope(notes_dir, search_term)
	local has_telescope, telescope = pcall(require, "telescope.builtin")
	if not has_telescope then
		utils.notify("Telescope.nvim not found", vim.log.levels.ERROR)
		return
	end

	telescope.live_grep({
		prompt_title = "🔍 Search content",
		cwd = notes_dir,
		default_text = search_term or "",
		attach_mappings = function(_, map)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			actions.select_default:replace(function(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				open_note_from_entry(selection)
			end)

			return true
		end,
	})
end

-- Search notes by content
function M.grep_notes(search_term)
	local notes_dir = config.get("notes_dir")
	local engine, _ = get_search_engine()

	if engine == "snacks" then
		grep_with_snacks(notes_dir, search_term)
	elseif engine == "telescope" then
		grep_with_telescope(notes_dir, search_term)
	else
		utils.notify("Search engine not found", vim.log.levels.ERROR)
	end
end

-- Show note list (custom)
function M.show_notes(notes, title)
	if #notes == 0 then
		utils.notify("No notes found", vim.log.levels.WARN)
		return
	end

	local notes_dir = config.get("notes_dir")
	local display_items = {}

	for _, file in ipairs(notes) do
		local relative_path = file:gsub(notes_dir .. "/", "")
		table.insert(display_items, relative_path)
	end

	vim.ui.select(display_items, {
		prompt = title or "Select a note:",
	}, function(choice, idx)
		if choice and idx then
			local note_mod = require("noxen.notes")
			note_mod.open_note(notes[idx])
		end
	end)
end

-- Tag search
function M.search_by_tag()
	local notes = require("noxen.notes")
	notes.find_notes_by_tag()
end

-- Select project and search
function M.search_by_project()
	local notes = require("noxen.notes")
	local projects = notes.get_projects()

	if #projects == 0 then
		utils.notify("No projects found", vim.log.levels.WARN)
		return
	end

	local project_names = {}
	for _, project in ipairs(projects) do
		table.insert(project_names, project.name)
	end

	vim.ui.select(project_names, {
		prompt = "Select a project:",
	}, function(choice)
		if choice then
			M.find_notes({ project = choice })
		end
	end)
end

return M
