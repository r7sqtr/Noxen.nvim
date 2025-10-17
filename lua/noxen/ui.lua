local config = require("noxen.config")
local utils = require("noxen.utils")

local M = {}

-- Current popup window
M.popup = nil
M.is_open = false

-- nui.nvim components
local Popup = nil
local event = nil

-- Check nui.nvim initialization
local function ensure_nui()
	if not Popup then
		local has_popup, popup = pcall(require, "nui.popup")
		local has_event, ev = pcall(require, "nui.utils.autocmd")

		if has_popup and has_event and ev and ev.event then
			Popup = popup
			event = ev.event
			return true
		else
			utils.notify("nui.nvim not found. Please install it.", vim.log.levels.ERROR)
			return false
		end
	end
	return true
end

-- Calculate popup size and position
local function calculate_popup_options()
	local ui_config = config.get("ui")
	local position = (ui_config and ui_config.position) or "center"
	local width = (ui_config and ui_config.width) or 80
	local height = (ui_config and ui_config.height) or 20

	-- Percentage specification
	if type(width) == "string" and width:match("%%$") then
		width = math.floor(vim.o.columns * tonumber(width:match("(%d+)%%")) / 100)
	end
	if type(height) == "string" and height:match("%%$") then
		height = math.floor(vim.o.lines * tonumber(height:match("(%d+)%%")) / 100)
	end

	local options = {
		border = {
			style = (ui_config and ui_config.border) or "rounded",
			text = {
				top = (ui_config and ui_config.title) or " noxen.nvim ",
				top_align = "center",
			},
		},
		relative = "editor",
		size = {
			width = width,
			height = height,
		},
	}

	-- Position setting
	if position == "center" then
		options.position = "50%"
	elseif position == "bottom" then
		options.position = {
			row = "95%",
			col = "50%",
		}
	elseif position == "right" then
		options.position = {
			row = "50%",
			col = "95%",
		}
	end

	return options
end

-- Open popup
function M.open(filepath)
	if not ensure_nui() then
		-- If nui.nvim is not available, open with normal buffer
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
		return
	end

	-- Close popup if already open
	if M.is_open and M.popup then
		M.close()
	end

	-- Create popup
	local options = calculate_popup_options()
	M.popup = Popup(options)

	-- Mount popup before loading buffer so :edit runs inside the popup window
	M.popup:mount()
	M.is_open = true

	-- Enter popup window and load file so that :edit targets the popup buffer
	vim.api.nvim_set_current_win(M.popup.winid)
	vim.cmd("silent edit " .. vim.fn.fnameescape(filepath))

	-- Use the buffer attached to the popup window
	local bufnr = vim.api.nvim_get_current_buf()

	-- Set buffer options
	vim.bo[bufnr].filetype = "markdown"
	vim.bo[bufnr].bufhidden = "hide"

	-- Setup autosave
	local notes = require("noxen.notes")
	notes.setup_autosave(bufnr)

	-- Setup keymaps
	M.setup_keymaps(bufnr)

	-- Focus popup window
	vim.api.nvim_set_current_win(M.popup.winid)

	-- Event on close
	M.popup:on(event.BufWinLeave, function()
		M.is_open = false
	end)
end

-- Close popup
function M.close()
	if M.popup then
		M.popup:unmount()
		M.popup = nil
		M.is_open = false
	end
end

-- Toggle popup
function M.toggle(filepath)
	if M.is_open then
		M.close()
	else
		if filepath then
			M.open(filepath)
		else
			-- If no file specified, open last opened memo
			local notes = require("noxen.notes")
			if notes.current_note then
				M.open(notes.current_note)
			else
				utils.notify("There's no memo to open.", vim.log.levels.WARN)
			end
		end
	end
end

-- Setup keymaps
function M.setup_keymaps(bufnr)
	local opts = { buffer = bufnr, noremap = true, silent = true }

	-- Close with Esc
	vim.keymap.set("n", "<Esc>", function()
		M.close()
	end, opts)

	-- Close with q
	vim.keymap.set("n", "q", function()
		M.close()
	end, opts)
end

-- Resize popup
function M.resize(width, height)
	if not M.is_open or not M.popup then
		return
	end

	-- Update popup with new size
	M.popup:update_layout({
		size = {
			width = width,
			height = height,
		},
	})
end

-- Change popup position
function M.reposition(position)
	if not M.is_open or not M.popup then
		return
	end

	local new_position
	if position == "center" then
		new_position = "50%"
	elseif position == "bottom" then
		new_position = {
			row = "95%",
			col = "50%",
		}
	elseif position == "right" then
		new_position = {
			row = "50%",
			col = "95%",
		}
	end

	if new_position then
		M.popup:update_layout({
			position = new_position,
		})
	end
end

-- Quick Note feature
function M.quick_note()
	-- Create temporary memo
	local notes = require("noxen.notes")
	local timestamp = os.date("%Y%m%d_%H%M%S")
	local title = "quick_" .. timestamp

	notes.create_note({
		title = title,
		project = "quick-notes",
	})
end

return M
