if exists('loaded_autoproject')
    finish
endif

"let loaded_autoproject=1

if !exists('ap_width')
    let g:ap_width = 40
endif

if !exists('ap_windowpos')
    let g:ap_windowpos = 'topleft vertical'
endif

if !exists('ap_title')
    let g:ap_title = '__autoproject__'
endif

if !exists('ap_sort')
    let ap_sort = 'header'
elseif g:ap_sort != 'header'
    if g:ap_sort != 'alpha'
        echohl WarningMsg
        echo "Unknown value " . g:ap_sort . " of ap_sort. Must either be \'alpha\' or \'header\'."
        echohl None
    endif
endif

let s:running = 0
let s:dir_level = 0
let s:filenames = ""

nnoremap <silent> <C-F9> :call AP_Start()<CR>

function! s:ap_init_project_window()
    let s:caller_window = winnr() 
    let winnum = bufwinnr(g:ap_title)
    if winnum != -1
        " Jump to the existing window
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
    else
        if !bufexists(g:ap_title)
            let init_cmd = g:ap_title
        else
            let init_cmd = '+buffer ' . bufnr(g:ap_title)
        endif
        let init_cmd = g:ap_title
        exe 'silent! ' . g:ap_windowpos . ' ' . g:ap_width . ' split ' . init_cmd
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal nonumber
        setlocal foldmethod=manual
        syntax on
        setlocal syntax=syn-autoproject
    endif
    setlocal modifiable
    call s:clear_buffer()
    call s:ap_display_header()
    call s:begin_file_processing()
    setlocal foldlevel=4
    setlocal foldtext=AP_folded_text()
    setlocal fillchars=" "
    call s:close_folds()
    highlight Folded ctermbg=NONE ctermfg=blue
    highlight FoldColumn ctermbg=NONE ctermfg=NONE 
    setlocal nomodifiable
    nnoremap <buffer> <silent> <CR> :call AP_FileSelected()<CR>
    nnoremap <buffer> <silent> r :call AP_Restart()<CR>
    nnoremap <buffer> <silent> + :foldopen<CR>
    nnoremap <buffer> <silent> - :foldclose<CR>
endfunction

function! s:clear_buffer()
    silent! %delete _
    let s:line=1
    let s:closed_folds = ""
endfunction   

function! s:print_line(text)
    call append(s:line, a:text)
    let s:line = s:line +1
endfunction

function! s:enter_level()
    let s:fold_begin_line_{s:dir_level} = s:line
    let s:dir_level = s:dir_level + 1 
endfunction

function! s:leave_level(close)
    let s:dir_level = s:dir_level - 1
    exe s:fold_begin_line_{s:dir_level} . "," . s:line . " fold"
    let fold_line = s:fold_begin_line_{s:dir_level} + 1
    if a:close
        let s:closed_folds = s:closed_folds . fold_line . " foldclose\n"
    endif
    unlet s:fold_begin_line_{s:dir_level}
endfunction

function! s:close_folds()
    while strlen(s:closed_folds)
        exe matchstr(s:closed_folds, "^.\\{-}\\ze\\n")
        let s:closed_folds = matchstr(s:closed_folds, "^.\\{-}\\n\\zs.*")
    endwhile
endfunction

function! s:print_line_level(text)
    if s:dir_level == 0 
        if strpart(a:text, 0, 1) == "|"
            call s:print_line(a:text)
            return
        endif
    endif
    let prefixstr = " "
    let i = 0
    while i < s:dir_level
        let prefixstr = prefixstr . "  "
        let i = i + 1
    endwhile
    call s:print_line(prefixstr . a:text)
endfunction

function! s:print_filename(text)
    let l:teststr = matchstr( s:filenames, ": " . getcwd() . "/" . a:text . "\\n" )
    if strlen(l:teststr)
      return
    endif
    call s:print_line_level("|- " . a:text)
    let s:filenames = s:filenames . "l-" . s:line . ": " . getcwd() . "/" . a:text . "\n"
endfunction

function! s:print_directory(text)
    call s:print_line_level("- " . a:text)
endfunction

function! s:remove_prefix(str, prefix)
    let l:reststr = a:str
    let newstr = matchstr(l:reststr, a:prefix . "\\s*\\zs.\\{-}\\ze\\n")
    let l:reststr = matchstr(l:reststr, a:prefix . "\\s*.\\{-}\\n\\zs\\_.*")
    while strlen(l:reststr)
        let newstr = newstr . " " . matchstr(l:reststr, a:prefix . "\\s*\\zs.\\{-}\\ze\\n")
        let l:reststr = matchstr(l:reststr, a:prefix . "\\s*.\\{-}\\n\\zs\\_.*")
    endwhile
    return newstr
endfunction

function! s:ap_display_header()
    call s:print_line("Automake Projects for VIM")
    call s:print_line("\'r\' reloads")
    call s:print_line("\'+\' expands folder")
    call s:print_line("\'-\' collapses folder")
    call s:print_line("")
    let i = 0
    let str = ""
    while i < g:ap_width
        let str = str . "-"
        let i = i+1
    endwhile
    call s:print_line(str)
    call s:print_line("")
endfunction

function! s:find_automake_files()
    if strlen(glob("Makefile.am"))
        return 1
    else
        return 0
    endif
endfunction

function! s:begin_file_processing()
    if strlen(glob("configure.in.in"))
        call s:print_filename("configure.in.in")
    endif
    if strlen(glob("configure.in"))
        call s:print_filename("configure.in")
    endif
    if strlen(glob("configure.ac"))
        call s:print_filename("configure.ac")
    endif
    call s:process_am_file(glob("Makefile.am"))
endfunction

