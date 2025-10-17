local M = {}

-- Check if directory exists and create if not
function M.ensure_dir(path)
	if vim.fn.isdirectory(path) == 0 then
		vim.fn.mkdir(path, "p")
	end
end

-- Check if file exists
function M.file_exists(path)
	return vim.fn.filereadable(path) == 1
end

-- Get list of files in directory
function M.get_files(dir, recursive)
	local files = {}
	local cmd = string.format("find %s -name '*.md' -type f", vim.fn.shellescape(dir))

	if not recursive then
		cmd = string.format("find %s -maxdepth 1 -name '*.md' -type f", vim.fn.shellescape(dir))
	end

	local handle = io.popen(cmd)
	if handle then
		for line in handle:lines() do
			table.insert(files, line)
		end
		handle:close()
	end

	return files
end

-- Get list of projects (directories directly under notes_dir)
function M.get_projects(notes_dir)
	local projects = {}
	local handle = io.popen(string.format("find %s -maxdepth 1 -type d", vim.fn.shellescape(notes_dir)))

	if handle then
		for line in handle:lines() do
			if line ~= notes_dir then
				local project_name = vim.fn.fnamemodify(line, ":t")
				if project_name ~= "templates" then
					table.insert(projects, {
						name = project_name,
						path = line,
					})
				end
			end
		end
		handle:close()
	end

	return projects
end

-- Extract Frontmatter from file
function M.parse_frontmatter(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	local frontmatter = {}
	local in_frontmatter = false
	local frontmatter_lines = {}

	for line in content:gmatch("[^\r\n]+") do
		if line:match("^---$") then
			if not in_frontmatter then
				in_frontmatter = true
			else
				break
			end
		elseif in_frontmatter then
			table.insert(frontmatter_lines, line)
		end
	end

	-- Parse YAML-style Frontmatter (simple version)
	for _, line in ipairs(frontmatter_lines) do
		local key, value = line:match("^(%w+):%s*(.*)$")
		if key and value then
			-- Handle array of tags
			if key == "tags" and value:match("^%[.*%]$") then
				local tags = {}
				for tag in value:gmatch("[^%[%],%s]+") do
					table.insert(tags, tag)
				end
				frontmatter[key] = tags
			else
				frontmatter[key] = value
			end
		end
	end

	return frontmatter
end

-- Extract hashtags from file
function M.extract_hashtags(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return {}
	end

	local content = file:read("*all")
	file:close()

	local tags = {}
	for tag in content:gmatch("#(%w+)") do
		if not vim.tbl_contains(tags, tag) then
			table.insert(tags, tag)
		end
	end

	return tags
end

-- Get list of all tags (from all notes)
function M.get_all_tags(notes_dir)
	local all_tags = {}
	local files = M.get_files(notes_dir, true)

	for _, file in ipairs(files) do
		local hashtags = M.extract_hashtags(file)
		for _, tag in ipairs(hashtags) do
			if not vim.tbl_contains(all_tags, tag) then
				table.insert(all_tags, tag)
			end
		end

		local frontmatter = M.parse_frontmatter(file)
		if frontmatter and frontmatter.tags then
			for _, tag in ipairs(frontmatter.tags) do
				if not vim.tbl_contains(all_tags, tag) then
					table.insert(all_tags, tag)
				end
			end
		end
	end

	return all_tags
end

-- Load template and replace variables
function M.apply_template(template_path, vars)
	local file = io.open(template_path, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	-- Replace variables
	for key, value in pairs(vars) do
		local pattern = "{{" .. key .. "}}"
		if type(value) == "function" then
			value = value()
		end
		content = content:gsub(pattern, value)
	end

	return content
end

-- Show notification
function M.notify(msg, level)
	level = level or vim.log.levels.INFO
	vim.notify("[Noxen] " .. msg, level)
end

-- Generate date string
function M.get_date_string(format)
	format = format or "%Y-%m-%d"
	return os.date(format)
end

-- Normalize path
function M.normalize_path(path)
	return vim.fn.expand(path)
end

-- Generate title from filename
function M.filename_to_title(filename)
	local title = vim.fn.fnamemodify(filename, ":t:r")
	return title:gsub("-", " "):gsub("_", " ")
end

-- Generate filename from title
function M.title_to_filename(title)
	return title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "") .. ".md"
end

return M
