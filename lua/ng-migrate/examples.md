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
