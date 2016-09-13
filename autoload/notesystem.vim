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

    let l:target = simplify(l:notes_dir ."/". l:noteDir ."/". l:noteFname)

    " If the file doesn't exist then create a pre-populated buffer.  If it
    " does exist then just open it.
    exec 'e ' . l:target
    if empty(glob(l:target))
        " open a new buffer for the new note and insert the title
        call setline(line('.'), getline('.') . 'tags:  ')
        let l:time = strftime('%Y-%m-%d %H:%M:%S %Z')
        call append(line('.'), ['created: ' . l:time . '  ',
                    \ 'modified: ' . l:time . '  ',
                    \ '',
                    \ '# '.a:noteName,
                    \ '', ''])
        normal! G
    else
        echom 'File already exists! Opening...'
    endif

    " create a link and put it in register l
    let l:link = simplify("/". l:noteDir ."/". l:noteFname)
    let l:link = printf("[%s](%s)", a:noteName, l:link)
    let @l = l:link

endfunction


function! notesystem#InsertAssets(sourcePaths)
    exec "py3 notesystem.insert_assets('". a:sourcePaths. "')"
endfunction


function! s:ag_handler(lines)
    if len(a:lines) < 2 | return | endif

    let [key, line] = a:lines[0:1]
    let [file, line, col] = split(line, ':')[0:2]
    let cmd = get({'ctrl-x': 'split', 'ctrl-v': 'vertical split', 'ctrl-t': 'tabe'}, key, 'e')
    execute cmd escape(g:notes_dir.'/'.file, ' %#\')
    execute line
    execute 'normal!' col.'|zz'
endfunction

function! notesystem#FuzzyGrepNotes(regex)
    if a:regex == ''
        let regex = '"^.*$"'
    else
        let regex = '"'.escape(a:regex, '"\').'"'
    endif

    let curdir = getcwd()
    exec 'cd '.g:notes_dir
    call fzf#run({
                \ 'source': 'ag --nogroup --nobreak --noheading --nocolor --column -G "md|taskpaper|rst" '.regex,
                \ 'sink*':    function('s:ag_handler'),
                \ 'options': '-x --ansi --expect=ctrl-t,ctrl-v,ctrl-x --no-multi --color hl:68,hl+:110',
                \ 'down':    '50%'
                \ })
    exec 'cd '.curdir
endfunction

function! notesystem#GrepNotes(regex)
    let l:gp = &grepprg
    let &grepprg='ag --nogroup --nocolor --column -G "md\|rst\|taskpaper" $* ' . fnameescape(g:notes_dir)
    exec 'silent grep! ' . a:regex
    let &grepprg = l:gp
    copen
endfunction

function! notesystem#OpenNote()
    " let l:cwd = getcwd()
    " exec 'lcd ' . g:notes_dir
    " call inputsave()
    " let l:note = input('Note: ', '', 'file')
    " let l:note = substitute(l:note, '/ *$', '', '')
    " call inputrestore()
    " exec 'lcd ' . l:cwd

    " if l:note == ''
        exec 'CtrlP '.g:notes_dir
    " else
    "     exec 'edit '.g:notes_dir.'/'.l:note
    " endif
endfunction

