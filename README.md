# vim-bufferline

Super simple vim plugin to show the list of buffers in the command bar.

## Screenshots

#### In statusline

TODO

##### Configuration:

```vim
autocmd BufEnter *
    \ let &statusline='%{bufferline#refresh_status()}' .
        \ bufferline#get_status_string('StatusLine', 'StatusLineNC')
```

#### In command bar

TODO

##### Configuration:

```vim
let g:bufferline_echo = 1
```

#### In tabline (using [lightline.vim](https://github.com/itchyny/lightline.vim))

![screenshot](https://cloud.githubusercontent.com/assets/1436441/13049947/53024a3e-d416-11e5-992d-bcc4e9fe8f0f.png)

##### Configuration:

```vim
let g:bufferline_active_buffer_left = ''
let g:bufferline_active_buffer_right = ''
let g:bufferline_show_bufnr = 0
let g:bufferline_fname_mod = ':~:.'
let g:bufferline_pathshorten = 1

let g:lightline = {
    \   'tab': {
    \     'active': ['tabnum'],
    \     'inactive': ['tabnum']
    \   },
    \   'tabline': {
    \     'left': [ ['tabs'], ['bufferline'] ],
    \     'right': [ ['fileencoding'] ]
    \   },
    \   'component': {
    \     'bufferline': '%{MyBufferlineRefresh()}' . bufferline#get_status_string('TabLineSel', 'LightLineLeft_tabline_tabsel_1'),
    \     'fileencoding': '%{&fenc}',
    \   }
    \ }

function! MyBufferlineRefresh()
  call bufferline#refresh_status()
  let rlen = 4*tabpagenr('$') + len(&fenc) + 8
  call bufferline#trim_status_info(&columns - rlen)
  return ''
endfunction
```

## Installation

* [pathogen](https://github.com/tpope/vim-pathogen)

  ```sh
  $ git clone https://github.com/critiqjo/vim-bufferline ~/.vim/bundle/vim-bufferline
  ```

* [neobundle](https://github.com/Shougo/neobundle.vim)

  ```vim
  NeoBundle 'critiqjo/vim-bufferline'
  ```

* [vundle](https://github.com/gmarik/vundle)

  ```vim
  Plugin 'critiqjo/vim-bufferline'
  ```

* [vim-plug](https://github.com/junegunn/vim-plug)

  ```vim
  Plug 'critiqjo/vim-bufferline'
  ```

## Credits

The [original](https://github.com/bling/vim-bufferline) author was Bailey Ling, who was inspired by the [buftabs](http://www.vim.org/scripts/script.php?script_id=1664) script.

## License

MIT License. Copyright (c) 2013 Bailey Ling.
