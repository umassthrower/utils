nnoremap @p4e :!p4 edit %:e

"set invlist
set nocompatible
set nowrap
set hlsearch
" fix backspace
set backspace=indent,eol,start
set nobackup
syntax on
" show ruler and commands
set ruler
set showcmd
" use UNIX style newlines
set ff=unix
set ffs=unix,dos

"set noet sts=0 sw=4 ts=2 

set noexpandtab
set softtabstop=0
set shiftwidth=2
set tabstop=2

" Only do this part when compiled with support for autocommands.
if has("autocmd")
	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on
	" Put these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
	" When editing a file, always jump to the last known cursor position.
	" Don't do it when the position is invalid or when inside an event handler
	" (happens when dropping a file on gvim).
	autocmd BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\		exe "normal g`\"" |
		\ endif
	augroup END
else
	set autoindent				" always set autoindenting on
endif " has("autocmd")

if !did_filetype()
	set filetype=perl
endif

au BufRead,BufNewFile *.json set filetype=json 
au! Syntax json source $VIM/syntax/json.vim

au BufRead,BufNewFile *.cls set filetype=apex 
au! Syntax apex source $VIM/syntax/apex.vim

au BufRead,BufNewFile *.inc set filetype=perl
"au! Syntax perl source $VIM/syntax/perl.vim

autocmd BufEnter * set mouse=a

