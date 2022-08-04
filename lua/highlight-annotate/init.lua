local M = {
  _hl_prefix = "HightligtAnnotateHl",
  _a_prefix = "HightligtAnnotateA",
  _namespace = vim.api.nvim_create_namespace("HightligtAnnotate"),
  _windows = {},
  _buffers = {},
}

local function create_default_highlights()
  local base03    = { "#002b36", 8  }
  local base02    = { "#073642", 0  }
  -- local base01    = { "#586e75", 10 }
  -- local base00    = { "#657b83", 11 }
  -- local base0     = { "#839496", 12 }
  -- local base1     = { "#93a1a1", 14 }
  local base2     = { "#eee8d5", 7  }
  local base3     = { "#fdf6e3", 15 }
  local yellow    = { "#b58900", 3  }
  local orange    = { "#cb4b16", 9  }
  local red       = { "#dc322f", 1  }
  local magenta   = { "#d33682", 5  }
  local violet    = { "#6c71c4", 13 }
  local blue      = { "#268bd2", 4  }
  local cyan      = { "#2aa198", 6  }
  local green     = { "#859900", 2  }

  local hls = {
    magenta = { main = magenta, complement = base2 },
    violet  = { main = violet,  complement = base2 },
    green   = { main = green,   complement = base2 },
    red     = { main = red,     complement = base2 },
    orange  = { main = orange,  complement = base2 },
    blue    = { main = blue,    complement = base2 },
    yellow  = { main = yellow,  complement = base02 },
    cyan    = { main = cyan,    complement = base02 },
    white   = { main = base3,   complement = base02 },
    black   = { main = base03,  complement = base2 },
  }

  for key, value in pairs(hls) do
    local vals = {
      bg      = value.main[1],
      ctermbg = value.main[2],
      fg      = value.complement[1],
      ctermfg = value.complement[2],
      default = true,
    }
    vim.api.nvim_set_hl(0, M._hl_prefix .. key, vals )
  end

  for key, value in pairs(hls) do
    local vals = {
      fg      = value.main[1],
      ctermfg = value.main[2],
      default = true,
    }
    vim.api.nvim_set_hl(0, M._a_prefix .. key, vals )
  end
end

