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

" Show syntax highlighting groups for word under cursor
nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
