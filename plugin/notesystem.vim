if !exists('g:notesystem_map_keys')
    let g:notesystem_map_keys = 1
endif

if !exists('g:notes_dir')
    let g:notes_dir = -1
endif

au FileType markdown
    \ command! -buffer RenderNotes execute "!open -a Marked\\ 2 " . g:notes_dir
au FileType markdown
    \ command! -buffer -nargs=+ NewNote execute ":normal! a" . notesystem#NewNote('<args>')
au FileType markdown
    \ command! -buffer -nargs=+ InsertImage execute ":normal! a" . notesystem#InsertImage('<args>')

if g:notesystem_map_keys
    autocmd FileType markdown nnoremap <buffer> ,nn :NewNote 
    autocmd FileType markdown nnoremap <buffer> ,ni :InsertImage 
endif
