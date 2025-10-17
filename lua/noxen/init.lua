local M = {}

-- Load modules
local config = require("noxen.config")
local notes = require("noxen.notes")
local ui = require("noxen.ui")
local search = require("noxen.search")
local utils = require("noxen.utils")

-- Initialization flag
M._initialized = false

-- Setup
function M.setup(opts)
  -- Initialize config
  config.setup(opts)

  -- Set initialized flag
  M._initialized = true

  -- Set global keymaps (optional)
  if config.get("keymaps") then
    M.setup_keymaps()
  end

  -- User commands are created in plugin/noxen.lua
end

-- Set global keymaps
function M.setup_keymaps()
  local keymaps = config.get("keymaps")

  if keymaps.toggle then
    vim.keymap.set("n", keymaps.toggle, function()
      M.toggle()
    end, { desc = "Noxen: Toggle UI" })
  end

  if keymaps.new then
    vim.keymap.set("n", keymaps.new, function()
      M.new()
    end, { desc = "Noxen: New Note" })
  end

  if keymaps.find then
    vim.keymap.set("n", keymaps.find, function()
      M.find()
    end, { desc = "Noxen: Find Notes" })
  end

  if keymaps.tags then
    vim.keymap.set("n", keymaps.tags, function()
      M.tags()
    end, { desc = "Noxen: Search by Tag" })
  end

  if keymaps.projects then
    vim.keymap.set("n", keymaps.projects, function()
      M.projects()
    end, { desc = "Noxen: Switch Project" })
  end
end

-- Create new note
function M.new(opts)
  notes.create_note(opts)
end

-- Search notes
function M.find(opts)
  search.find_notes(opts)
end

-- Search notes by content
function M.grep(search_term)
  search.grep_notes(search_term)
end

-- Search notes by tag
function M.tags(tag)
  if tag then
    notes.find_notes_by_tag(tag)
  else
    search.search_by_tag()
  end
end

-- Switch project
function M.projects(project_name)
  if project_name then
    notes.switch_project(project_name)
  else
    search.search_by_project()
  end
end

-- Toggle UI
function M.toggle(filepath)
  ui.toggle(filepath)
end

-- Open UI
function M.open(filepath)
  ui.open(filepath)
end

-- Close UI
function M.close()
  ui.close()
end

-- Quick note
function M.quick_note()
  ui.quick_note()
end

-- Delete note
function M.delete(filepath)
  notes.delete_note(filepath)
end

-- Get tag list
function M.get_tags()
  return notes.get_tags()
end

-- Get project list
function M.get_projects()
  return notes.get_projects()
end

-- Get current note
function M.current_note()
  return notes.current_note
end

-- Get current project
function M.current_project()
  return notes.current_project
end

-- Get config
function M.get_config(key)
  return config.get(key)
end

-- Version info
M.version = "0.1.0"

-- Alias for lazy.nvim opts support
M.config = M.setup

return M

