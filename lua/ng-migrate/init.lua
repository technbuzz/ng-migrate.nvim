local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values
local nestedMigs = require('ng-migrate.nested_migs')

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

---@class MigrationWithRoot
---@field list Migration[] List of migrations
---@field rootPath string Path to root collection.json

---Creates a table from collection.json and returns a list of migrations 
---along with the root path
---@param root string
---@returns MigrationWithRoot
local function get_migrations(root) 
  local collection_path = root .. '/node_modules/@angular/core/schematics/collection.json'

  local data = utils.read_json_file(collection_path)
  if not data or not data.schematics then
    print('❌ Could not find migrations' .. collection_path)
    return
  end

  local list = {}

  -- We are interested in migration schematics not other collections
  for name, details in pairs(data.schematics) do
    if name:match("migration") then
      table.insert(list, {
        name = name,
        details = details
      })
    end
  end

  return { list = list, root = collection_path }
end

local presentTerm = function(command)
  vim.cmd.vnew()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 15)

  vim.api.nvim_create_autocmd("TermOpen", {
    buffer = 0,
    callback = function()
      log.debug('term open ran')
      vim.api.nvim_win_set_cursor(0, { 9999, 0 })
    end
  })

  vim.api.nvim_command("term " .. command)

end

M.list_migrations = function(opts)
  local root = get_workspace_root()

  if not root then
    vim.notify("❌ Not in an Angular project", vim.log.levels.ERROR)
    return
  end

  -- get to collections.js
  local migrations = get_migrations(root)
  if not migrations then
    return
  end

  pickers.new(opts, {
    finder = finders.new_table({
      results = migrations.list,
      cwd = root,
      entry_maker = function(entry)

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
        -- log.debug('entry', entry)
        local lines = vim.split(vim.inspect(entry.details.description), "\n")
        -- log.debug('lines', lines)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)


        vim.api.nvim_set_option_value("wrap", true, { win = self.state.winid })
        vim.api.nvim_set_option_value("foldcolumn", "3", { win = self.state.winid })
      end
    }),

    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()

        -- log.debug('selection', selection)


        local migs = nestedMigs.get_nested_migrations(migrations.root, selection)
        local flags = nestedMigs.get_prompt_answers(migs)
        local dry_run = utils.confirm_dry_run()

        -- If user cancelled the migration that close everything
        if dry_run then 
          local flat_flags = utils.flatten(flags)
          local flag_string = table.concat(flat_flags, " ")
          -- log.debug('flat_flags', flat_flags)
          -- log.debug('flat_flag_string', table.concat(flat_flags, " "))
          -- log.debug('migs', migs)

          actions.close(prompt_bufnr)
          local command = string.format("npx ng g @angular/core:%s %s %s", selection.ordinal, flag_string, dry_run)
          log.debug('command', command)

         -- vim.cmd("botright 15split | term " .. command) 
         presentTerm(command)

        else
          actions.close(prompt_bufnr)
          vim.notify_once("Action Cancelled by user")
        end

        -- vim.fn.system(command)
      end)
      return true
    end

  }):find()
end

vim.api.nvim_create_user_command('NgMigrate', function()
    
    M.list_migrations()
end, {})

return M;
