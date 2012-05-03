hi String ctermfg=lightred
"==================================="
"--------.vimrc file kind-----------"
"-----Created by Matheus Araujo-----"
"-----matheus.araujo@dcc.ufmg.br----"
"-----------version 1.0-------------"
"==================================="

"==================================="
"----Load Files *.vim---------------" 
"==================================="




"Load CVIM and others plugins" 
:filetype plugin on

"Load cvim here to use some global variables"
	"let g:C_CCompiler           = 'gcc.exe'  " the C   compiler
	"let g:C_CplusCompiler       = 'g++.exe'  " the C++ compiler
	"let g:C_ExeExtension        = '.exe'     " file extension for executables (leading point required)
	"let g:C_ObjExtension        = '.obj'     " file extension for objects (leading point required)
	"let g:C_Man                 = 'man.exe'  " the manual program
	"let g:C_CCompiler           = 'gcc'      " the C   compiler
	"let g:C_CplusCompiler       = 'g++'      " the C++ compiler
	"let g:C_ExeExtension        = ''         " file extension for executables (leading point required)
	"let g:C_ObjExtension        = '.o'       " file extension for objects (leading point required)
	"let g:C_Man                 = 'man'      " the manual program

	"let g:C_VimCompilerName				= 'gcc'      " the compiler name used by :compiler

	"let g:C_CExtension     				= 'c'                    " C file extension; everything else is C++
	"let g:C_CFlags         				= '-Wall -g -O0 -c'      " compiler flagg: compile, don't optimize
	"let g:C_CodeCheckExeName      = 'check'
	"let g:C_CodeCheckOptions      = '-K13'
	"let g:C_LFlags         				= '-Wall -g -O0'         " compiler flagg: link   , don't optimize
	"let g:C_Libs           				= '-lm'                  " libraries to use
	"let g:C_LineEndCommColDefault = 49
	"let g:C_LoadMenus      				= 'yes'
	"let g:C_MenuHeader     				= 'yes'
	"let g:C_OutputGvim            = 'vim'
	"let g:C_Printheader           = "%<%f%h%m%<  %=%{strftime('%x %X')}\6     Page %N"
	"let g:C_Root  	       				= '&C\/C\+\+.'           " the name of the root menu of this plugin
	"let g:C_TypeOfH               = 'cpp'
	"let g:C_Wrapper               = s:plugin_dir.'c-support/scripts/wrapper.sh'
	"let g:C_XtermDefaults         = '-fa courier -fs 12 -geometry 80x24'
	"let g:C_GuiSnippetBrowser     = 'gui'										" gui / commandline
	"let g:C_GuiTemplateBrowser    = 'gui'										" gui / explorer / commandline
	""
	"let g:C_TemplateOverwrittenMsg= 'yes'
	"let g:C_Ctrl_j								= 'on'
	""
	"let g:C_FormatDate						= '%x'
	"let g:C_FormatTime						= '%X'
	"let g:C_FormatYear						= '%Y'
	"let g:C_SourceCodeExtensions  = 'c cc cp cxx cpp CPP c++ C i ii'
	""

"Shift-Y copy Shift-P paste inter-terminals"
"copy the current visual selection to ~/.vbuf
vmap <S-y> :call CopyExternal()<CR>
""copy the current line to the buffer file if no visual selection
nmap <S-y> :call CopyExternal()<CR>
"paste the contents of the buffer file if no visual selection
nmap <S-p> :r /tmp/vimbuf<CR>"
"paste the contents of the buffer file if visual selection
vmap <S-p> :r /tmp/vimbuf<CR>"

function CopyExternal()
    :'<,'>w! /tmp/vimbuf
	call system("cat /tmp/vimbuf | xclip")	
	call system("cat /tmp/vimbuf | xclip -selection 'clipboard'")
endfunction

"Make .zcml to .xml highlights"
au BufNewFile,BufRead *.zcml set filetype=xml

"Python Suport"
:so $HOME/GitVim/python3.0.vim

"Load auto comments with <C-C> <C-X>"
:so $HOME/GitVim/comments.vim

"Load auto close parenteses, bracket, etc"
:so $HOME/GitVim/autoclose.vim

"Load MRU-Most Recently Used-file
:so $HOME/GitVim/mru.vim

"Load ShowMarks"
:so $HOME/GitVim/showmarks.vim

