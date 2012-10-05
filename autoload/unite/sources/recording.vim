let s:save_cpo = &cpo| set cpo&vim
"=============================================================================
"Init
let g:unite_source_recording_directory =
  \ exists('g:unite_source_recording_directory') ? g:unite_source_recording_directory :
  \ g:unite_data_directory

let g:unite_source_recording_char =
  \ exists('g:unite_source_recording_char') ? g:unite_source_recording_char :
  \ 'z'


function! s:_rf_recordings() "{{{
  if !filereadable(g:unite_source_recording_directory.'/'.'recording')
    return []
  endif
  return map(readfile(g:unite_source_recording_directory.'/'.'recording'), 'eval(v:val)')
endfunction
"}}}
let g:recordings = exists('g:recordings') ? g:recordings : s:_rf_recordings()

let s:save_register = ''

"-----------------------------------------------------------------------------
function! s:_wf_add_recording(char, recording_description) "{{{
  if !isdirectory(g:unite_source_recording_directory)
    call mkdir(g:unite_source_recording_directory, 'p')
  endif
  "let g:recordings = exists('g:recordings') ? g:recordings : s:_rf_recordings()
  exe 'let recording = [a:recording_description , @'. a:char. ']'
  call insert(g:recordings, recording)
  call writefile(map(deepcopy(g:recordings), 'string(v:val)'), g:unite_source_recording_directory. '/'. 'recording')
endfunction
"}}}

function! s:_jd_duplicate_recording_description(recording_description) "{{{
  for pkd in g:recordings
    if get(pkd, 0, '') ==# a:recording_description
      return 1
    endif
  endfor
endfunction
"}}}

"=============================================================================
"Functions
function! unite#sources#recording#Begin(char) "{{{
  let recording_description = input('Unite-recording: Input recording description: ')
  if empty(recording_description) || s:_jd_duplicate_recording_description(recording_description)
    return
  endif
  exe 'let s:save_register = @'. a:char
  exe 'normal! q'. a:char
  let [s:now_used_char, s:now_used_recording_description] = [a:char, recording_description]
  aug recording
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
  aug recording
    au!
  aug END
endfunction
"}}}


function! unite#sources#recording#Save(char) "{{{
  let recording_description = input('Unite-recording: Input recording description: ')
  if empty(recording_description) || s:_jd_duplicate_recording_description(recording_description)
    return
  endif
  call s:_wf_add_recordingcollection(a:char, recording_description)
endfunction
"}}}




"=============================================================================
"Unite define
function! unite#sources#recording#define() "{{{
  return s:source
endfunction
"}}}

let s:source = {}
let s:source.name = 'recording'
"let s:source.action_table = {}
"let s:source.action_table.recording = {}
"let s:source.action_table.recording.test = {}
"function! s:source.action_table.recording.test.func(candidate) "{{{
"  echo candidate
"endfunction
""}}}
"let s:source.default_action = {'*': 'yank'}

function! s:source.gather_candidates(args, context) "{{{
  "let g:recordings = exists('g:recordings') ? g:recordings : s:_rf_recordings()
  let recordings = deepcopy(g:recordings)
  let format = '[%s] %s'
  call map(recordings, '{"word": printf(format, v:val[0], v:val[1]),
    \ "kind": "recording",
    \ "action__recording": v:val[1],
    \ }')
  let cdds = recordings

  let candidate = {}
  let candidate.word = '[:Add recording:]'
  let candidate.kind = 'add_recording'
  call insert(cdds, candidate)

  return cdds
endfunction
"}}}

"-----------------------------------------------------------------------------
"=============================================================================
let &cpo = s:save_cpo| unlet s:save_cpo
