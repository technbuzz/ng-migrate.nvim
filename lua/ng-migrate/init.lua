local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values
local action = require('telescope.actions')
local action_state = require('telescope.actions.state')


local utils = require('ng-migrate.utils')
local executor = require('ng-migrate.executor')

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
  -- NOTE: use fs.find & joinpath for proper implmentioan
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

local function get_nested_migrations(root, selection)
  local normalized = selection.details.schema:gsub("^%./", "")
  local sub_coll_path = root .. '/node_modules/@angular/core/schematics/' .. normalized
  local data = utils.read_json_file(sub_coll_path)

  if not data then
    print('❌ Could not find migrations' .. sub_coll_path)
    return
  end

  return data
end

local function extract_nested_prompts(schema)
  local props = schema.properties 
  -- log.debug('props', schema, 'props', props)

  if not props then
    print("No Props found")
    log.debug(vim.inspect(schema))
    return
  end

  local keys = {}
  for k in pairs(props) do
    table.insert(keys, k)
  end

  table.sort(keys)
  log.debug('sortedkeys', keys)

  for i, key in ipairs(keys) do
    local details = props[key]
    local prompt = details["x-prompt"]
    local p_type = details.type

    log.debug('key', key)
    log.debug('details', details)
    log.debug('prompt', prompt)
    log.debug('p_type', p_type)
    print(string.format("[%s] (%s): %s", key, p_type, prompt))
    log.debug(string.format("[%s] (%s): %s", key, p_type, prompt))
  end


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
        local lines = vim.split(vim.inspect(entry.details.description), "\n")
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)


        vim.api.nvim_set_option_value("wrap", true, { win = self.state.winid })
        vim.api.nvim_set_option_value("foldcolumn", "3", { win = self.state.winid })
      end
    }),

    attach_mappings = function(prompt_bufnr, _) 
      action.select_default:replace(function()
        local selection = action_state.get_selected_entry()

        local migration_name = selection.ordinal
        action.close(prompt_bufnr)


        local root = get_workspace_root()
        local sub_schema = get_nested_migrations(root, selection)
        local sub_det = extract_nested_prompts(sub_schema)

        -- executor.confirm_and_run(migration_name)


        -- log.debug('selected', selection)

      end)
      return true
    end

  }):find()
end

vim.api.nvim_create_user_command('NgMigrate', function()
    M.list_migrations()
end, {})

return M;
