local config = require("noxen.config")
local utils = require("noxen.utils")

local M = {}

-- Currently opened note
M.current_note = nil

-- Current project
M.current_project = nil

-- Create a new note
function M.create_note(opts)
	opts = opts or {}

	-- Get title
	local title = opts.title
	if not title then
		vim.ui.input({ prompt = "Note title: " }, function(input)
			if not input or input == "" then
				return
			end
			title = input
			M._create_note_with_title(title, opts)
		end)
	else
		M._create_note_with_title(title, opts)
	end
end

-- Create a new note with specified title
function M._create_note_with_title(title, opts)
	opts = opts or {}
	local project = opts.project or M.current_project or "default"

	-- Check project directory
	local project_dir = config.get("notes_dir") .. "/" .. project
	utils.ensure_dir(project_dir)

	-- Generate filename
	local filename = utils.title_to_filename(title)
	local filepath = project_dir .. "/" .. filename

	-- If file already exists
	if utils.file_exists(filepath) then
		utils.notify('Note "' .. title .. '" already exists', vim.log.levels.WARN)
		M.open_note(filepath)
		return
	end

	-- Load template
	local template_path = config.get("templates_dir") .. "/" .. config.get("template")
	local content = utils.apply_template(template_path, {
		title = title,
		date = utils.get_date_string("%Y-%m-%d"),
		tags = opts.tags or "",
	})

	if not content then
		utils.notify("Failed to load template", vim.log.levels.ERROR)
		return
	end

	-- Write to file
	local file = io.open(filepath, "w")
	if file then
		file:write(content)
		file:close()
		utils.notify('Note "' .. title .. '" created')
		M.open_note(filepath)
	else
		utils.notify("Failed to create note", vim.log.levels.ERROR)
	end
end

-- Open note
function M.open_note(filepath)
	M.current_note = filepath

	-- If UI module is loaded, open with UI
	local has_ui, ui = pcall(require, "noxen.ui")
	if has_ui then
		ui.open(filepath)
	else
		-- If no UI module, open with normal buffer
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
	end
end

-- Delete note
function M.delete_note(filepath)
	filepath = filepath or M.current_note

	if not filepath then
		utils.notify("No note selected for deletion", vim.log.levels.WARN)
		return
	end

	vim.ui.select({ "Yes", "No" }, {
		prompt = "Delete note?: " .. vim.fn.fnamemodify(filepath, ":t"),
	}, function(choice)
		if choice == "Yes" then
			local success = os.remove(filepath)
			if success then
				utils.notify("Note deleted")
				-- Close buffer
				local bufnr = vim.fn.bufnr(filepath)
				if bufnr ~= -1 then
					vim.api.nvim_buf_delete(bufnr, { force = true })
				end
				M.current_note = nil
			else
				utils.notify("Failed to delete note", vim.log.levels.ERROR)
			end
		end
	end)
end

-- Get list of notes
function M.get_notes(opts)
	opts = opts or {}
	local notes_dir = config.get("notes_dir")
	local project = opts.project

	-- If project is specified
	if project then
		notes_dir = notes_dir .. "/" .. project
	end

	return utils.get_files(notes_dir, opts.recursive or true)
end

-- Get list of projects
function M.get_projects()
	return utils.get_projects(config.get("notes_dir"))
end

-- Switch project
function M.switch_project(project_name)
	if not project_name then
		local projects = M.get_projects()
		local project_names = {}

		for _, project in ipairs(projects) do
			table.insert(project_names, project.name)
		end

		vim.ui.select(project_names, {
			prompt = "Select project:",
		}, function(choice)
			if choice then
				M.current_project = choice
				utils.notify('Switched to project "' .. choice .. '"')
			end
		end)
	else
		M.current_project = project_name
		utils.notify('Switched to project "' .. project_name .. '"')
	end
end

-- Get list of tags
function M.get_tags()
	return utils.get_all_tags(config.get("notes_dir"))
end

-- Search notes by tag
function M.find_notes_by_tag(tag)
	if not tag then
		local tags = M.get_tags()
		vim.ui.select(tags, {
			prompt = "Select tag:",
		}, function(choice)
			if choice then
				M._find_notes_by_tag(choice)
			end
		end)
	else
		M._find_notes_by_tag(tag)
	end
end

-- Search notes by tag (internal)
function M._find_notes_by_tag(tag)
	local notes = M.get_notes()
	local filtered_notes = {}

	for _, note in ipairs(notes) do
		local hashtags = utils.extract_hashtags(note)
		local frontmatter = utils.parse_frontmatter(note)

		local has_tag = false

		-- Check hashtags
		if vim.tbl_contains(hashtags, tag) then
			has_tag = true
		end

		-- Check frontmatter tags
		if frontmatter and frontmatter.tags then
			if vim.tbl_contains(frontmatter.tags, tag) then
				has_tag = true
			end
		end

		if has_tag then
			table.insert(filtered_notes, note)
		end
	end

	-- Show with search module
	local has_search, search = pcall(require, "noxen.search")
	if has_search then
		search.show_notes(filtered_notes, "Tag: " .. tag)
	else
		utils.notify(#filtered_notes .. " notes found")
	end
end

-- Autosave note
function M.setup_autosave(bufnr)
	local auto_save = config.get("ui.auto_save")
	local save_timeout = config.get("ui.save_timeout")

	if not auto_save then
		return
	end

	local timer = vim.loop.new_timer()
	local group = vim.api.nvim_create_augroup("NoxenAutoSave", { clear = true })

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = group,
		buffer = bufnr,
		callback = function()
			if timer then
				timer:stop()
			end
			timer:start(
				save_timeout,
				0,
				vim.schedule_wrap(function()
					if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modified then
						vim.api.nvim_buf_call(bufnr, function()
							vim.cmd("silent! write")
						end)
					end
				end)
			)
		end,
	})
end

return M
