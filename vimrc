"" vim:fdm=marker

let mapleader = " "
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
let g:netrw_preview = 1

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
set statusline=[%n][%{winnr()}]-%f:%l:%c\ %m
set path=$PWD/**
set nocompatible
set complete-=i

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
highlight StatusLineNC cterm=bold ctermfg=white ctermbg=darkgray

match ExtraWhitespace /\s\+$/

if &diff
  colorscheme industry
endif

""---Commands
command!Rmtrailws %s/\s\+$//g
command!Bterm bel term
command!PendingTasks call ShowPendingTasks()
command!OpenSpec call OpenRailsRspec()
command!GoToSpec call GoToRailsRspec()
command!RunFileSpec call RunRailsRspec()
command!RunFileSpecFailure call RunRailsRspecFailure()
command!RunNearSpec call RunNearSpec()
command!RunAllSpecs call RunAllSpecs()
command!RunAllFailures call RunAllFailures()
command!RunLastSpecCommand call RunLastSpecCommand()
command!OpenSpecTarget call OpenRailsRspecTarget()
command!GoToSpecTarget call GoToRailsRspecTarget()
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
command!FormatXML call FormatXML()
command!RunRailsRunner call RunRailsRunner()
command!RemoveFile call RemoveFile()
command!Rm call RemoveFile()
command!MoveFile call MoveFile()
command!Mv call MoveFile()
command!RenameFile call MoveFile()
command!DuplicateFile call DuplicateFile()

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
nnoremap <leader>rrr :RunRailsRunner<cr>
nnoremap <leader>osf :OpenSpec<cr>
nnoremap <leader>ost :OpenSpecTarget<cr>
nnoremap <leader>gsf :GoToSpec<cr>
nnoremap <leader>gst :GoToSpecTarget<cr>
nnoremap <leader>vc :ViewChanges<cr>
nnoremap <leader>ob o<Esc>k
nnoremap <leader>oa O<Esc>j
nnoremap <C-W>m :MaxWindow<cr>
nnoremap <leader>rh :ResizeToHeight<cr>
nnoremap <leader>gd :GitDiff<cr>
nnoremap <leader>ga :GitAdd<cr>
nnoremap <leader>gs :GitShow<cr>
nnoremap <leader>gl :GitLog<cr>
nnoremap Y y$
nnoremap <leader>q :qa<cr>

""---Text Object Mappings
onoremap <silent> i\| :<C-u> call SelectBetweenMatchingPattern('\|')<cr>
onoremap <silent> a\| :<C-u> call SelectAroundMatchingPattern('\|')<cr>
onoremap <silent> i** :<C-u> call SelectBetweenMatchingPattern('\*\*')<cr>
onoremap <silent> a** :<C-u> call SelectAroundMatchingPattern('\*\*')<cr>
onoremap <silent> i_ :<C-u> call SelectBetweenMatchingPattern('_')<cr>
onoremap <silent> i__ :<C-u> call SelectBetweenMatchingPattern('__')<cr>
onoremap <silent> a__ :<C-u> call SelectAroundMatchingPattern('__')<cr>
onoremap <silent> i~~ :<C-u> call SelectBetweenMatchingPattern('\~\~')<cr>
onoremap <silent> a~~ :<C-u> call SelectAroundMatchingPattern('\~\~')<cr>
onoremap <silent> i/ :<C-u> call SelectBetweenMatchingPattern('/')<cr>
onoremap <silent> a/ :<C-u> call SelectAroundMatchingPattern('/')<cr>
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
  setl textwidth=79
  setl spell
endfunction

function! OpenRailsRspec()
  let spec_file = SpecFile()
  let spec_dir = SpecDir()
  call OpenFile(spec_file)
endfunction

function! OpenFile(file)
  if filereadable(a:file)
    let bufmatcher = "^".a:file
    if bufwinnr(bufmatcher) > 0
      return GoToWindow(bufwinnr(bufmatcher))
    endif
    if bufexists(bufmatcher)
      execute 'vert sb' a:file
    else
      call MkDirAndOpenFile(a:file)
    endif
  else
    return MkDirAndOpenFile(a:file)
  endif
endfunction

function GoToWindow(window_number)
  execute "normal! ".a:window_number."\<C-W>\<C-W>"
endfunction

function! MkDirAndOpenFile(file)
  let directory = GetDirectoryForFile(a:file)
  execute 'silent' '!' 'mkdir' '-p' directory
  execute 'vert' 'new' a:file
  execute 'redraw!'
endfunction

function! GetDirectoryForFile(file)
  let directory = substitute(a:file, '\/\w\+\(\.\w\+\)\?$', '','')
  if directory == a:file
    return ''
  else
    return directory
  endif
endfunction

function! GoToRailsRspec()
  let spec_file = SpecFile()
  let spec_dir = SpecDir()
  execute 'e' spec_file
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
  let target_file = SpecTargetFile()
  let target_dir = SpecTargetDir()
  call OpenFile(target_file)
endfunction

function! GoToRailsRspecTarget()
  let target_file = SpecTargetFile()
  execute 'e' target_file
endfunction

function! SpecTargetFile()
  let current_file = @%
  let target_file = substitute(current_file, '^spec\/', 'app/','')
  let target_file = substitute(target_file, '_spec\.rb$', '\.rb', '')
  let target_file = substitute(target_file, '^spec\/', 'app/','')
  return target_file
endfunction

function! SpecTargetDir()
  return substitute(SpecTargetFile(), '\(app.*\)\(\/.*rb$\)', '\1', '')
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
  execute 'normal Gdd gg'
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

function! RemoveFile(...)
  let target_file= get(a:, 1, @%)
  echo 'Deleting target file: '.target_file
  let job = job_start('rm ' . expand(target_file))
  execute 'bdelete!' target_file
endfunction

function! MoveFile()
  let target_file = @%
  let dup_file = DuplicateFile(target_file)
  if dup_file != target_file
    call RemoveFile(target_file)
  end
endfunction

function! DuplicateFile(...)
  let target_file = get(a:, 1, @%)
  call inputsave()
  let new_name = input('', target_file)
  call inputrestore()
  let init_pos = getcurpos()
  execute 'write! '.new_name
  execute 'edit! '.new_name
  call setpos('.', init_pos)
  return new_name
endfunction

function! MakeBufferScratch()
  execute 'setlocal buftype=nofile'
  execute 'setlocal bufhidden=hide'
  execute 'setlocal noswapfile'
endfunction

function! FormatJSON()
  execute '%!python -m json.tool'
endfunction

function! FormatXML()
  execute '%!xmllint -format -'
endfunction

function! RunRailsRunner(...)
  let target_file= get(a:, 1, @%)
  echo target_file
  let ex_str = 'bel term ' . RailsCommand() . ' r ' . target_file
  execute ex_str
endfunction

function! RailsCommand()
  let g:rails_command = get(g:, 'rails_command', 'bin/rails')
  return g:rails_command
endfunction

function! RunRuby(...)
  let target_file= get(a:, 1, @%)
  echo target_file
  let ex_str = 'bel term ' RubyCommand . ' ' . target_file
endfunction

function! RubyCommand()
  let g:ruby_command = get(g:, 'ruby_command', 'ruby')
  return g:ruby_command
endfunction

function! VisualSelection(position1, position2)
  call setpos('.', a:position1)
  normal! v
  call setpos('.', a:position2)
endfunction

function GetStringRelativeToCursor(relnumber)
  let start=0
  let end = col('.') + a:relnumber - 1
  return getline('.')[start:end]
endfunction

function! CountPatternInString(string, pattern)
  let split_list = split(a:string, a:pattern, 1)
  return len(split_list) - 1
endfunction

function! IsEven(number)
  return a:number%2 == 0
endfunction

function! IsCursorBetweenPattern(pattern)
  let pos_before = searchpos(a:pattern, 'bn', line('.'))
  let pos_after = searchpos(a:pattern, 'zn', line('.'))
  return pos_before != [0,0] && pos_after != [0,0] && !IsCursorOverPattern(a:pattern)
endfunction

function! IsCursorOverPattern(pattern)
  let pos_before = searchpos(a:pattern, 'bnc', line('.'))
  let pos_before_end = searchpos(a:pattern, 'bnce', line('.'))
  let curindex = getcurpos()[2]
  let pos_after = searchpos(a:pattern, 'znc', line('.'))
  return pos_before != [0,0] && (pos_before == pos_after || (curindex >= pos_before[1] && pos_before_end[1] >= curindex))
endfunction

function! IsCursorOverBeginPattern(pattern)
  let str_b_cur = GetStringRelativeToCursor(-1)
  let ptrn_cnt_b_cur = CountPatternInString(str_b_cur, a:pattern)
  return IsEven(ptrn_cnt_b_cur) && IsCursorOverPattern(a:pattern)
endfunction

function! IsCursorOverEndPattern(pattern)
  let str_b_cur = GetStringRelativeToCursor(-1)
  let ptrn_cnt_b_cur = CountPatternInString(str_b_cur, a:pattern)
  return !IsEven(ptrn_cnt_b_cur) && IsCursorOverPattern(a:pattern)
endfunction

function! SelectAroundMatchingPattern(pattern)
  let init_pos = getcurpos()
  if IsCursorBetweenPattern(a:pattern)
    call searchpos(a:pattern, 'b', line('.'))
    let begin_pos = getcurpos()
    call setpos('.', init_pos)
    call searchpos(a:pattern, 'ze', line('.'))
    let end_pos = getcurpos()
    call VisualSelection(begin_pos, end_pos)
  elseif IsCursorOverBeginPattern(a:pattern)
    call searchpos(a:pattern, 'bc', line('.'))
    let begin_pos = getcurpos()
    let pos_after = searchpos(a:pattern, 'z', line('.'))
    if pos_after != [0,0]
      call searchpos(a:pattern, 'ze', line('.'))
      let end_pos = getcurpos()
      call VisualSelection(begin_pos, end_pos)
    endif
  elseif IsCursorOverEndPattern(a:pattern)
    call searchpos(a:pattern, 'bc', line('.'))
    call searchpos(a:pattern, 'ze', line('.'))
    let end_pos = getcurpos()
    call searchpos(a:pattern, 'b', line('.'))
    call searchpos(a:pattern, 'b', line('.'))
    let begin_pos = getcurpos()
    call VisualSelection(begin_pos, end_pos)
  endif
endfunction

function! SelectBetweenMatchingPattern(pattern)
  let init_pos = getcurpos()
  if IsCursorBetweenPattern(a:pattern)
    call searchpos(a:pattern, 'be', line('.'))
    normal! l
    let begin_pos = getcurpos()
    call setpos('.', init_pos)
    call searchpos(a:pattern, 'z', line('.'))
    normal! h
    let end_pos = getcurpos()
    call VisualSelection(begin_pos, end_pos)
  elseif IsCursorOverBeginPattern(a:pattern)
    call searchpos(a:pattern, 'bc', line('.'))
    call searchpos(a:pattern, 'ce', line('.'))
    normal! l
    let begin_pos = getcurpos()
    let pos_after = searchpos(a:pattern, 'z', line('.'))
    if pos_after != [0,0]
      normal! h
      let end_pos = getcurpos()
      call VisualSelection(begin_pos, end_pos)
    endif
  elseif IsCursorOverEndPattern(a:pattern)
    call searchpos(a:pattern, 'bc', line('.'))
    normal! h
    let end_pos = getcurpos()
    call searchpos(a:pattern, 'be', line('.'))
    normal! l
    let begin_pos = getcurpos()
    call VisualSelection(begin_pos, end_pos)
  endif
endfunction!

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
