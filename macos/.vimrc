" Mappings
set number
set relativenumber

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>

" Plugins
let s:vim_plug_location = $HOME . '/.vim/autoload/plug.vim'
let s:vim_plugged_location = $HOME . '/.vim/plugged'

if empty(glob(s:vim_plug_location))
    execute'silent !curl -fLo' s:vim_plug_location '--create-dirs'
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(s:vim_plugged_location)
Plug 'altercation/vim-colors-solarized'
call plug#end()

if has('syntax')
    syntax enable
    silent! colorscheme solarized

    set cursorline colorcolumn=80
end

