local M = {}
local Utils = require "utils"

M.empty_string = function()
  return ""
end

M.add_space = function(module, space_length)
  local space = string.rep(" ", space_length)
  return module .. space .. ""
end

M.statusline_location = function()
  local navic = require "nvim-navic"

  if not navic.is_available() then
    return ""
  end

  local location = navic.get_location()

  location = Utils.remove_quoted_strings(location)
  location = Utils.remove_callback_string(location)
  location = Utils.trim_anonymous_function(location)
  location = Utils.concat_string(location)
  location = Utils.reduce_by_window_width(location)

  return location
end

M.statusline_lsp_status = function()
  if not rawget(vim, "lsp") then
    return ""
  end

  local clients = vim.lsp.get_active_clients()

  for _, client in ipairs(clients) do
    local current_buf = vim.api.nvim_get_current_buf()
    if client.attached_buffers[current_buf] and client.name ~= "null-ls" then
      local separator = "%#St_LspStatus_Sep#" .. ""
      local lsp_icon = "%#St_LspStatus_Icon#" .. " "
      local lsp_text = "%#St_LspStatus_Text#" .. " " .. client.name

      return (separator .. lsp_icon .. lsp_text .. " ") or " "
    end
  end
end

-- UTF-8 문자열 디코딩 함수
local function utf8_decode(input)
  local pos = 1
  local len = #input
  local result = {}

  while pos <= len do
    local byte = string.byte(input, pos)
    local char_len, char

    if byte < 128 then
      char_len = 1
      char = string.char(byte)
    elseif byte >= 192 and byte < 224 then
      char_len = 2
      char = string.char(byte, string.byte(input, pos + 1))
    elseif byte >= 224 and byte < 240 then
      char_len = 3
      char = string.char(byte, string.byte(input, pos + 1), string.byte(input, pos + 2))
    else
      -- Handle other cases if needed
      char_len = 1
      char = "?"
    end

    table.insert(result, char)
    pos = pos + char_len
  end

  return table.concat(result)
end

M.statusline_git_branch = function(input)
  local icon_index = string.find(input, "")
  if icon_index and icon_index < #input then
    local branch_name_encoded = string.sub(input, icon_index + 1)

    -- 디코딩된 브랜치 이름을 사용하여 포맷
    local branch_name = utf8_decode(branch_name_encoded):gsub("?", "")

    if #branch_name > 20 then
      local first_six = string.sub(branch_name, 1, 3)
      local last_six = string.sub(branch_name, -6)
      local formatted_branch = "" .. first_six .. "..." .. last_six

      -- 함께 하이라이트된 문자열 반환
      return "%#St_gitIcons#" .. formatted_branch
    else
      -- 원래 문자열 반환
      return input
    end
  else
    -- 원래 문자열 반환
    return input
  end
end

M.statusline_git_branch_v2 = function(input)
  local icon_index = string.find(input, "")
  if icon_index and icon_index < #input then
    local branch_name_encoded = string.sub(input, icon_index + 1)
    local branch_name = utf8_decode(branch_name_encoded):gsub("?", "")

    if #branch_name > 20 then
      return ""
    else
      return input
    end
  else
    return input
  end
end

return M
