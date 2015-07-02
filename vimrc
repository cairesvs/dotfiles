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
function! Make(args)
  " Close quickfix
  cclose

  " Compile arguments
  let l:args = strlen(a:args) ? ' ' . a:args : ''
  let l:title = expand('%') . ' - Make' . l:args

  " Force write
  silent write!

  " Move to current directory
  lcd %:p:h

  " Make
  let l:out = split(system('make' . l:args), "\n")
  let l:len = len(l:out)

  " Output to quickfix
  cgetexpr l:out
  let w:quickfix_title = l:title

  " If no output, just report success
  if l:len == 0
	redraw
	echo l:title . ' succeeded'
  " If output is a single line, echo it
  elseif l:len == 1
	cc 1
	redraw
	echo l:out[0]
  else
	execute 'copen' l:len + 1
	cc 1
  endif
endfunction

command! -nargs=? Make call Make("<args>")

let g:make_loaded = 1
