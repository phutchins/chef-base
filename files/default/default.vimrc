set nocompatible
filetype off

" Install vundle and plugins
if !filereadable($HOME . "/.vim") | call system("mkdir -p $HOME/.vim/{plugin,undo}") | endif
if !filereadable($HOME . "/.vimrc.plugins") | call system("touch $HOME/.vimrc.plugins") | endif
if !filereadable($HOME . "/.vimrc.first") | call system("touch $HOME/.vimrc.first") | endif
if !filereadable($HOME . "/.vimrc.last") | call system("touch $HOME/.vimrc.last") | endif

let has_vundle=1
if !isdirectory($HOME."/.vim/bundle/Vundle.vim")
  echo "Installing Vundle..."
  echo ""
  silent !mkdir -p $HOME/.vim/bundle
  silent !git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  let has_vundle=0
endif

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'flazz/vim-colorschemes'
Plugin 'scrooloose/nerdtree'
Plugin 'tomasr/molokai'

call vundle#end()
filetype plugin indent on

if has_vundle == 0
  :silent! PluginInstall
  :qa
endif

syntax on
set laststatus=2
set encoding=utf-8

map <leader>ff :CtrlP<CR>
map <leader>fb :CtrlPBuffer<CR>
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <leader>t  :A<CR>
map <leader>ts :AS<CR>
map <leader>tv :AV<CR>
map <leader>rm :Rmodel<CR>
map <leader>rc :Rcontroller<CR>
map <leader>rh :Rhelper<CR>
map <leader>ru :Runittest<CR>
map <leader>rf :Rfunctionaltest<CR>
map <leader>ro :Robserver<CR>
map <leader>rv :Rview<CR>
map <leader>rl :Rlocale<CR>
imap jj <Esc>

set autoread    "Auto reload files changed outside of vim automatically
set wildmenu
set wildmode=list:longest
set splitright
set splitbelow
set cindent
set smartindent
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set hidden
set number
set ic
set hlsearch
set incsearch
"set noswapfile
"set nobackup
set backupdir=~/.vim/backup/,~/.tmp,~/tmp,/tmp
set directory=~/.vim/backup/,~/.tmp,~/tmp,/tmp
set autoread      "Autoreload files changed externally
set noeb vb t_vb=
set so=5
set foldmethod=indent
set foldminlines=1
set foldlevel=100
au GUIEnter * set vb t_vb=
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" Backup files in alternative directory
set backupdir-=.
set backupdir^=~/tmp,/tmp

colorscheme molokai
set guifont=Monaco:h15

"set guioptions-=T guioptions-=e guioptions-=L guioptions-=r
set shell=bash

let @c='ggjGf x:%s/ #.*$//gvapJ'

nnoremap <Leader>[ :tabprevious<CR>
nnoremap <Leader>] :tabnext<CR>
nnoremap <silent> <Enter> :nohlsearch<Bar>:echo<CR>

augroup vimrc
autocmd!
"autocmd GuiEnter * set columns=120 lines=70 number
augroup END

" remove whistespace at end of line before write
func! StripTrailingWhitespace()
  normal mZ
  %s/\s\+$//e
  normal `Z
endfunc
au BufWrite * if ! &bin | call StripTrailingWhitespace() | endif

" Add syntax highlighting for rabl
au BufRead,BufNewFile *.rabl setf ruby

au BufRead,BufNewFile *.hamlc setf haml

"Reload .vimrc after updating it
"if has("autocmd")
"  autocmd BufWritePost .vimrc source $MYVIMRC
"endif

let g:EasyMotion_leader_key = ','
nmap <leader>v :tabedit $MYVIMRC<CR>
nmap <leader>n :set invnumber<CR>
nmap <leader>p :set paste!<CR>

nnoremap <Leader>h :h <C-r><C-w><CR>
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
nnoremap <Leader>sv :source $MYVIMRC<CR>

" Reload .vimrc after update
if has("autocmd")
  " autocmd BufWritePost .vimrc source $MYVIMRC
endif

map <D-1> 1gt
map <D-2> 2gt
map <D-3> 3gt
map <D-4> 4gt
map <D-5> 5gt
map <D-6> 6gt
map <D-7> 7gt
map <D-8> 8gt
map <D-9> :tablast<CR>

" Map in insert mode as well
map! <D-1> 1gt
map! <D-2> 2gt
map! <D-3> 3gt
map! <D-4> 4gt
map! <D-5> 5gt
map! <D-6> 6gt
map! <D-7> 7gt
map! <D-8> 8gt
map! <D-9> :tablast<CR>

map <F3> :source $MYVIMRC<CR>:echoerr ".vimrc reloaded"<CR>

set showtabline=2

"" Search for visual selection
"xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
"xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
"
"function! s:VSetSearch()
"  let temp = @s
"  norm! gv"sy
"  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
"  let @s = temp
"endfunction

if has("gui_running")
  set background=dark
  set showtabline=2 " Always show the tab bar
  set lines=999 columns=999 " Start vim maximized
  set guioptions+=a guioptions+=P " Enable autocopy on select to system clipboard
endif

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

" Rspec.vim mappings
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>
