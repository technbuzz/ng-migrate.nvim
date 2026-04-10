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

  print('Successfully loaded' .. vim.inspect(data))

  return data
end

local function create_loop()
  local data = read_file()

  print("--- Exercise 1: Finding Migrations ---")

  local migs = {}
  for name, _ in pairs(data.schematics) do
    if name:match("migration") then
      print("Found: " .. name)
      table.insert(migs, name)
    end
  end

  print(vim.inspect(migs))


  print("\n--- Exercise 2: Reading Descriptions ---")

  for name, details in pairs(data.schematics) do
    local desc = details.description
    local ver = details.version

    print(string.format("[%s] v%s: %s", name, ver, desc))
  end
end



create_loop()
