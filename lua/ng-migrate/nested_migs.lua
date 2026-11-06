local utils = require "ng-migrate.utils"
local log = require('plenary.log'):new() 

log.level = 'debug'


local M = {}

--- @param rootCollectionPath string
--- @param selection Migration
--- @return SchematicUI | nil
M.get_nested_migrations = function(rootCollectionPath, selection)
  local normal = selection.details.schema:gsub("^%./", "/")
  local rootDir = vim.fs.dirname(rootCollectionPath)

  local schema_path = rootDir .. normal
  local data = utils.read_json_file(schema_path)
  -- log.debug('sub data', data)

  if not data or not data.properties then
    print('❌ Could not find migrations' .. schema_path)
    return
  end

  return data.properties
end



--- @param prompts SchematicUI[]
--- @returns table
M.get_prompt_answers = function(prompts)
  local result = {}
  local pointer = 1

  local keys = {}
  for key, _ in pairs(prompts) do
    table.insert(keys, key)
  end



  local function run_prompt()
    local current_key = keys[pointer]
    local current = prompts[current_key]

    -- exit sequence
    if pointer > #keys then
      return
    end

    local prompt_key = '--'..current_key

    local function on_complete(value)
      result[prompt_key] = value
      pointer = pointer + 1
      run_prompt()
    end

    if current.type == 'boolean' then
      vim.ui.select({ 'true', 'false' }, { prompt = current['x-prompt'] }, function(choice)
        vim.cmd("clear")
    vim.cmd("redraw!")
          on_complete(choice)
      end)
    end

    if current.type == 'string' then
      vim.ui.input({ prompt = current['x-prompt'], default = current.default }, function(input)
        on_complete(input)
      end)
    end -- end if
  end

  run_prompt()

  -- Return nil if user cancels otherwise options table
  return result
end -- end function


return M
