" keep track of vimrc setting
let s:updatetime = &updatetime

" keep track of scrollinf window start
let s:window_start = 0

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
    let is_listed = bufexists(i) && buflisted(i)
    if is_listed || i == current_buffer
      let name = s:get_name(i)

      let skip = 0
      for ex in g:bufferline_excludes
        if match(name, ex) > -1
          let skip = 1
          break
        endif
      endfor

      if i == current_buffer
        let fname = s:format_name(i, name, !is_listed || skip)
        let g:bufferline_status_info.current = fname
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
  let names = s:generate_names()
  let line = ''
  for val in names
    let line .= val[1]
  endfor

  let index = match(line, '\V'.g:bufferline_status_info.current)
  let g:bufferline_status_info.count = len(names)
  let g:bufferline_status_info.before = strpart(line, 0, index)
  let g:bufferline_status_info.after = strpart(line, index + len(g:bufferline_status_info.current))
  return line
endfunction

function! s:echo()
  if &filetype ==# 'unite'
    return
  endif

  let line = bufferline#get_echo_string()

  " 12 is magical and is the threshold for when it doesn't wrap text anymore
  let width = &columns - 12
  if g:bufferline_rotate == 2
    let current_buffer_start = stridx(line, g:bufferline_active_buffer_left)
    let current_buffer_end = stridx(line, g:bufferline_active_buffer_right)
    if current_buffer_start < s:window_start
      let s:window_start = current_buffer_start
    endif
    if current_buffer_end > (s:window_start + width)
      let s:window_start = current_buffer_end - width + 1
    endif
    let line = strpart(line, s:window_start, width)
  else
    let line = strpart(line, 0, width)
  endif

  echo line

  if &updatetime != s:updatetime
    let &updatetime = s:updatetime
  endif
endfunction

function! s:cursorhold_callback()
  call s:echo()
  autocmd! bufferline CursorHold
endfunction

function! s:refresh(updatetime)
  let &updatetime = a:updatetime
  autocmd bufferline CursorHold * call s:cursorhold_callback()
endfunction

function! bufferline#init_echo()
  augroup bufferline
    au!

    " events which output a message which should be immediately overwritten
    autocmd BufWinEnter,WinEnter,InsertLeave,VimResized * call s:refresh(1)
  augroup END

  autocmd CursorHold * call s:echo()
endfunction