local function list_styles(prefix)
  local all = vim.fn.getcompletion("", "highlight")
  local filtered = {}
  for _, name in ipairs(all) do
    if name:find(prefix) then
      table.insert(filtered, name:sub(#prefix + 1))
    end
  end
  return filtered
end

local function list_hls()
  local result = {}
  local window = vim.api.nvim_win_get_number(0)
  M._windows[window] = M._windows[window] or {}
  for i, m in ipairs(M._windows[window]) do
    result[i] = ("%d: %s /%s"):format(i, m[2], m[3])
  end
  return result
end

local function command_ha_hl(args)
  local pattern = nil
  local hl = nil

  if #args > 2 then
      vim.notify("max 2 parameters", vim.log.levels.ERROR)
      return
  end

  for _, arg in ipairs(args) do
    if arg:match('^/.*$') then
      if pattern then
        vim.notify("provide only one pattern", vim.log.levels.ERROR)
        return
      end
      pattern = arg:sub(2) -- strip leading /
    else
      if hl then
        vim.notify("provide only one highlight name", vim.log.levels.ERROR)
        return
      end
      hl = arg
    end
  end

  if not pattern then
    pattern = vim.fn.getreg("/")
  end
  if not hl then
    vim.notify("provide the highlight name", vim.log.levels.ERROR)
    return
  end

  vim.w.ha_matches = vim.w.ha_matches or {}
  local window = vim.api.nvim_win_get_number(0)
  local match = vim.fn.matchadd(M._hl_prefix .. hl, pattern)
  M._windows[window] = M._windows[window] or {}
  table.insert(M._windows[window], {match, hl, pattern})
end

local function complete_ha_hl(args)
  if #args > 2 then return end
  if #args == 2 and not vim.startswith(args[1], "/") then return end

  local last_arg = table.remove(args)
  return vim.tbl_filter(function(v) return vim.startswith(v, last_arg) end, list_styles(M._hl_prefix))
end

local function command_ha_list(args)
  if #args ~= 0 then
    vim.notify("no arguments pls", vim.log.levels.ERROR)
    return
  end

  for _, hl in ipairs(list_hls()) do
    print(hl)
  end
end

local function command_ha_del_hl(args)
  local window = vim.api.nvim_win_get_number(0)
  M._windows[window] = M._windows[window] or {}

  local removed = table.remove(M._windows[window], tonumber(args[1]))

  if removed then
    vim.fn.matchdelete(removed[1])
  else
    vim.notify("wrong hl to delete", vim.log.levels.ERROR)
  end
end

local function complete_ha_del_hl(args)
  if #args ~= 1 then return end
  return vim.tbl_filter(function(v) return vim.startswith(v, args[1]) end, list_hls())
end

local function command_ha_a(args)
  local hl = "magenta"

  if vim.tbl_contains(list_styles(M._a_prefix), args[1]) then
    hl = table.remove(args, 1)
  end

  local text = table.concat(args, " ")
  local opts = {
    virt_text     = { { " ■ " .. text, M._a_prefix .. hl } },
    virt_text_pos = "right_align"
  }
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  M._buffers[buf] = M._buffers[buf] or {}
  local extmark = vim.api.nvim_buf_set_extmark(0, M._namespace, row-1, 0, opts )
  M._buffers[buf][extmark] =  { hl, text }
end

local function complete_ha_a(args)
  if #args > 1 then return end

  local last_arg = table.remove(args)
  return vim.tbl_filter(function(v) return vim.startswith(v, last_arg) end, list_styles(M._a_prefix))
end

local function list_extmarks()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  return vim.api.nvim_buf_get_extmarks(0, M._namespace, { row-1, 0 }, { row-1, 0 }, {})
end

local function command_ha_del_a(args)
  local buf = vim.api.nvim_get_current_buf()
  local extmark = table.remove(args, 1)

  extmark = extmark or table.remove(list_extmarks(), 1)[1]
  extmark = tonumber(extmark)

  if extmark then
    M._buffers[buf][extmark] = nil
    vim.api.nvim_buf_del_extmark(0, M._namespace, extmark)
  end
end

local function complete_ha_del_a(args)
  if #args > 1 then return end

  local buf = vim.api.nvim_get_current_buf()
  local extmarks = {}

  for _, v in ipairs(list_extmarks()) do
    local extmark = v[1]
    local hl, text = unpack(M._buffers[buf][extmark])
    table.insert(extmarks, ("%d %s %s"):format(extmark, hl, text))
  end

  local last_arg = table.remove(args)
  return vim.tbl_filter(function(v) return vim.startswith(v, last_arg) end, extmarks)
end

local subcommands = {
  ["hl"]     = { command_ha_hl,     complete_ha_hl },
  ["list"]   = { command_ha_list,   nil },
  ["del-hl"] = { command_ha_del_hl, complete_ha_del_hl },
  ["a"]      = { command_ha_a,      complete_ha_a },
  ["del-a"]  = { command_ha_del_a,  complete_ha_del_a }
}

local function command_ha(opts)
  local args = opts.fargs
  local sc_name = table.remove(args, 1)

  local sc = subcommands[sc_name]

  if not sc then
    vim.notify("unknown subcommand " .. tostring(sc_name), vim.log.levels.ERROR)
    return
  end

  sc[1](args)
end

local function complete_ha(_, line)
  local args = vim.split(line, "%s+")
  local subcommand_names = vim.tbl_keys(subcommands)

  -- shift command name
  table.remove(args, 1)

  if #args == 1 then
    return vim.tbl_filter(function(v) return vim.startswith(v, args[1]) end, subcommand_names)
  end

  local sc_name = table.remove(args, 1)
  local sc = subcommands[sc_name]
  if sc and sc[2] then
    return sc[2](args)
  end
end

function M.setup()
  create_default_highlights()
  vim.api.nvim_create_user_command("HA", command_ha, { force = true, nargs = "*", complete = complete_ha })
end

return M
