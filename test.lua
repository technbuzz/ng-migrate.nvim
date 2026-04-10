local function read_json_file(path)
  local file = io.open(path, 'r')
  if not file then return nil end

  local content = file:read('*a')

  file:close()
  if content == "" then return nil end
  return vim.json.decode(content)
end

local function run_test()
  local path = './test_data.json'
  local data = read_json_file(path)

  print('Successfully loaded' .. vim.inspect(data))

end

run_test()
