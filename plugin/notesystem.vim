if !exists('g:notesystem_map_keys')
    let g:notesystem_map_keys = 1
endif

if !exists('g:notes_dir')
    let g:notes_dir = -1
endif

command RenderNotes execute "!open -a Marked\\ 2 " . g:notes_dir
command -nargs=+ NewNote call notesystem#NewNote('<args>')
au FileType markdown
    \ command! -buffer -nargs=+ InsertImage execute ":normal! a" . notesystem#InsertImage('<args>')

if g:notesystem_map_keys
    nnoremap ,nn :NewNote 
    autocmd FileType markdown nmap <buffer> ,ni :InsertImage 
endif
