set nu
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
command OpenSpec call OpenRailsRspec()
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
endfunction
