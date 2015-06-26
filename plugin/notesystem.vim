if !exists('g:notesystem_map_keys')
    let g:notesystem_map_keys = 1
endif

if !exists('g:notes_dir')
    let g:notes_dir = -1
endif

command! RenderNotes execute "!open -a Marked\\ 2 " . g:notes_dir
command! -nargs=+ NewNote call notesystem#NewNote('<args>')
command! -nargs=+ GrepNotes call notesystem#GrepNotes('<args>')
command! -nargs=? FuzzyGrepNotes call notesystem#FuzzyGrepNotes('<args>')
command! OpenNote call notesystem#OpenNote()
command! GenLink call notesystem#GenLink()

au FileType markdown
    \ command! -buffer -nargs=+ InsertImage execute ":normal! a" . notesystem#InsertImage('<args>')

if g:notesystem_map_keys
    nnoremap <Leader>nn :NewNote 
    nnoremap <Leader>ns :GrepNotes 
    nnoremap <Leader>ng :FuzzyGrepNotes 
    nnoremap <Leader>nf :OpenNote<CR>
    nnoremap <Leader>nr :RenderNotes<CR>
    nnoremap <Leader>nl :GenLink<CR>
    autocmd FileType markdown nmap <buffer> <LocalLeader>ni :InsertImage 
endif