function! s:process_am_file(file)
    let subdirs = s:remove_prefix(system("cat " . a:file . "| awk '/\\\\/{printf \"%s\",$0;next}{print}' | sed 's/\\\\//g' | egrep '^[[:space:]]*SUBDIRS[[:space:]]*='"), "=")
    let source_files = s:remove_prefix(system("cat " . a:file . "| awk '/\\\\/{printf \"%s\",$0;next}{print}' | sed 's/\\\\//g' | egrep '_HEADERS[[:space:]]*='"), "=")
    let source_files = source_files . " " . s:remove_prefix(system("cat " . a:file . "| awk '/\\\\/{printf \"%s\",$0;next}{print}' | sed 's/\\\\//g' | egrep '_SOURCES[[:space:]]*='"), "=")
    call s:print_filename(a:file)
    if strlen(source_files)
        call s:init_sort()
        let l:sorted_filenames = s:for_each_substr(a:file, source_files, "s:sort_filenames")
        call s:for_each_substr("", l:sorted_filenames, "s:process_filename")
    endif
    if strlen(subdirs)
        call s:for_each_substr(a:file, subdirs, "s:process_dirname")
    endif
endfunction

function! s:init_sort()
    let g:sorted_list_h = ""
    let g:sorted_list_c = ""
endfunction

function! s:insert_sort_impl(string, list)
    if strlen(a:list) == 0
        return a:string
    endif
    let l:B = ""
    let l:E = a:list
    while 1
        let l:current = matchstr(l:E, "^\\s*\\zs\\S*")
        if strlen(l:current) == 0
            return l:B . " " . a:string
        endif
        if a:string < l:current
            return l:B . " " . a:string . " " . l:E
        endif
        if strlen(l:B)
            let l:B = l:B . " "
        endif
        let l:B = l:B . l:current
        let l:E = matchstr(l:E, "^\\s*\\S*\\s*\\zs.*")
    endwhile
endfunction

function! s:insert_sort(string)
    if g:ap_sort == 'alpha'
        let g:sorted_list_h = s:insert_sort_impl(a:string, g:sorted_list_h)
        return g:sorted_list_h
    else
        if strlen(matchstr(a:string, ".*\\.h\\(\\|h\\|pp\\)"))
            let g:sorted_list_h = s:insert_sort_impl(a:string, g:sorted_list_h)
        else
            let g:sorted_list_c = s:insert_sort_impl(a:string, g:sorted_list_c)
        endif
        return g:sorted_list_h . " " . g:sorted_list_c
    endif
endfunction

function! s:sort_filenames(filename, index)
  return s:insert_sort(a:filename)
endfunction

function! s:process_filename(filename, index)
    call s:print_filename(a:filename)
endfunction

function! s:process_dirname(dirname, index)
    call s:print_directory(a:dirname)
    let olddir = getcwd()
    if !isdirectory(a:dirname) 
        return
    endif
    exe "chdir " . olddir . "/" . a:dirname
    call s:enter_level()
    call s:begin_file_processing()
    exe "chdir " . olddir
    call s:leave_level(0)
endfunction

function! s:for_each_substr(file, str, cmd)
    let i = 0
    let reststr = a:str
    let retval = ""
    while 1
        while 1
            let varstr = matchstr(reststr, "^\\s*\\$(\\zs\\S*\\ze)")
            if strlen(varstr) == 0
                break
            endif
            let l:source_files = s:remove_prefix(system("cat " . a:file . "| awk '/\\\\/{printf \"%s\",$0;next}{print}' | sed 's/\\\\//g' | egrep '^[[:space:]]*" . varstr . "[[:space:]]*='"), "=")
            if v:shell_error
                call system("test -f Makefile")
                if v:shell_error
                    echohl WarningMsg
                    echo "Could not find the definition of " . varstr ". Please run configure."
                    echohl None
                else
                    let l:source_files = s:remove_prefix(system("cat Makefile | awk '/\\\\/{printf \"%s\",$0;next}{print}' | sed 's/\\\\//g' | egrep '^[[:space:]]*" . varstr . "[[:space:]]*='"), "=")
                    if v:shell_error
                        echohl WarningMsg
                        echo "Could not find the definition of " . varstr "!"
                        echohl None
                    endif
                endif
            endif
            let retval = s:for_each_substr(a:file, l:source_files, a:cmd)
            let l:reststr = matchstr(reststr, "^\\s*\\$(\\S*)\s*\\zs.*")
        endwhile
        let substr = matchstr(reststr, "\\<\\f*")
        if strlen(substr) == 0
            break
        endif
        let reststr = matchstr(reststr, "\\<\\f*\s*\\zs.*")
        let cmd = a:cmd . "( \"" . substr . "\", " . i . ")"
        exe "let retval = " . cmd
        let i=i+1
    endwhile
    if retval == "0"
      let retval = ""
    endif
    return retval
endfunction

function! AP_folded_text()
    return matchstr(getline(v:foldstart), ".*\\ze-") . "+" .  matchstr(getline(v:foldstart), "-\\zs.*\\ze$") 
endfunction

function! AP_FileSelected()
    let filename = matchstr(s:filenames, "l-" . line(".") . ":\\s\\zs.\\{-}\\n")
    if !strlen(filename)
        return
    endif
    wincmd w
    exe "edit " . filename
endfunction

function! AP_Restart()
    let s:dir_level = 0
    let s:filenames = ""
    let s:lines = 0
    if !s:find_automake_files()
        echo "no makefile found"
        return
    endif
    call s:ap_init_project_window()
endfunction

function! AP_Start()
    if s:running == 1
        let s:running = 0
        exe "bd " . g:ap_title
        return
    endif
    let s:running = 1
    call AP_Restart()
endfunction

