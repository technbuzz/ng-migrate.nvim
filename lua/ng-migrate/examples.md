      command_generator = function() 
        local target_path = vim.fn.expand("~/../../../package.json")
        return { "jq", "-c", ".dependencies | to_entries[]", target_path } 
      end,

