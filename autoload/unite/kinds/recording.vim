let s:save_cpo = &cpo| set cpo&vim
"=============================================================================
function! unite#kinds#recording#define() "{{{
  return s:kind
endfunction
"}}}

let s:kind = {}
let s:kind.name = 'recording'
let s:kind.default_action = 'set'
let s:kind.action_table = {}

"-----------------------------------------------------------------------------
let s:kind.action_table.execute = {}
let s:kind.action_table.execute.description = 'Yank to "g:unite_source_recording_char" register and Execute recording.'
function! s:kind.action_table.execute.func(candidate) "{{{
  exe 'let @'. g:unite_source_recording_char. " = '". a:candidate.action__recording. "'"
  exe 'normal! @'. g:unite_source_recording_char
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.set = {}
let s:kind.action_table.set.description = 'Yank to "g:unite source_recording_char" register.'
function! s:kind.action_table.set.func(candidate) "{{{
  exe 'let @'. g:unite_source_recording_char. " = '". a:candidate.action__recording. "'"
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.add = {}
let s:kind.action_table.add.description = 'Add recording.'
let s:kind.action_table.add.is_selectable = 1
function! s:kind.action_table.add.func(candidate) "{{{
  call unite#sources#recording#Begin(g:unite_source_recording_char)
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.append = {}
let s:kind.action_table.append.description = 'Append recording to "g:unite_source_recording_char" register.'
function! s:kind.action_table.append.func(candidate) "{{{
  exe 'let @'. g:unite_source_recording_char. " = '". a:candidate.action__recording. "'"
  exe 'let s:save_register = @'. g:unite_source_recording_char
  exe 'normal! q'. substitute(g:unite_source_recording_char, '\w', '\u\0', '')
  let [s:now_used_char, s:now_used_recording_description] = [g:unite_source_recording_char, a:candidate.action__description]
  aug recording
    au!
    au CursorMoved * silent call <SID>__sence_finishedRecordingAppending()
  aug END
endfunction
"}}}
function! s:__sence_finishedRecordingAppending() "{{{
  exe 'if @'. s:now_used_char. ' == s:save_register'
    return
  endif
  call s:___wf_append_recording(s:now_used_char, s:now_used_recording_description)
  unlet s:now_used_char s:now_used_recording_description
  aug recording
    au!
  aug END
endfunction
"}}}
function! s:___wf_append_recording(char, recording_description) "{{{
  for pkd in g:recordings
    if pkd[0] ==# a:recording_description
      exe 'let g:recordings[index(g:recordings, pkd)][1] = @'. g:unite_source_recording_char
      break
    endif
  endfor
  call unite#sources#recording#write_recordingfile()
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.delete = {}
let s:kind.action_table.delete.description = 'Delete recording.'
let s:kind.action_table.delete.is_quit = 0
let s:kind.action_table.delete.is_selectable = 1
let s:kind.action_table.delete.is_invalidate_cache = 1
function! s:kind.action_table.delete.func(candidate) "{{{
  for candidate in a:candidate
    call filter(g:recordings, 'v:val[0] !=# '. string(candidate.action__description))
    call unite#sources#recording#write_recordingfile()
  endfor
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.sort_ahead = {}
let s:kind.action_table.sort_ahead.description = 'Sort it ahead.'
let s:kind.action_table.sort_ahead.is_quit = 0
let s:kind.action_table.sort_ahead.is_invalidate_cache = 1
function! s:kind.action_table.sort_ahead.func(candidate) "{{{
  let i = s:_gn_idx_matching2description_1recordings(candidate)
  if i == 0
    return
  endif
  let t = g:recordings[i-1]
  let g:recordings[i-1] = g:recordings[i]
  let g:recordings[i] = t
  call unite#sources#recording#write_recordingfile()
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.sort_behind = {}
let s:kind.action_table.sort_behind.description = 'Sort it behind.'
let s:kind.action_table.sort_behind.is_quit = 0
let s:kind.action_table.sort_behind.is_invalidate_cache = 1
function! s:kind.action_table.sort_behind.func(candidate) "{{{
  let i = s:_gn_idx_matching2description_1recordings(a:candidate)
  if i == len(g:recordings)-1
    return
  endif
  let t = g:recordings[i+1]
  let g:recordings[i+1] = g:recordings[i]
  let g:recordings[i] = t
  call unite#sources#recording#write_recordingfile()
endfunction
"}}}

"=============================================================================
function! s:_gn_idx_matching2description_1recordings(candidate) "{{{
  for pkd in g:recordings
    if pkd[0] ==# a:candidate.action__description
      return index(g:recordings, pkd)
    endif
  endfor
endfunction
"}}}

"=============================================================================
let &cpo = s:save_cpo| unlet s:save_cpo
