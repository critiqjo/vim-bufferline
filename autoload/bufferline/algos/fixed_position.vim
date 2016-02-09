" pins the active buffer to a specific index in the list
function! bufferline#algos#fixed_position#modify(names)
  let counter = 0
  let current = bufnr('%')
  while a:names[g:bufferline_fixed_index][0] != current && counter < len(a:names)
    let first = remove(a:names, 0)
    call add(a:names, first)
    let counter += 1
  endwhile
endfunction