"Load Code Completion on Searching mode"
:so $HOME/GitVim/SearchComplete.vim

"Load a(switcher to/from && from/to source/header file) HotKey: :A"
:so $HOME/GitVim/a.vim

"Load show invisivle caracter "
:so $HOME/GitVim/cream-showinvisibles.vim 

"Load CTAGS Global Variables"
   	:let g:ctags_path='/home/matheus/VIM/ctags-5.8/bin/'
   	:let g:ctags_args='-I __declspec+'
	:let g:ctags_title=1 
	:let g:ctags_statusline=0
	:let generate_tags=1 


"Load ctags"
:so $HOME/GitVim/ctags.vim

"Configure ctags atualization with <ctags-F12>"
	nmap <C-F12> :call Ctags_atualiza()<CR>
	function! Ctags_atualiza()
		:w
		:silent !ctags -R *
		:redraw!
		:TlistUpdate
	endfunction

"==================================="
"----Configurar teclas--------------"
"==================================="
"Configurar tecla para syntax on"
nmap <S-s> :syntax on<CR>

"Close Buffers without lose the MiniBufExplorer, NERDTree, and/or Tlist"
	cmap Q :call CloseBuffer()<CR>
	cmap Q!:call CloseBufferWithOutAsk()<CR>
	function! CloseBuffer()
	    if g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 1
		   :call CloseNERDTree()
		   :call CloseMiniBufExplorer()
		   :call CloseTlist()
		   :bd
		   :call OpenNERDTree()
		   :wincmd p
		   :call OpenTlist()
		   :wincmd p
		   :call OpenMiniBufExplorer()
		   :wincmd p
	    else
		   if  g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 1
			  :call CloseMiniBufExplorer()
			  :call CloseTlist()
			  :bd
			  :call OpenTlist()
			  :wincmd p
			  :call OpenMiniBufExplorer()
			  :wincmd p
		   else
			  if  g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 1
				 :call CloseNERDTree()
				 :call CloseTlist()
				 :bd
				 :call OpenNERDTree()
				 :wincmd p
				 :call OpenTlist()	
				 :wincmd p
			  else
				 if  g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 0
					:call CloseNERDTree()
					:call CloseMiniBufExplorer()
					:bd
					:call OpenNERDTree()
					:wincmd p
					:call OpenMiniBufExplorer()
					:wincmd p

				 else
					if g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 1
					    :call CloseTlist()
					    :bd
					    :call OpenTlist()
					    :wincmd p
					else
					    if  g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 0
						   :call CloseMiniBufExplorer()
						   :bd
						   :call OpenMiniBufExplorer()
						   :wincmd p
					    else
						   if  g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 0
							  :call CloseNERDTree()
							  :bd
							  :call OpenNERDTree()
							  :wincmd p
						   else
							  if  g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 0
								 :bd	
							  endif
						   endif
					    endif
					endif

				 endif
			  endif
		   endif
	    endif
	endfunction

function! CloseBufferWithOutAsk()
	if g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 1
	:call CloseNERDTree()
	:call CloseMiniBufExplorer()
	:call CloseTlist()
	:bd!
	:call OpenNERDTree()
	:wincmd p
	:call OpenTlist()
	:wincmd p
	:call OpenMiniBufExplorer()
	:wincmd p
	endif

	if  g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 1
	:call CloseMiniBufExplorer()
	:call CloseTlist()
	:bd!
	:call OpenTlist()
	:wincmd p
	:call OpenMiniBufExplorer()
	:wincmd p
	endif

	if  g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 1
	:call CloseNERDTree()
	:call CloseTlist()
	:bd!
	:call OpenNERDTree()
	:wincmd p
	:call OpenTlist()
	
	endif

	if  g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 0
	:call CloseNERDTree()
	:call CloseMiniBufExplorer()
	:bd!
	:call OpenNERDTree()
	:wincmd p
	:call OpenMiniBufExplorer()
	:wincmd p
	endif

	if g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 1
	:call CloseTlist()
	:bd!
	:call OpenTlist()
	:wincmd p
	endif

	if  g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') != -1 && g:Tlist_on == 0
	:call CloseMiniBufExplorer()
	:bd!
	:call OpenMiniBufExplorer()
	:wincmd p
	endif

	if  g:NERDTree_on == 1 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 0
	:call CloseNERDTree()
	:bd!
	:call OpenNERDTree()
	:wincmd p
	endif

	if  g:NERDTree_on == 0 && LookMiniBufOpen('-MiniBufExplorer') == -1 && g:Tlist_on == 0
	:bd!	
	endif
