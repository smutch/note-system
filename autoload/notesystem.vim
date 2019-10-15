py3 import notesystem

function! notesystem#NewNote(noteName, standalone)

    " sanitise note name
    exec 'py3 notesystem.slugify("' . a:noteName . '")'
    let l:noteFname = l:slug . '.md'

    if a:standalone
        let l:notes_dir = getcwd()
    else
        let l:notes_dir = g:notes_dir
    endif

    " get the target directory of the new note
    let l:cwd = getcwd()
    exec 'lcd ' . l:notes_dir
    call inputsave()
    let l:noteDir = input('Note dir: ', '', 'dir')
    call inputrestore()
    exec 'lcd ' . l:cwd

    let l:date = strftime('%Y%m%d')
    let l:target = simplify(l:notes_dir ."/". l:noteDir ."/". l:date ."-". l:noteFname)

    " If the file doesn't exist then create a pre-populated buffer.  If it
    " does exist then just open it.
    exec 'e ' . l:target
    if empty(glob(l:target))
        " open a new buffer for the new note and insert the title
        call setline(line('.'), getline('.') . '---')
        let l:time = strftime('%Y-%m-%d %H:%M:%S %Z')
        call append(line('.'), ['tags: ""',
                    \ 'created: "' . l:time . '"',
                    \ '...',
                    \ '',
                    \ '# '.a:noteName,
                    \ '', ''])
        normal! ggj6la
    else
        echom 'File already exists! Opening...'
    endif

    " create a link and put it in register l
    let l:link = simplify("/". l:noteDir ."/". l:date ."-". l:noteFname)
    let l:link = printf("[%s](%s)", a:noteName, l:link)
    let @l = l:link

endfunction


function! notesystem#InsertAssets(sourcePaths)
    exec "py3 notesystem.insert_assets('". a:sourcePaths. "')"
endfunction


function! s:result_to_dict(line, with_column)
  let parts = split(a:line, ':')
  let text = join(parts[(a:with_column ? 3 : 2):], ':')
  let dict = {'filename': &acd ? fnamemodify(parts[0], ':p') : parts[0], 'lnum': parts[1], 'text': text}
  if a:with_column
    let dict.col = parts[2]
  endif
  return dict
endfunction

function! s:notes_handler(lines)
  let actions = {
              \ 'ctrl-t': 'tab split',
              \ 'ctrl-s': 'split',
              \ 'ctrl-x': 'NewNote',
              \ 'ctrl-v': 'vsplit' }

  let query = a:lines[0]
  let cmd = get(actions, a:lines[1], 'e')

  if cmd == 'NewNote'
      execute cmd query
  else
      let hit = s:result_to_dict(a:lines[2], 1)
      try
          execute cmd g:notes_dir.'/'.escape(hit.filename, ' %#\')
      catch
      endtry
  endif

endfunction

function! notesystem#Notes(query, fullscreen, subdir)
    let dir = g:notes_dir . '/' . a:subdir
    let opts = {
                \ 'source':  'rg --no-heading --color=always --column "'.a:query.'"',
                \ 'dir': dir,
                \ 'options': '--print-query --ansi --prompt "NOTES> " '.
                \            '--delimiter : --nth 4.. '.
                \            '--multi --bind=alt-a:select-all,alt-d:deselect-all '.
                \            '--expect=ctrl-x,ctrl-t,ctrl-s,ctrl-v',
                \ 'sink*': function('s:notes_handler')
                \}

    if a:fullscreen
        call fzf#run(fzf#vim#with_preview(opts, 'right:50%', '?'))
    else
        call fzf#run(fzf#vim#with_preview(opts, 'up:60%', '?'))
    endif
endfunction


function! notesystem#OpenNote(fullScreen, subdir)
    let dir = g:notes_dir . '/' . a:subdir
    let opts = {'dir': dir}
    call fzf#vim#files(
                \ '', 
                \ a:fullScreen ? fzf#vim#with_preview(opts, 'right:50%', '?')
                \              : fzf#vim#with_preview(opts, 'up:60%:hidden', '?'),
                \ a:fullScreen)
endfunction


function! notesystem#History(fullScreen)
    let opts = {
                \ 'source':  "gfind . -type f -a \\( -name '*.md' -o -name '*.taskpaper' \\) -printf '%T+\t%p\n' | sort -r | cut -f 2",
                \ 'sink': 'edit',
                \ 'dir': g:notes_dir,
                \ 'options': '--reverse'
                \ }

  if a:fullScreen
      call fzf#run(fzf#vim#with_preview(opts, 'right:50%', '?'))
  else
      call fzf#run(fzf#vim#with_preview(opts, 'up:60%:hidden', '?'))
  endif
endfunction
