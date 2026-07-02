      command_generator = function() 
        local target_path = vim.fn.expand("~/../../../package.json")
        return { "jq", "-c", ".dependencies | to_entries[]", target_path } 
      end,

      command_generator = function()
        return { "ng", "g", "@angular/core:ng-update", "--help" }
      end,

        -- return {
        --   display = parsed.key,
        --   ordinal = parsed.key,
        --   value = parsed,
        -- }


:nmap <leader>rr :lua package.loaded['ng-migrate'] = nil; require('ng-migrate').list_migrations()<CR>


### Simple Example
```lua

    
      pickers.new(opts, {
        -- Somethings that finds entries to display
        finder = finders.new_table({
          "Yes",
          "No",
          "Maybe",
          "Perhaps"
        }), 

        -- sort and filters them, user expected to pre configure sorter in theri
        -- config when they first install Telescope. And we can use the generic
        -- sorter
        sorter = config.generic_sorter(opts) 

  }):find()
```



### Complex example with object

```lua
M.demo = function(opts)
  pickers.new(opts, {
    -- Somethings that finds entries to display
    finder = finders.new_table({
      results = {
        { name = "Yes", value = { 1,2,3,4,5 }},
        { name = "No", value = { 1,2,3,4,5 }},
        { name = "Maybe", value = { 1,2,3,4,5 }},
        { name = "Perhaps", value = { 1,2,3,4,5 }}
      },
      entry_maker = function(entry)
        return {
          display = entry.name,
          -- sorting filtering key
          ordinal = entry.name,
          value = entry
        }
      end,
    }),

    -- Teaches telescope how to display complex objects 
    -- Simple ones were

    -- sort and filters them, user expected to pre configure sorter in theri
    -- config when they first install Telescope. And we can use the generic
    -- sorter
    sorter = config.generic_sorter(opts),
    -- gives us temp buffer to write stuff to
    previewer = previewers.new_buffer_previewer({
      title = "Item Details",
      -- grab hold of the buffer to write to
      define_preview = function(self, entry)
        -- writes to the buffer
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, false, 
        vim.tbl_flatten({ "hello", "World", vim.split(vim.inspect(entry.value), "\n") })
      )

      end,
    }),


  }):find()
end
```
