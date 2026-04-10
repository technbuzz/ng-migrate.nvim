local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values

local utils = require('ng-migrate.utils')

local log = require('plenary.log'):new()
log.level = 'debug'

local M = {};

-- Validation Phase
local function get_workspace_root()
  local stop_path = vim.fn.getcwd()
  local match = vim.fs.find('angular.json', { path = stop_path, upward = true })[1]

  if match then
    return vim.fs.dirname(match)
  end

  return nil
end

local function get_migrations(root) 
  local collection_path = root .. '/node_modules/@angular/core/schematics/collection.json'

  local data = utils.read_json_file(collection_path)
  if not data or not data.schematics then
    print('❌ Could not find migrations' .. collection_path)
    return
  end

  local list = {}

  for name, details in pairs(data.schematics) do
    if name:match("migration") then
      table.insert(list, {
        name = name,
        details = details
      })
    end
  end

  return list
end

M.list_migrations = function(opts)
  local root = get_workspace_root()

  if not root then
    vim.notify("❌ Not in an Angular project", vim.log.levels.ERROR)
    return
  end

  -- get to collections.js
  local migrations = get_migrations(root)

  pickers.new(opts, {
    finder = finders.new_table({
      results = migrations,
      cwd = root,
      entry_maker = function(entry)
        -- log.debug(entry)

        return {
          value = entry.details.description,
          display = "🅰️  " .. entry.name,
          ordinal = entry.name,
          details = entry.details
        }
      end
    }),

    -- sorts and filters the results
    sorter = config.generic_sorter(opts),

    previewer = previewers.new_buffer_previewer({
      title = "Migration Details",

      define_preview = function(self, entry)
        log.debug('entry', entry)
        local lines = vim.split(vim.inspect(entry.details.description), "\n")
        log.debug('lines', lines)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)


        vim.api.nvim_set_option_value("wrap", true, { win = self.state.winid })
        vim.api.nvim_set_option_value("foldcolumn", "3", { win = self.state.winid })
      end
    })

  }):find()
end

vim.api.nvim_create_user_command('NgMigrate', function()
    M.list_migrations()
end, {})

return M;
