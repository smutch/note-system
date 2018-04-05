if !exists('g:notesystem_map_keys')
    let g:notesystem_map_keys = 1
endif

if !exists('g:notes_dir')
    let g:notes_dir = -1
endif

command! -bang RenderNote execute "!open -a Marked\\ 2 " . (<bang>0 ? g:notes_dir : '%:p:h')
command! -nargs=+ NewNote call notesystem#NewNote("<args>", 0)
command! -nargs=+ LocalNote call notesystem#NewNote("<args>", 1)
command! -bang -nargs=* SearchNotes call notesystem#SearchNotes("<args>", <bang>0 ? 0 : 1)
command! -bang -nargs=* OpenNote call notesystem#OpenNote("<args>", <bang>0 ? 0 : 1)

augroup Notes
    au!
    au FileType markdown
                \ command! -buffer -nargs=+ InsertImages execute ":normal! a" . notesystem#InsertAssets("<args>")
    au FileType markdown
                \ command! -buffer -nargs=+ InsertAssets execute ":normal! a" . notesystem#InsertAssets("<args>")

    au BufWritePre *.md exe "norm mz"|exe '%s/^\(modified\: \).*/\1'.strftime("%Y-%m-%d %H:%M:%S %Z")."  /e"|norm `z

    if g:notesystem_map_keys
        nnoremap <Leader>nn :NewNote 
        nnoremap <Leader>nl :LocalNote 
        nnoremap <Leader>n/ :SearchNote 
        nnoremap <Leader>no :OpenNote 
        nnoremap <Leader>nr :RenderNote<CR>
        autocmd FileType markdown nmap <buffer> <LocalLeader>ni :InsertAssets<space>
    endif
augroup END

