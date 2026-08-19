"remap <SPACE> <Nop>
let mapleader="\<Space>"

set number
"set relativenumber
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set mouse=a
set wrap
set hls
set incsearch
set nocompatible
set clipboard=unnamed
set ignorecase smartcase
"set cpoptions+=$
set autochdir
set undolevels=1000
set nrformats+=alpha

noremap <Esc> :nohlsearch<CR>

if has('nvim')
	" nvim plugins
else
	call plug#begin()
	Plug 'machakann/vim-highlightedyank'
	Plug 'christoomey/vim-tmux-navigator'
	Plug 'tpope/vim-commentary'
	call plug#end()
endif

nmap Y y$
nnoremap x "_x

inoremap <C-i> <Esc>

"" visual shifting (builtin-repeat)
vnoremap < <gv
vnoremap > >gv

nnoremap ø :
