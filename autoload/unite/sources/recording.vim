let s:save_cpo = &cpo| set cpo&vim
"=============================================================================
"Init
let g:unite_source_recording_directory =
  \ exists('g:unite_source_recording_directory') ? g:unite_source_recording_directory :
  \ g:unite_data_directory


function! s:_rf_recordings() "{{{
  if !filereadable(g:unite_source_recording_directory.'/'.'recording')
    return []
  endif
  return map(readfile(g:unite_source_recording_directory.'/'.'recording'), 'eval(v:val)')
endfunction
"}}}
let s:recordings = exists('s:recordings') ? s:recordings : s:_rf_recordings()

let s:save_register = ''

"-----------------------------------------------------------------------------

function! s:_wf_add_recording(char, recording_description) "{{{
  "let s:recordings = exists('s:recordings') ? s:recordings : s:_rf_recordings()
  exe 'let recording = [a:recording_description , @'. a:char. ']'
  call insert(s:recordings, recording)
  call unite#sources#recording#Write_recordingfile()
endfunction
"}}}

function! s:_jd_duplicate_recording_description(recording_description) "{{{
  for pkd in s:recordings
    if get(pkd, 0, '') ==# a:recording_description
      return 1
    endif
  endfor
endfunction
"}}}


function! unite#sources#recording#Write_recordingfile() "{{{
  if !isdirectory(g:unite_source_recording_directory)
    call mkdir(g:unite_source_recording_directory, 'p')
  endif
  call writefile(map(deepcopy(s:recordings), 'string(v:val)'), g:unite_source_recording_directory. '/'. 'recording')
endfunction
"}}}

function! unite#sources#recording#Export_recordings() "{{{
  return s:recordings
endfunction
"}}}

"=============================================================================
"Functions
function! unite#sources#recording#Begin(char) "{{{
  let recording_description = input('Unite-recording: Input recording description: ')
  if empty(recording_description) || s:_jd_duplicate_recording_description(recording_description)
    redraw!| echo 'Recording is canceled.'
    return
  endif
  exe 'let s:save_register = @'. a:char
  exe 'normal! q'. a:char
  let [s:now_used_char, s:now_used_recording_description] = [a:char, recording_description]
  aug unite_recording
    au!
    au CursorMoved * silent call <SID>__sence_finishedRecording()
  aug END
endfunction
"}}}
function! s:__sence_finishedRecording() "{{{
  exe 'if @'. s:now_used_char. ' == s:save_register'
    return
  endif
  call s:_wf_add_recording(s:now_used_char, s:now_used_recording_description)
  unlet s:now_used_char s:now_used_recording_description
  aug unite_recording
    au!
  aug END
endfunction
"}}}


function! unite#sources#recording#Save(char) "{{{
  let recording_description = input('Unite-recording: Input recording description: ')
  if empty(recording_description) || s:_jd_duplicate_recording_description(recording_description)
    redraw!| echo 'Save is canceled.'
    return
  endif
  call s:_wf_add_recording(a:char, recording_description)
endfunction
"}}}




"=============================================================================
"Unite define
function! unite#sources#recording#define() "{{{
  return s:source
  unlet s:source
endfunction
"}}}

let s:kind__add_recording = {}
let s:kind__add_recording.name = 'add_recording'
let s:kind__add_recording.default_action = 'add_recording'
let s:kind__add_recording.parents = []
let s:kind__add_recording.action_table = {}
let s:kind__add_recording.action_table.add_recording = {}
let s:kind__add_recording.action_table.add_recording.is_selectable = 1
function! s:kind__add_recording.action_table.add_recording.func(candidate) "{{{
  call unite#sources#recording#Begin(g:unite_source_recording_char)
endfunction
"}}}
call unite#define_kind(s:kind__add_recording)
unlet s:kind__add_recording

"-----------------------------------------------------------------------------
let s:source = {}
let s:source.name = 'recording'

function! s:source.gather_candidates(args, context) "{{{
  "let s:recordings = exists('s:recordings') ? s:recordings : s:_rf_recordings()
  let recordings = deepcopy(s:recordings)
  let format = '[%s] %s'
  call map(recordings, '{"word": printf(format, v:val[0], v:val[1]),
    \ "kind": "recording",
    \ "action__description": v:val[0],
    \ "action__recording": v:val[1],
    \ }')
  let cdds = recordings

  let candidate = {}
  let candidate.word = '[:Add recording:]'
  let candidate.kind = 'add_recording'
  call add(cdds, candidate)

  return cdds
endfunction
"}}}

"=============================================================================
let &cpo = s:save_cpo| unlet s:save_cpo
