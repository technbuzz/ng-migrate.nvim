local M = {}

local execute = function(migration_name, dry_run) 
  local flag = dry_run and " -d" or ""

  local cmd = "npx ng g @angular/core:" .. migration_name .. flag
  -- Open a horizontal split and run the command in a terminal
  -- 'split' opens the window, 'term' starts the process
  vim.cmd("botright 15split | term " .. cmd)

  -- Automatically enter insert mode so you can see output/interact
  vim.cmd('startinsert')
end

M.confirm_and_run = function(migration_name)
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
    end

    local dry_run = (choice == "Preview (Dry Run)") 
    execute(migration_name, dry_run)

  end)
end

return M