endfunction

function! CloseNERDTree()
 	:NERDTreeClose
	:let g:NERDTree_on = 0
endfunction

function! OpenNERDTree()
	:NERDTree
	:syntax on
	:let g:NERDTree_on = 1
endfunction

function! CloseMiniBufExplorer()
	:CMiniBufExplorer
endfunction

function! OpenMiniBufExplorer()
	:MiniBufExplorer	
	:syntax on
endfunction

function! CloseTlist()
	:TlistClose
	:let g:Tlist_on = 0
endfunction

function! OpenTlist()
	:TlistOpen
	:let g:Tlist_on = 1
	:syntax on
endfunction

function! LookMiniBufOpen(bufName)
	" Try to find an existing window that contains 
	" our buffer.
	let l:bufNum = bufnr(a:bufName)
	if l:bufNum != -1
		let l:winNum = bufwinnr(l:bufNum)
	else
		let l:winNum = -1
	endif
	return l:winNum
endfunction

"Toggle NERDTree"
:let NERDTree_on = 0
	nmap <C-F9> :call MyToggleNERDTree()<CR>
	

function! MyToggleNERDTree()
	if  g:NERDTree_on == 1
		:let g:NERDTree_on = 0
		:NERDTreeToggle
	else
		:let g:NERDTree_on = 1
		:NERDTreeToggle
	endif
endfunction

"Tlist Function"
	let g:tlist_open = 0
	nmap <C-F11> :call MyToggleTlist()<CR>

"Tlist Toggle Configuration"
	let g:Tlist_on = 0
	function! MyToggleTlist()
		if  g:Tlist_on == 1
			:let g:Tlist_on = 0
			:silent TlistToggle
		else
			:let g:Tlist_on = 1
			:silent TlistToggle
		endif
	endfunction

"Copy and paste between terminals"
	let g:session_yank_file="/tmp/.vim_yank"
	map <silent> <Leader>y :call Session_yank()<CR>
	vmap <silent> <Leader>y y:call Session_yank()<CR>
	vmap <silent> <Leader>Y Y:call Session_yank()<CR>
	nmap <silent> <Leader>p :call Session_paste("p")<CR>
	nmap <silent> <Leader>P :call Session_paste("P")<CR>

function Session_yank()
	new
	call setline(1,getregtype())
	put
	silent exec 'wq! ' . g:session_yank_file
	exec 'bdelete ' . g:session_yank_file
	endfunction

