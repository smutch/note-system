if !exists('g:notesystem_map_keys')
    let g:notesystem_map_keys = 1
endif

if !exists('g:notes_dir')
    let g:notes_dir = -1
endif

command! -bang -nargs=* Notes call notesystem#Notes("<args>", <bang>0 ? 0 : 1)
command! -nargs=+ NewNote call notesystem#NewNote("<args>", 0)
command! -nargs=+ LocalNote call notesystem#NewNote("<args>", 1)
command! -bang NotesHistory call notesystem#History(<bang>0 ? 0 : 1)
command! -bang RenderNote execute "!open -a Marked\\ 2 " . (<bang>0 ? g:notes_dir : '%:p:h')

augroup Notes
    au!
    au FileType markdown
                \ command! -buffer -nargs=+ InsertAssets
                \ execute ":normal! a" . notesystem#InsertAssets("<args>")

    " au BufWritePre *.md exe "norm mz"|exe '%s/^\(modified\: \).*/\1"'.strftime("%Y-%m-%d %H:%M:%S %Z").'"'."/e"|norm `z

    if g:notesystem_map_keys
        nnoremap <Leader>nn :Notes<CR>
        nnoremap <Leader>n/ :Notes 
        nnoremap <Leader>nc :NewNote 
        nnoremap <Leader>nl :LocalNote 
        nnoremap <Leader>no :OpenNote<CR>
        nnoremap <Leader>nr :RenderNote<CR>
        nnoremap <Leader>nh :NotesHistory<CR>
        autocmd FileType markdown nmap <buffer> <LocalLeader>i :InsertAssets<space>
    endif
augroup END

