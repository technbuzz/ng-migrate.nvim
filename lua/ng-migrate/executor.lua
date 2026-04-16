
local log = require('plenary.log'):new()
log.level = 'debug'


local M = {}

local execute = function(migration_name, dry_run, path)
  local flag = dry_run and " -d" or ""

  -- use path if it exits other wise ./
  local p = (path and path ~= "") and path or "./"

  local cmd = string.format("npx ng g @angular/core:%s --path=%s %s",migration_name, p, flag)
  log.debug('cmd', cmd)
  -- Open a horizontal split and run the command in a terminal
  -- 'split' opens the window, 'term' starts the process
  vim.cmd("botright 15split | term " .. cmd)
end

local function show_menu(migration_name, path)
  local opts = {
    "Preview (Dry Run)",
    "Execute (Writes to disk)",
    "Cancel"
  }

  vim.ui.select(opts, {
    prompt = "Run migration " .. migration_name .. " ?",
  }, function(choice)
    if not choice or choice == 'Cancel' then
      print("Action Cancelled by User")
      return
    end

    local dry_run = (choice == "Preview (Dry Run)") 
    execute(migration_name, dry_run, path)

  end)
end

M.confirm_and_run = function(migration_name)

  vim.ui.input({
    prompt = "Which directory do you want to migrate? ",
    default = "./",
    completion = "dir"
  }, function(input_path)
      log.debug('input_path', input_path)
      if not input_path then return end

      show_menu(migration_name, input_path)
    end)
end

return M
