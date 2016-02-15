" keep track of vimrc setting
let s:updatetime = &updatetime

" keep track of scroll info start
let s:scroll_start = 0

function! s:get_name(bufnr)
  let bname = bufname(a:bufnr)
  let btype = getbufvar(a:bufnr, '&buftype')
  let name = '[No Name]'
  if len(bname) == 0 && len(btype) != 0
    let name = '['.btype.']'
  elseif len(bname) > 0
    let name = fnamemodify(bname, g:bufferline_fname_mod)
  endif
  if g:bufferline_pathshorten != 0
    let name = pathshorten(name)
  endif
  let name = substitute(name, "%", "%%", "g")
  return name
endfunction

function! s:format_name(bufnr, name, unlisted)
  let fname = ''
  if g:bufferline_show_bufnr != 0
    let fname = a:bufnr . ':'
  endif
  let fname .= a:name . (getbufvar(a:bufnr, '&mod') ? g:bufferline_modified : '')
  let fname .= a:unlisted ? g:bufferline_unlisted : ''
  if bufnr('%') == a:bufnr
    let fname = g:bufferline_active_buffer_left . fname . g:bufferline_active_buffer_right
  else
    let fname = g:bufferline_separator . fname . g:bufferline_separator
  endif
  return fname
endfunction

function! s:generate_names()
  let names = []
  let i = 1
  let last_buffer = bufnr('$')
  let current_buffer = bufnr('%')

  while i <= last_buffer
    let skip = !bufexists(i) || !buflisted(i) || len(getbufvar(i, "&buftype"))
    if !skip || i == current_buffer
      let name = s:get_name(i)

      if i == current_buffer
        let fname = s:format_name(i, name, skip)
        call add(names, [i, fname])
      elseif !skip
        let fname = s:format_name(i, name, 0)
        call add(names, [i, fname])
      endif
    endif
    let i += 1
  endwhile

  if len(names) > 1
    if g:bufferline_rotate == 1
      call bufferline#algos#fixed_position#modify(names)
    endif
  endif

  return names
endfunction

function! bufferline#get_echo_string()
  return g:bufferline_status_info.before
     \ . g:bufferline_status_info.current
     \ . g:bufferline_status_info.after
endfunction

function! bufferline#refresh_status()
  let g:bufferline_status_info.before = ''
  let g:bufferline_status_info.current = ''
  let g:bufferline_status_info.after = ''
  let names = s:generate_names()
  let curbuf = bufnr('%')
  let is_before = 1
  for val in names
    if is_before
      if curbuf != val[0]
        let g:bufferline_status_info.before .= val[1]
      else
        let g:bufferline_status_info.current = val[1]
        let is_before = 0
      endif
    else
      let g:bufferline_status_info.after .= val[1]
    endif
  endfor
  return ''
endfunction

function! bufferline#trim_status_info(width)
  let line = bufferline#get_echo_string()
  if len(line) < a:width
    return
  endif
  let before = g:bufferline_status_info.before
  let current = g:bufferline_status_info.current
  let after = g:bufferline_status_info.after
  let beg_i = len(before)
  let end_i = beg_i + len(current)
  let scr_i = s:scroll_start
  if beg_i < scr_i
    let scr_i = beg_i
  endif
  if end_i > (scr_i + a:width)
    let scr_i = end_i - a:width + 1
  endif
  if len(line[scr_i :]) < a:width
    let scr_i = len(line) - a:width + 1
  endif
  let g:bufferline_status_info.before = before[scr_i :]
  let beg_i__scr_i = beg_i - scr_i
  if beg_i__scr_i < 0
    let g:bufferline_status_info.current = current[-beg_i__scr_i :]
  endif
  let width__end_i = a:width - len(g:bufferline_status_info.before) - len(g:bufferline_status_info.current) - 1
  if width__end_i == -1
    let g:bufferline_status_info.after = '' " VimL sucks!
  else
    let g:bufferline_status_info.after = after[: width__end_i]
  endif
  let s:scroll_start = scr_i
endfunction

function! s:echo()
  call bufferline#refresh_status()

  " 12 is magical and is the threshold for when it doesn't wrap text anymore
  call bufferline#trim_status_info(&columns - 12)

  echo bufferline#get_echo_string()

  if &updatetime != s:updatetime
    let &updatetime = s:updatetime
  endif
endfunction

function! s:cursorhold_callback()
  call s:echo()
  autocmd! bufferline CursorHold
endfunction

function! s:refresh_au(updatetime)
  let &updatetime = a:updatetime
  autocmd bufferline CursorHold * call s:cursorhold_callback()
endfunction

function! bufferline#init_echo()
  augroup bufferline
    au!
    " events which output a message which should be immediately overwritten
    autocmd BufWinEnter,WinEnter,InsertLeave,VimResized * call s:refresh_au(1)
  augroup END
  autocmd CursorHold * call s:echo()
endfunction

function! bufferline#get_status_string(active_highlight, inactive_highlight)
  return
        \ '%#'.a:inactive_highlight.'#'
        \.'%{g:bufferline_status_info.before}'
        \.'%#'.a:active_highlight.'#'
        \.' %{g:bufferline_status_info.current} '
        \.'%#'.a:inactive_highlight.'#'
        \.'%{g:bufferline_status_info.after}'
endfunction
