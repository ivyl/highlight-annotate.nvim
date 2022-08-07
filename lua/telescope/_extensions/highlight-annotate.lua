local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local ha = require('highlight-annotate')

local function make_display(entry)
  local display = (" ■ %s"):format(entry.value[2][2])
  return display, { { { 0, 5 }, ha._a_prefix .. entry.value[2][1] } }
end

local function go_annotations()
  local annotations = ha._list_annotations()

  pickers.new({}, {
    prompt_title = "jump to annotation",
    finder = finders.new_table {
      results = annotations,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = ("%s: %s"):format(entry[2][1], entry[2][2]),
          lnum = entry[1][2] + 1,
        }
      end
    },
    sorter = conf.generic_sorter(),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
      end)
      return true
    end
  }):find()
end

return require("telescope").register_extension {
  setup = function(ext_config, config) end,
  exports = {
    annotations = go_annotations
  },
}