function Session_paste(command)
	silent exec 'sview ' . g:session_yank_file
	let l:opt=getline(1)
	silent 2,$yank
	if (l:opt == 'v')
		call setreg('"', strpart(@",0,strlen(@")-1), l:opt) " strip trailing endline ?
	else
		call setreg('"', @", l:opt)
	endif
	exec 'bdelete ' . g:session_yank_file
	exec 'normal ' . a:command
	endfunction

"Configure backspace to standard mode" 
:set backspace=indent,eol,start

"Navegate between files, in Edit mode, with <C-Left> and <C-Right>"
	:nmap <C-right> <ESC>:bn!<CR>
	:nmap <C-left> <ESC>:bp!<CR>

"Toggle Showamarks"
:nmap <C-m> \mt

"Sign line in text with S-F7 and unsign with S-F8"
	:sign define sinal text=!! linehl=Todo texthl=Error
	function! Sinal()
		execute(":sign place ".line(".")." line=".line(".")." name=sinal file=".expand("%:p"))
	endfunction
	nmap <S-F7> :call Sinal()<CR>
	nmap <S-F8> :sign unplace<CR>

"Tab key works on normal mode"
nmap <tab> i<tab>

"-------------------------------------------------------------------------------
"  Add quick command
"-------------------------------------------------------------------------------
"    F4   -  show tag under curser in the preview window (tagfile must exist!)
"    F5   -  open quickfix error window
"    F7   -  display previous error
"    F8   -  display next error   
"-------------------------------------------------------------------------------
	nmap  <silent> <F4>        :exe ":ptag ".expand("<cword>")<CR>
	map   <silent> <F5>        :copen<CR>
	map   <silent> <F7>        :cp<CR>
	map   <silent> <F8>        :cn<CR>
	"
	imap  <silent> <F4>   <Esc>:exe ":ptag ".expand("<cword>")<CR>
	imap  <silent> <F5>   <Esc>:copen<CR>
	imap  <silent> <F7>   <Esc>:cp<CR>
	imap  <silent> <F8>   <Esc>:cn<CR>

"==================================="
"----Visual Configuration-----------" 
"==================================="

"Highlight Syntax on"
:syntax on

"Check in text the last pattern searched"
set hlsearch

"Identation"
	:set tabstop=4    "Quantas colunas vale um tab" 
	:set shiftwidth=4 "Quantas colunas para a identacao"

"Language dependent identation"
":filetype indent on

"Smart Identantion"
":set smartindent

"Change Status Line to show: file format, type, ASCII character under cursor, percentage in all document, document size in lines"
	:set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [%p%%]\ [LEN=%L]
	:set laststatus=2

"Change some colors"
	"Highlight cursor line"
	:highlight CursorLine cterm=NONE ctermbg=darkgray
	:set cursorline!
	:hi String cterm=NONE ctermfg=LightRed	
	:hi Constant cterm=NONE ctermfg=LightRed 
	:hi Comment cterm=bold ctermfg=LightGreen term=bold 

	"":nnoremap <Leader>c :set cursorline!<CR>
	:hi Normal cterm=NONE  ctermfg=7

	"Change column number line color"
	:highlight LineNr ctermbg=darkgray

	"Marck highlight error after column 73"
	:match ErrorMsg /\%>73v.\+/


"Don't break line"
:set nowrap


"==================================="
"----Configure Utilities------------" 
"==================================="

"VI not compatible"
:set nocompatible 

"Incremetal search mode"
:set incsearch

"Scroll n lines after/before display's end"
:set scrolloff=2

"Code completion in file management"
:set wildmode=longest,list

"Line with numbers"
:set number

"Turn on mouse"
:set mouse=a

"Configure the actual diretory browser"
:set browsedir=current

"Keep 1000 line in the history" 
:set history=1000

"Print options"
:set popt=left:8pc,right:3pc

"Always show cursor position"
:set ruler

"Show incomplete commands"
:set showcmd

"Code completion in command-line"
:set wildmenu

"Cursor in the last position when the file has closed"
	if has("autocmd")
		autocmd BufReadPost *
			\ if line("'\"") > 0 && line("'\"")  <= line ("$") |
			\   exe "normal! g`\"" |
			\ endif
	endif

"Configure SuperTab"
""let g:SuperTabDefaultCompletionType = "context"

"Configure intelligent tab"
	"function! SuperCleverTab()
		"if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
			"return "\<Tab>"
		"else
			"""""""if &omnifunc != ''
				"""""""return "\<C-X>\<C-O>"
			"""""""elseif &dictionary != ''
				"""""""return "\<C-K>"
			"""""""else
				"""""""return "\<C-N>"
			"""""""endif
		"endif
	"endfunction
	"inoremap <Tab> <C-R>=SuperCleverTab()<cr>

"Ignorate Case Sensitive"
":set noignorecase caso contrario"
:set ignorecase

"Folding settings
	set foldmethod=indent   "fold based on indent
	set foldnestmax=10      "deepest fold is 10 levels
	"set nofoldenable        "dont fold by default
	set foldlevel=1         "this is just what i use

"Set save last exibition (folding included)"
   au BufWinLeave * silent  mkview
   au BufWinEnter silent * silent loadview

"==================================="
"----C-vim global variables---------"
"==================================="



"==================================="
"----Observations-------------------"
"==================================="

"Abreviacoes, abbreviate para todos os modos, iabbrev para o modo de insercao, cabbrev para o modo de linha de comando "

"[] Make Documentation about all of this document"
"[x] Make the highlight on cursor line works"
"[n] Make all of the plugins get work in just one directory"
"[] Make an easy install method to all of this plugins"
"[x] Cursor back to text when close a file in multiple files
"[] Create a great documentation to cvim shortcuts
"[x] Configure cvim global variables
"[x] Correct strange dysplay bugs and not permission in save
"
