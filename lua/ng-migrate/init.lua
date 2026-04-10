local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values

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

M.list_migrations = function(opts)
  local root = get_workspace_root()

  if not root then
    vim.notify("Not angular workspace", vim.log.levels.ERROR)
    return
  end

  pickers.new(opts, {
    finder = finders.new_async_job({
      command_generator = function()
        return { "ng", "g", "@angular/core:ng-update", "--help" }
      end,
      cwd = root,
      entry_maker = function(line)
        -- return {
        --   display = parsed.key,
        --   ordinal = parsed.key,
        --   value = parsed,
        -- }

        log.debug('raw_line', line)

        -- 2. Use string matching (NOT JSON) to find the migration ID
        local id = line:match("([%w%-]*migration[%w%-]*)")

        -- 3. If the line doesn't contain a migration name, skip it
        if not id then return nil end

        -- 4. Return the valid entry for Telescope
        return {
          value = id,
          display = "🅰️  " .. id,
          ordinal = id
        }
      end
    }),

    -- sorts and filters the results
    sorter = config.generic_sorter(opts),

    previewer = previewers.new_buffer_previewer({
      title = "Docker Image Details",
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true,
          vim.tbl_flatten({ "Hello", "Every One", vim.split(vim.inspect(entry.value), "\n") })
        )
      end
    })

  }):find()
end

M.list_migrations()

return M;
