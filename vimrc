"" vim:fdm=marker

let mapleader = " "
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25

set nu
set rnu
set spr
set expandtab ts=2 sw=2 ai
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
set wildmenu
set exrc
set secure
set background=dark
set t_Co=256
set cc=80
set laststatus=2
set statusline=[%n]-%F:%l:%c\ %m
set path=$PWD/**
set nocompatible

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#begin()
  Plugin 'VundleVim/Vundle.vim'
  Plugin 'elixir-editors/vim-elixir'
call vundle#end()
runtime  macros/matchit.vim

hi ColorColumn ctermbg=8
au BufNewFile,BufRead *.hamlc set ft=haml

filetype plugin on
highlight ExtraWhitespace ctermbg=red guibg=red

match ExtraWhitespace /\s\+$/

if &diff
  colorscheme industry
endif

""---Commands
command!Rmtrailws %s/\s\+$//g
command!Bterm bel term
command!PendingTasks call ShowPendingTasks()
command!OpenSpec call OpenRailsRspec()
command!RunFileSpec call RunRailsRspec()
command!RunFileSpecFailure call RunRailsRspecFailure()
command!RunNearSpec call RunNearSpec()
command!RunAllSpecs call RunAllSpecs()
command!RunAllFailures call RunAllFailures()
command!RunLastSpecCommand call RunLastSpecCommand()
command!OpenSpecTarget call OpenRailsRspecTarget()
command!SpecFileExist call SpecFileExist()
command!CopyFileToClipBoard normal gg"+yG
command!CopyFileNameToClipBoard execute "let @+=@%"
command!GWA norm 1GVGgw
command!ViewChanges w !git diff --no-index -- % -
command!MaxWindow call MaxWindow()
command!ResizeToHeight call ResizeToHeight()
command! -nargs=? GitDiff call GitDiff(<f-args>)
command!GitAdd call GitAdd()
command!GitLog -nargs=? call GitLog(<f-args>)
command!GitShow -nargs=? call GitShow(<f-args>)
command!FormatJSON call FormatJSON()

""--AutoCommands
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
autocmd BufWinEnter *.md exe SetMdFileSettings()

""---Normal mode mappings
nnoremap <leader>rs :RunFileSpec<cr>
nnoremap <leader>rl :RunLastSpecCommand<cr>
nnoremap <leader>ras :RunAllSpecs<cr>
nnoremap <leader>raf :RunAllFailures<cr>
nnoremap <leader>rn :RunNearSpec<cr>
nnoremap <leader>rf :RunFileSpecFailure<cr>
nnoremap <leader>osf :OpenSpec<cr>
nnoremap <leader>ost :OpenSpecTarget<cr>
nnoremap <leader>vc :ViewChanges<cr>
nnoremap <leader>ob o<Esc>k
nnoremap <leader>oa O<Esc>j
nnoremap <C-W>m :MaxWindow<cr>
nnoremap <leader>rh :ResizeToHeight<cr>
nnoremap <leader>gd :GitDiff<cr>
nnoremap <leader>ga :GitAdd<cr>
nnoremap <leader>gs :GitShow<cr>
nnoremap <leader>gl :GitLog<cr>

""---Text Object Mappings
onoremap <silent> i\| :<C-u> call SelectInnerPipe()<cr>
onoremap <silent> a\| :<C-u> call SelectAroundPipe()<cr>
""---Insert mode mappings

"Quickly insert ruby method
inoremap <C-@>d def<cr>end<Esc>kA<space>
inoremap <C-@>c class<cr>end<Esc>kA<space>
inoremap <C-@>m module<cr>end<Esc>kA<space>
inoremap <C-@>b <space>do<cr>end<Esc>kA

""---Functions
function! MaxWindow()
  normal! _|
endfunction

function! ResizeToHeight()
  let window_height = line('$')
  execute 'resize' window_height
  setl wfh
endfunction

function! SetMdFileSettings()
  setl textwidth=80
  setl spell
endfunction

function! OpenRailsRspec()
  let spec_file = SpecFile()
  let spec_dir = SpecDir()
  execute "silent" "!" "mkdir" "-p" spec_dir
  execute 'vert' 'new' spec_file
  execute "redraw!"
endfunction

function! RunLastSpecCommand()
  execute g:last_spec_command
endfunction

function! ExecuteSpecCommmand(command)
  call SetLastSpecCommand(a:command)
  execute a:command
endfunction

function! SetLastSpecCommand(command)
  let g:last_spec_command = a:command
endfunction

function! RunAllSpecs()
  let command =  "bel term " . RspecCommand()
  call ExecuteSpecCommmand(command)
endfunction

function! RunAllFailures()
  let command = "bel term " . RspecCommand() . " --only-failures"
  call ExecuteSpecCommmand(command)
endfunction

function! RunRailsRspec()
  let command = "bel term " . RspecCommand() . " " . SpecFile()
  call ExecuteSpecCommmand(command)
endfunction

function! RspecCommand()
  let g:rspec_command = get(g:, 'rspec_command', "bundle exec rspec")
  return g:rspec_command
endfunction

function! RunRailsRspecFailure()
  let command = "bel term " . RspecCommand() . " " . SpecFile() . " --only-failures"
  call ExecuteSpecCommmand(command)
endfunction

function! RunNearSpec()
  let near_spec = SpecFile() . ":" . line(".")
  let command = "bel term " . RspecCommand() . " " . near_spec
  call ExecuteSpecCommmand(command)
endfunction

function! SpecDir()
  return substitute(SpecFile(), '\(spec.*\)\(\/.*rb$\)', '\1', '')
endfunction

function! SpecFile()
  let current_file = @%
  if current_file =~ "_spec.rb"
    let spec_file = current_file
  else
    let spec_file = substitute(current_file, '^app\/', 'spec/','')
    let spec_file = substitute(spec_file, '\.rb$', '_spec.rb','')
  end
  return spec_file
endfunction

function! OpenRailsRspecTarget()
  let current_file = @%
  let target_file = substitute(current_file, '^spec\/', 'app/','')
  let target_file = substitute(target_file, '_spec\.rb$', '\.rb', '')
  let target_file = substitute(target_file, '^spec\/', 'app/','')
  let target_dir = substitute(target_file, '\(app.*\)\(\/.*rb$\)', '\1', '')
  execute "silent" "!" "mkdir" "-p" target_dir
  execute 'vert' 'new' target_file
  execute "redraw!"
endfunction

function! SpecFileExist()
  let spec_file = SpecFile()
  if filereadable(expand(spec_file))
    echo expand(spec_file).' exists'
  else
    echohl ErrorMsg
    echo 'WARNING: '.expand(spec_file).' does not exist'
    echohl None
  endif
endfunction

function! ShowPendingTasks()
  let current_file_type = &ft
  let current_file = @%
  execute 'abo' 'new'
  execute "read ! grep -E '\\[\\s\\].*$|\\#.*$'" current_file
  execute "1d"
  execute "set syntax=" .current_file_type
  execute "resize 20"
endfunction

function! GitDiff(...)
  let target_file_type=&ft
  let target_file=@%
  let object = get(a:, 1, 'HEAD')
  execute 'diffthis'
  execute 'vne | 0read !git show ' . expand(object) . ':' . expand(target_file)
  execute 'set filetype=' . expand(target_file_type)
  execute 'diffthis'
  call MakeBufferScratch()
  execute "normal! \<C-W>r"
endfunction

function! GitLog(...)
  let target_file = get(a:,1, @%)
  execute 'vne | 0read !git log ' .expand(target_file)
  call MakeBufferScratch()
endfunction

function! GitShow(...)
  let object = get(a:, 1, 'HEAD')
  execute 'vne | 0read !git show ' .expand(object)
  call MakeBufferScratch()
endfunction

function! GitAdd(...)
  let target_file=@%
  let job = job_start('git add ' . expand(target_file))
endfunction

function! MakeBufferScratch()
  execute 'setlocal buftype=nofile'
  execute 'setlocal bufhidden=hide'
  execute 'setlocal noswapfile'
endfunction

function! FormatJSON()
  let target_file=@%
  execute '%!python -m json.tool'
endfunction

function! SelectInnerPipe()
  execute "normal! ^f|lvt|"
endfunction

function! SelectAroundPipe()
  execute "normal! ^f|vf|"
endfunction

""--- CSCOPE
"##########################################
" CSCOPE Settings
"##########################################
" add any cscope database in current directory
if filereadable("cscope.out")
    cs add cscope.out
" else add the database pointed to by environment variable
elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
endif" show msg when any other cscope db added

set cscopeverbose

" To do the first type of search, hit 'CTRL-\', followed by one of the
" cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
" search will be displayed in the current window.  You can use CTRL-T to
" go back to where you were before the search.
"
nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nnoremap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nnoremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

" Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
" makes the vim window split horizontally, with search result displayed in
" the new window.
"
" (Note: earlier versions of vim may not have the :scs command, but it
" can be simulated roughly via:
"    nnoremap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>

nnoremap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
nnoremap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nnoremap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


" Hitting CTRL-space *twice* before the search type does a vertical
" split instead of a horizontal one (vim 6 and up only)
"
" (Note: you may wish to put a 'set splitright' in your .vimrc
" if you prefer the new window on the right instead of the left

nnoremap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
nnoremap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nnoremap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
"##########################################
