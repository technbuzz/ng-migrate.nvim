
---@class Schematic
---@field description string
---@field factory string
---@field schema string
---@field aliases table

---@class Migration
---@field display string
---@field ordinal string
---@field details Schematic
--       "aliases": ["outputs"]

    --[[
    details = {
[plenary]     aliases = { "common-to-standalone" },
[plenary]     description = "Replaces CommonModule with individual imports from @angular/common",
[plenary]     factory = "./bundles/common-to-standalone-migration.cjs#migrate",
[plenary]     schema = "./migrations/common-to-standalone-migration/schema.json"
[plenary]   },
[plenary]   display = "🅰️  common-to-standalone-migration",
[plenary]   index = 7,
[plenary]   ordinal = "common-to-standalone-migration",
[plenary]   value = "Replaces CommonModule with individual imports from @angular/common"
--]]


---@class SchematicUI 
---@field path string
---@field type boolean | string 
---@field ['x-prompt'] string
---@field default boolean | string


--[[
  "properties": {
    "path": {
      "type": "string",
      "description": "Path relative to the project root which should be migrated",
      "x-prompt": "Which path in your project should be migrated?",
      "default": "./"
    },
    "format": {
      "type": "boolean",
      "description": "Enables reformatting of your templates",
      "x-prompt": "Should the migration reformat your templates?",
      "default": "true"
    }
  }
--]]

local M = {}

M.read_json_file = function(path)
  local file = io.open(path, 'r')
  if not file then return nil end

  local content = file:read('*a')

  file:close()
  if content == "" then return nil end

  return vim.json.decode(content)
end


M.confirm_dry_run= function() 
  local result = nil
  local opts = {
    "Preview (Dry Run)",
    "Execute (Writes to disk)",
    "Cancel"
  }

  vim.ui.select(opts, {prompt = "By default migration will run in dry run where no changes are made"},
    function(choice, idx)
      if not choice or choice == 'Cancel' then 
        print("Action Cancelled by user")
        result = nil
        return

      elseif idx == 1 then
        result = "-d"
        return
      end

      result = ""
    end
  )

  return result
end

local function camelToKebab(camel)
  local matched = string.gsub(camel, '(%u)', function(match)
    return '-' .. string.lower(match) 
  end)
  return matched
end

M.flatten = function(table_keys)
  local result = {}
  for key, value in pairs(table_keys) do
    table.insert(result, camelToKebab(key) ..' '..value)
  end
  return result
end

return M
