local M = {}

local ui = require "core"

local default_configs = {
  statusline = function(modules)
    modules[3] = ui.statusline_git_branch_v2(modules[3])
    modules[4] = ui.add_space(modules[4], 1)
    modules[5] = ui.statusline_location()
    modules[7] = ui.add_space(modules[7], 1)
    modules[8] = ui.statusline_lsp_status()
  end,
  tabufline = function(modules)
    modules[1] = ui.empty_string()
    modules[4] = ui.empty_string()
  end,
}

M.configs = {}

M.setup = function(configs)
  M.configs = vim.tbl_extend("force", {}, default_configs, configs or {})
end

return M.configs
