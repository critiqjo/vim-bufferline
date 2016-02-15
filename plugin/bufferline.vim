if exists('g:loaded_bufferline')
  finish
endif
let g:loaded_bufferline = 1

function! s:check_defined(variable, default)
  if !exists(a:variable)
    let {a:variable} = a:default
  endif
endfunction

call s:check_defined('g:bufferline_active_buffer_left', '[')
call s:check_defined('g:bufferline_active_buffer_right', ']')
call s:check_defined('g:bufferline_echo', 0)
call s:check_defined('g:bufferline_fixed_index', 1)
call s:check_defined('g:bufferline_fname_mod', ':t')
call s:check_defined('g:bufferline_modified', '+')
call s:check_defined('g:bufferline_pathshorten', 0)
call s:check_defined('g:bufferline_rotate', 0)
call s:check_defined('g:bufferline_separator', ' ')
call s:check_defined('g:bufferline_show_bufnr', 1)
call s:check_defined('g:bufferline_unlisted', '!')

let g:bufferline_status_info = {
      \ 'count': 0,
      \ 'before': '',
      \ 'current': '',
      \ 'after': '',
      \ }

if g:bufferline_echo
  call bufferline#init_echo()
endif
