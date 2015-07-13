syntax on
set hlsearch
set smartcase
set ic
set incsearch
set history=700
set autoread
set nobackup
set nowb
set noswapfile
set tabstop=4
set shiftwidth=4
set winminheight=0
set t_Co=256
set laststatus=2
colorscheme caires

set makeprg=[[\ -f\ Makefile\ ]]\ &&\ make\ \\\|\\\|\ make\ -C\ ~/

autocmd FileType java set tags=~/java/sources/tags
