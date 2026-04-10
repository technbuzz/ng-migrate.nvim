
local M = {}

M.read_json_file = function(path)
  local file = io.open(path, 'r')
  if not file then return nil end

  local content = file:read('*a')

  file:close()
  if content == "" then return nil end

  return vim.json.decode(content)
end

return M
