local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values

local M = {};

M.show_docker_images = function(opts)
  pickers.new(opts, {
    finder = finders.new_table({
      results = {

        { name = "Yes",      value = { 1, 2, 3, 4, 5 } },
        { name = "No",       value = { 1, 2, 3, 4, 5 } },
        { name = "Maybe",    value = { 1, 2, 3, 4, 5 } },
        { name = "Definitely", value = { 1, 2, 3, 4, 5 } }
      },
      entry_maker = function(entry)
        return {
          display = entry.name,
          ordinal = entry.name,
          value = entry.value,
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

