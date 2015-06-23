if !exists('g:notesystem_map_keys')
    let g:notesystem_map_keys = 1
endif

if !exists('g:notes_dir')
    let g:notes_dir = -1
endif

command! RenderNotes execute "!open -a Marked\\ 2 " . g:notes_dir
command! -nargs=+ NewNote call notesystem#NewNote('<args>')
command! -nargs=+ GrepNotes call notesystem#GrepNotes('<args>')
au FileType markdown
    \ command! -buffer -nargs=+ InsertImage execute ":normal! a" . notesystem#InsertImage('<args>')

if g:notesystem_map_keys
    nnoremap <Leader>nn :NewNote 
    nnoremap <Leader>ns :GrepNotes 
    autocmd FileType markdown nmap <buffer> <LocalLeader>ni :InsertImage 
endif
