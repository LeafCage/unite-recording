if exists('g:loaded_unite_recording') || $SUDO_USER != '' | finish| endif
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================
"Variables
let g:unite_source_recording_char =
  \ exists('g:unite_source_recording_char') ? g:unite_source_recording_char :
  \ 'z'

"-----------------------------------------------------------------------------
"Interface
command! -nargs=0 UniteRecordingBegin    call unite#sources#recording#Begin(g:unite_source_recording_char)
command! -nargs=? UniteRecordingSave     call unite#sources#recording#Save(<q-args>)

noremap <silent><Plug>(unite-recording-execute)     :exe 'normal! @'. g:unite_source_recording_char<CR>

"=============================================================================
let g:loaded_unite_recording = 1
let &cpo = s:save_cpo| unlet s:save_cpo
