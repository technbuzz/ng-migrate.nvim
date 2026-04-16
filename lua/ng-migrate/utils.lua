
local M = {}

-- @return table | nil
M.read_json_file = function(path)
  local file = io.open(path, 'r')
  if not file then return nil end

  local content = file:read('*a')

  file:close()
  if content == "" then return nil end

  return vim.json.decode(content)
end

M.log_schema = function (schema)
  local props = schema.properties or {}

  for key, details in pairs(props) do
    local msg = string.format('%s: %s', key, details.description)
    print(msg)
  end
  
end

M.ask_bool = function(prompt,  cb) 
  vim.ui.select({ "Yes", "No" }, { primpt = prompt }, 
    function(choice)
      if choice then cb(choice == "Yes") end
    end
  )
end




-- M.ask_str = function(prompt, default, cb)
--   vim.ui.input({
--     prompt = prompt .. " ",
--     default = default 
--
--   })
--
--
--
-- end
--


return M
