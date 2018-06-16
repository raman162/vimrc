set nu
set spr
set expandtab ts=2 sw=2 ai
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
au BufNewFile,BufRead *.hamlc set ft=haml
set path=$PWD/**
filetype plugin on
set statusline+=%F
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
command Rmtrailws %s/\s\+$//g
command GitCommitPush !git commit -am 'made updates';git push origin master
command GitPullMaster !git pull origin master
command PendingTasks call ShowPendingTasks()
command OpenSpec call OpenRailsRspec()
command OpenSpecTarget call OpenRailsRspecTarget()
command CopyFileToClipBoard execute "silent !cat % | xclip -selection c" | redraw!
command CopyFileNameToClipBoard execute "silent ! echo % | tr -d '\\n' | xclip -selection c" | redraw!
command GWA norm 1GVGgw
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
autocmd BufWinEnter *.md exe SetMdFileSettings()

"Functions
function! SetMdFileSettings()
  setl textwidth=80
  setl spell
endfunction

function! OpenRailsRspec()
  let current_file = @%
  let spec_file = substitute(current_file, '^app\/', 'spec/','')
  let spec_file = substitute(spec_file, '\.rb$', '_spec.rb','')
  let spec_dir = substitute(spec_file, '\(spec.*\)\(\/.*rb$\)', '\1', '')
  execute "silent" "!" "mkdir" "-p" spec_dir
  execute 'vert' 'new' spec_file
  execute "redraw!"
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

function! ShowPendingTasks()
  let current_file_type = &ft
  let current_file = @%
  execute 'abo' 'new'
  execute "read ! grep -E '\\[\\s\\].*$|\\#.*$'" current_file
  execute "1d"
  execute "set syntax=" .current_file_type
  execute "resize 20"
endfunction
