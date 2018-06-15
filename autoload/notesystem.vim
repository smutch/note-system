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


function! notesystem#SearchNotes(query, fullScreen)
    let opts = {'dir': g:notes_dir}
    call fzf#vim#grep(
                \ 'rg --no-heading --color=always "'.a:query.'"',
                \ 0,
                \ a:fullScreen ? fzf#vim#with_preview(opts, 'right:50%', '?')
                \              : fzf#vim#with_preview(opts, 'up:60%:hidden', '?'),
                \ a:fullScreen)
endfunction


function! notesystem#OpenNote(fullScreen)
    let opts = {'dir': g:notes_dir}
    call fzf#vim#files(
                \ '', 
                \ a:fullScreen ? fzf#vim#with_preview(opts, 'right:50%', '?')
                \              : fzf#vim#with_preview(opts, 'up:60%:hidden', '?'),
                \ a:fullScreen)
endfunction


function! notesystem#History()
    call fzf#run({
                \ 'source':  "gfind . -type f -a \\( -name '*.md' -o -name '*.taskpaper' \\) -printf '%T+\t%p\n' | sort -r | cut -f 2",
                \ 'sink': 'edit',
                \ 'dir': g:notes_dir,
                \ 'options': '--reverse'
                \ })
endfunction
