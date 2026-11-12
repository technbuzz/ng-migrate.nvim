local function read_json_file(path)
  local file = io.open(path, 'r')
  if not file then return nil end

  local content = file:read('*a')

  file:close()
  if content == "" then return nil end
  return vim.json.decode(content)
end

local function read_file()
  local path = './test_data.json'
  local data = read_json_file(path)
  return data
end

local function create_loop()
  local data = read_file()

  local migs = {}
  for name, _ in pairs(data.schematics) do
    if name:match("migration") then
      table.insert(migs, name)
    end
  end

  -- Reading Descriptions
  -- NOTE: Why I need the following variables
  for name, details in pairs(data.schematics) do
    local desc = details.description
    local ver = details.version
  end
end



create_loop()
