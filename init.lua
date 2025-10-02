--------------------------------------------------------------------------------
--- Options
--------------------------------------------------------------------------------
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.sw = 2
vim.opt.ts = 2
vim.opt.wrap = false
vim.opt.hls = false
vim.opt.colorcolumn = "80"
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.path = "**"
vim.opt.swapfile = false
vim.opt.makeprg = "cmake --build $*"
vim.opt.hidden = true

--------------------------------------------------------------------------------
--- Globals
--------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.netrw_banner = false

--------------------------------------------------------------------------------
--- Keymap
--------------------------------------------------------------------------------

-- to to ctag
vim.keymap.set("n", "gt", 
	function() 
		vim.cmd("norm! yiw") 
		vim.cmd("tag "..vim.fn.getreg('"'))
	end,
	({ desc = "Go to tag of word under cursor" })
)

vim.keymap.set("n", "<leader>dn", function() vim.diagnostic.goto_next() end)
vim.keymap.set("n", "<leader>dp", function() vim.diagnostic.goto_next() end)
vim.keymap.set("n", "<leader>bp", function() vim.cmd("bp") end)
vim.keymap.set("n", "<leader>bn", function() vim.cmd("bn") end)
vim.keymap.set("n", "<leader>ls", function() vim.cmd("ls") end)
vim.keymap.set("n", "<leader>ff", function() vim.cmd("Explore") end)

--------------------------------------------------------------------------------
--- LSP
--------------------------------------------------------------------------------
-- grn in Normal mode maps to vim.lsp.buf.rename()
-- grr in Normal mode maps to vim.lsp.buf.references()
-- gri in Normal mode maps to vim.lsp.buf.implementation()
-- gO in Normal mode maps to vim.lsp.buf.document_symbol() (this is analogous to the gO mappings in help buffers and :Man page buffers to show a “table of ontents”)
-- gra in Normal and Visual mode maps to vim.lsp.buf.code_action()
-- CTRL-S in Insert and Select mode maps to vim.lsp.buf.signature_help()
-- [d and ]d move between diagnostics in the current buffer ([D jumps to the first diagnostic, ]D jumps to the last)

vim.lsp.config.clangd = {
  cmd = { 'clangd', '--background-index' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt' },
  filetypes = { 'c', 'cpp' },
}

vim.lsp.config.luals = {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luarc.jsonc' },
  filetypes = { 'lua' },
}

vim.lsp.config.marksman = {
  cmd = { 'marksman', 'server' },
  root_markers = { '.git', '.marksman.toml' },
  filetypes = { 'markdown' },
}

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  }
})

vim.lsp.enable({ 'clangd', 'luals', 'marksman' })

--------------------------------------------------------------------------------
--- Auto Commands
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('text/Document/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
      vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end)
    end
    pcall(vim.treesitter.start, ev.buf)
  end
})

--------------------------------------------------------------------------------
--- Statusline 
--------------------------------------------------------------------------------

local function git_branch()
  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
  if string.len(branch) > 0 then
    return branch
  else
    return ":"
  end
end

local function statusline()
  local set_color_1 = "%#PmenuSel#"
  local branch = git_branch()
  local set_color_2 = "%#LineNr#"
  local file_name = " %f"
  local modified = "%m"
  local align_right = "%="
  local fileencoding = " %{&fileencoding?&fileencoding:&encoding}"
  local fileformat = " [%{&fileformat}]"
  local filetype = " %y"
  local percentage = " %p%%"
  local linecol = " %l:%c"

  return string.format(
    "%s %s %s%s%s%s%s%s%s%s%s",
    set_color_1,
    branch,
    set_color_2,
    file_name,
    modified,
    align_right,
    filetype,
    fileencoding,
    fileformat,
    percentage,
    linecol
  )
end

vim.opt.statusline = statusline()
