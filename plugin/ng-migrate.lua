-- Add this to your main plugin setup or init.lua
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  command = "startinsert",
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert")
  end,
})

vim.print('Plugin works')
