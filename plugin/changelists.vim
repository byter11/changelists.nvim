echo "Loading changelists.nvim"
function LuaDoItVimL()
endfunction

lua <<EOF
    function lua_do_it_lua()
    end
EOF

lua require 'changelists'.setup()
nmap <M-C-K> :lua Print_changelist()<CR>
