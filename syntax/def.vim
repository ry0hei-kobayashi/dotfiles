syn include @sh syntax/sh.vim
syn region defScript start="^%labels" end="^$" contains=@sh
syn region defScript start="^%setup" end="^$" contains=@sh
syn region defScript start="^%files" end="^$" contains=@sh
syn region defScript start="^%post" end="^$" contains=@sh
syn region defScript start="^%runscript" end="^$" contains=@sh
syn region defScript start="^%environment" end="^$" contains=@sh

