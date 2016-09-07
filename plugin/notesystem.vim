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

augroup Notes
    au!
    au FileType markdown
                \ command! -buffer -nargs=+ InsertImages execute ":normal! a" . notesystem#InsertAssets('<args>')
    au FileType markdown
                \ command! -buffer -nargs=+ InsertAssets execute ":normal! a" . notesystem#InsertAssets('<args>')
    if g:notesystem_map_keys
        nnoremap <Leader>nn :NewNote 
        nnoremap <Leader>ng :GrepNotes 
        nnoremap <Leader>nf :FuzzyGrepNotes 
        nnoremap <Leader>no :OpenNote<CR>
        nnoremap <Leader>nr :RenderNotes<CR>
        autocmd FileType markdown nmap <buffer> <LocalLeader>ni :InsertAssets<space>
    endif
augroup END

