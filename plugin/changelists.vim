echo "Loading changelists.nvim"
function LuaDoItVimL()
endfunction

lua <<EOF
    function lua_do_it_lua()
    end
EOF

lua require 'changelists'.setup()
nmap <M-C-G> :lua Global_lua_function()<CR>
nmap <M-C-L> :lua changelists.local_lua_function()<CR>

lua require("changelists.definestuff").hello()
