set expandtab
set tabstop=2
set shiftwidth=2
set noeb vb t_vb=
set nu
set hlsearch
set smartcase
set ic
set incsearch
set history=700
set autoread
set background=dark
set nobackup
set nowb
set noswapfile
set winminheight=0
colorscheme desert

" Formata e mostra a status bar
set laststatus=2
hi statusline ctermfg=white ctermbg=black
hi statuslinenc ctermfg=gray ctermbg=black cterm=bold

" Formats the statusline
set statusline=%f                           " file name
set statusline+=%y      "filetype
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=\ %=                        " align left
set statusline+=Line:%l/%L[%p%%]            " line X of Y [percent of file]
set statusline+=\ Col:%c                    " current column
set statusline+=\ Buf:%n                    " Buffer number

let mapleader = ","
let g:mapleader = ","

" Find maroto
function! Find(name)
  let l:list=system("find . -iname '*".a:name."*' | perl -ne 'print \"$.\\t$_\"'")
  let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))
  if l:num < 1
    echo "'".a:name."' not found"
    return
  endif
  if l:num != 1
    echo l:list
    let l:input=input("Which ? (CR=nothing)\n")
    if strlen(l:input)==0
      return
    endif
    if strlen(substitute(l:input, "[0-9]", "", "g"))>0
      echo "Not a number"
      return
    endif
    if l:input<1 || l:input>l:num
      echo "Out of range"
      return
    endif
    let l:line=matchstr("\n".l:list, "\n".l:input."\t[^\n]*")
  else
    let l:line=l:list
  endif
  let l:line=substitute(l:line, "^[^\t]*\t./", "", "")
  execute ":e ".l:line
endfunction
command! -nargs=1 Find :call Find("<args>")

nmap <leader>f :Find 
nmap <leader>g :grep -Ri 
nmap <silent> <leader>v :rightbelow vsplit<CR>
nmap <silent> <leader>s :leftabove split<CR> <C-W>_
nmap <silent> <leader>j <C-W>j<C-W>_
nmap <silent> <leader>k <C-W>k<C-W>_
nmap <silent> <leader>b :buffers<CR>:buffer<Space>
"Fast saving
nmap <leader>w :w!<cr>
"nmap <leader>s :w!<cr>:! websp.py<cr>
nmap <leader>q :q<cr><C-W>_
nmap <silent><leader>wq :wq<cr>
" Proximo e anterior arquivo no resultado do grep
map <leader>n :cn<cr>
map <leader>p :cp<cr>
noremap <C-l> :set hlsearch! hlsearch?<CR>
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! %!sudo tee > /dev/null %
nmap <F8> :TagbarToggle<CR> 

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
