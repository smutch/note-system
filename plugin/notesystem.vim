if !exists('g:notesystem_map_keys')
    let g:notesystem_map_keys = 1
endif

if !exists('g:notes_dir')
    let g:notes_dir = -1
endif

command! RenderNotes execute "!open -a Marked\\ 2 " . g:notes_dir
command! -nargs=+ NewNote call notesystem#NewNote("<args>", 0)
command! -nargs=+ StartNote call notesystem#NewNote("<args>", 1)

augroup Notes
    au!
    au FileType markdown
                \ command! -buffer -nargs=+ InsertImages execute ":normal! a" . notesystem#InsertAssets("<args>")
    au FileType markdown
                \ command! -buffer -nargs=+ InsertAssets execute ":normal! a" . notesystem#InsertAssets("<args>")

    au BufWritePre *.md exe "norm mz"|exe '%s/^\(modified\: \).*/\1'.strftime("%Y-%m-%d %H:%M:%S %Z")."  /e"|norm `z

    if g:notesystem_map_keys
        nnoremap <Leader>nn :NewNote 
        nnoremap <Leader>ns :StartNote 
        nnoremap <Leader>nr :RenderNotes<CR>
        autocmd FileType markdown nmap <buffer> <LocalLeader>ni :InsertAssets<space>
    endif
augroup END

