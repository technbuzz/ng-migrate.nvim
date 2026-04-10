local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values

local log = require('plenary.log'):new()
log.level = 'debug'

local M = {};

M.show_docker_images = function(opts)
  pickers.new(opts, {
    finder = finders.new_async_job({
      command_generator = function() 
        local target_path = vim.fn.expand("~//package.json")
        return { "jq", "-c", ".dependencies | to_entries[]", target_path } 
      end,

      entry_maker = function(entry)
        local parsed = vim.json.decode(entry)

        log.debug('parsed', parsed)
        return {
          display = parsed.key,
          ordinal = parsed.key,
          value = parsed,
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

M.show_docker_images()

return M;

