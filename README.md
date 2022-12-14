# highlight-annotate.nvim

Highlight-annotate.nvim is a plugin for aiding reading and analyzing text
files such as logs or program sources.

The [highlights](#highlight) and [annotations](#annotate) are not persistent
and last only for the current editing session.


## Install

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { 'ivyl/highlight-annotate.nvim', config = function()
  require'highlight-annotate'.setup({})
end }
```


## Docs

[`:help highlight-annotate.txt`](doc/highlight-annotate.txt)

## Highlight

Local to window.

`:HA hl`

![Preview](https://i.imgur.com/EhZEtev.gif)

`:HA list`

`:HA del-hl`


## Annotate

Local to buffer.

`:HA a`

![Preview](https://i.imgur.com/NjTHn6P.gif)

`:HA del-a`


## Search Annotations

Requires [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

```lua
local telescope = require 'telescope'
-- regular telescope setup goes here

telescope.load_extension('highlight-annotate')
vim.keymap.set('n', '<leader>fa', telescope.extensions["highlight-annotate"].annotations)
```

`:Telescope highlight-annotate annotations` or use the mapping.

![Preview](https://i.imgur.com/8RD9CXF.gif)
