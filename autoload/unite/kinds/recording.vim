let s:save_cpo = &cpo| set cpo&vim
"=============================================================================

let s:recordings = unite#sources#recording#Export_recordings()
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
  let s = a:candidate.action__recording
  exe 'let @'. g:unite_source_recording_char. ' = s'
  exe 'normal! @'. g:unite_source_recording_char
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.set = {}
let s:kind.action_table.set.description = 'Yank to "g:unite source_recording_char" register.'
function! s:kind.action_table.set.func(candidate) "{{{
  let s = a:candidate.action__recording
  exe 'let @'. g:unite_source_recording_char. ' = s'
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
  let s = string(a:candidate.action__recording)
  exe 'let @'. g:unite_source_recording_char. ' = s'
  let s:save_register = eval('@'. g:unite_source_recording_char)
  exe 'normal! q'. substitute(g:unite_source_recording_char, '\w', '\u\0', '')
  let [s:now_used_char, s:now_used_recording_description] = [g:unite_source_recording_char, a:candidate.action__description]
  aug unite_recording
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
  aug unite_recording
    au!
  aug END
endfunction
"}}}
function! s:___wf_append_recording(char, recording_description) "{{{
  for pkd in s:recordings
    if pkd[0] ==# a:recording_description
      exe 'let s:recordings[index(s:recordings, pkd)][1] = @'. g:unite_source_recording_char
      break
    endif
  endfor
  call unite#sources#recording#Write_recordingfile()
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.revise_recording = {}
let s:kind.action_table.revise_recording.description = 'Revise recording.'
let s:kind.action_table.revise_recording.is_invalidate_cache = 1
function! s:kind.action_table.revise_recording.func(candidate) "{{{
  silent exe 'belowright 3split +setl\ ft=revise-recording [revise-recording]'
  exe 'let @'. g:unite_source_recording_char. ' = '. string(a:candidate.action__recording)
  exe 'put '. g:unite_source_recording_char
  nnoremap <buffer>q     :bd!<CR>
  1delete _
  echo 'unite-recording: 次のバッファを:writeすると変更が反映されます。'
  let b:unite_recording_description = a:candidate.action__description
endfunction
"}}}
aug revise_recording
  au BufWriteCmd \[revise-recording]   call <SID>Revise_write()
  au BufLeave \[revise-recording]     redraw!| echo ''| silent bd!
aug END
function! s:Revise_write() "{{{
  let i = s:_gn_idx_matching2description_1recordings(b:unite_recording_description)
  let s:recordings[i][1] = join(getline(1, '$'), '')
  call unite#sources#recording#Write_recordingfile()
  redraw!| echo ''| silent bd!
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.revise_description = {}
let s:kind.action_table.revise_description.description = 'Revise description.'
let s:kind.action_table.revise_description.is_invalidate_cache = 1
function! s:kind.action_table.revise_description.func(candidate) "{{{
  let i = s:_gn_idx_matching2description_1recordings(a:candidate)
  let d = input('', s:recordings[i][0])
  if empty(d)
    return
  endif
  let s:recordings[i][0] = d
  call unite#sources#recording#Write_recordingfile()
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
    call filter(s:recordings, 'v:val[0] !=# '. string(candidate.action__description))
    call unite#sources#recording#Write_recordingfile()
  endfor
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.sort_ahead = {}
let s:kind.action_table.sort_ahead.description = 'Sort it ahead.'
let s:kind.action_table.sort_ahead.is_quit = 0
let s:kind.action_table.sort_ahead.is_invalidate_cache = 1
function! s:kind.action_table.sort_ahead.func(candidate) "{{{
  let i = s:_gn_idx_matching2description_1recordings(a:candidate)
  if i == 0
    return
  endif
  let t = s:recordings[i-1]
  let s:recordings[i-1] = s:recordings[i]
  let s:recordings[i] = t
  call unite#sources#recording#Write_recordingfile()
endfunction
"}}}

"-----------------------------------------------------------------------------
let s:kind.action_table.sort_behind = {}
let s:kind.action_table.sort_behind.description = 'Sort it behind.'
let s:kind.action_table.sort_behind.is_quit = 0
let s:kind.action_table.sort_behind.is_invalidate_cache = 1
function! s:kind.action_table.sort_behind.func(candidate) "{{{
  let i = s:_gn_idx_matching2description_1recordings(a:candidate)
  if i == len(s:recordings)-1
    return
  endif
  let t = s:recordings[i+1]
  let s:recordings[i+1] = s:recordings[i]
  let s:recordings[i] = t
  call unite#sources#recording#Write_recordingfile()
endfunction
"}}}

"=============================================================================
function! s:_gn_idx_matching2description_1recordings(candidate6description) "{{{
  let description = type(a:candidate6description)==type({}) ?
    \ a:candidate6description.action__description : a:candidate6description
  for pkd in s:recordings
    if pkd[0] ==# description
      return index(s:recordings, pkd)
    endif
  endfor
endfunction
"}}}

"=============================================================================
let &cpo = s:save_cpo| unlet s:save_cpo
