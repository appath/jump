""" Automatically create needed files and folders on first run (*nix only) {{{
    call system('mkdir -p $HOME/.vim/{autoload,bundle,swap,undo}')
    if !filereadable($HOME.'/.vimrc.plugins') | call system('touch $HOME/.vimrc.plugins') | endif
    if !filereadable($HOME.'/.vimrc.first') | call system('touch $HOME/.vimrc.first') | endif

""" }}}

""" vim-plug plugin manager {{{
    " Automatic installation
    " https://github.com/junegunn/vim-plug/wiki/faq#automatic-installation
    if empty(glob('~/.vim/autoload/plug.vim'))
        let g:clone_details = 'https://github.com/junegunn/vim-plug.git $HOME/.vim/bundle/vim-plug'
        silent call system('git clone --depth 1 '. g:clone_details)
        if v:shell_error | silent call system('git clone ' . g:clone_details) | endif
        silent !ln -s $HOME/.vim/bundle/vim-plug/plug.vim $HOME/.vim/autoload/plug.vim
        augroup FirstPlugInstall
            autocmd! VimEnter * PlugInstall --sync | source $MYVIMRC
        augroup END
    endif

    """ Plugins to be disabled {{{
    """ https://github.com/timss/vimconf/issues/13
        " Create empty list with names of disabled plugins if not defined
        let g:plugs_disabled = get(g:, 'plug_disabled', [])

        " Trim and extract repo name
        " Same substitute/fnamemodify args as vim-plug itself
        " https://github.com/junegunn/vim-plug/issues/469#issuecomment-226965736
        function! s:plugs_disable(repo)
            let l:repo = substitute(a:repo, '[\/]\+$', '', '')
            let l:name = fnamemodify(l:repo, ':t:s?\.git$??')
            call add(g:plugs_disabled, l:name)
        endfunction

        " Append to list of repo names to be disabled just like they're added
        " UnPlug 'junegunn/vim-plug'
        command! -nargs=1 -bar UnPlug call s:plugs_disable(<args>)

    """ }}}

    " Default to same plugin directory as vundle etc
    call plug#begin('~/.vim/bundle')
    
    " Snippets like textmate
    if has('python') || has('python3')
        Plug 'honza/vim-snippets'
        Plug 'sirver/ultisnips'
    endif

    " Local plugins
    if filereadable($HOME.'/.vimrc.plugins')
        source $HOME/.vimrc.plugins
    endif

    " Remove disabled plugins from installation/initialization
    " https://vi.stackexchange.com/q/13471/5070
    call filter(g:plugs, 'index(g:plugs_disabled, v:key) == -1')

    " Initalize plugin system
    call plug#end()

""" }}}

""" Local leading config, only for prerequisites and will be overwritten {{{
    if filereadable($HOME.'/.vimrc.first')
        source $HOME/.vimrc.first
    endif

""" }}}

""" User interface {{{
    set number                   " line numbers
    set title                    " window title
    set vb t_vb=                 " disable beep and flashing

""" }}}

""" General settings {{{
    set nocompatible             " disable classic Vi compatibility mode

    """ Return to last edit position when opening files {{{
        augroup LastPosition
            autocmd! BufReadPost *
                \ if line("'\"") > 0 && line("'\"") <= line("$") |
                \     exe "normal! g`\"" |
                \ endif
        augroup END

    """ }}}

""" }}}