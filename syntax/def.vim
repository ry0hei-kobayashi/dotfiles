"syn include @sh syntax/sh.vim
"syn region defScript start="^%labels" end="^$" contains=@sh
"syn region defScript start="^%setup" end="^$" contains=@sh
"syn region defScript start="^%files" end="^$" contains=@sh
"syn region defScript start="^%post" end="^$" contains=@sh
"syn region defScript start="^%runscript" end="^$" contains=@sh
"syn region defScript start="^%environment" end="^$" contains=@sh
if exists("b:current_syntax")
  finish
endif

syn include @sh syntax/sh.vim

syn match defSection /^%\(labels\|setup\|files\|post\|runscript\|environment\|test\|help\)\>/

syn match defComment /^#.*$/

syn region defScript start=/^%\(setup\|post\|runscript\|environment\|test\)\>/ end=/^\ze%/me=s-1 keepend contains=@sh,defComment
syn region defScript start=/^%files\>/ end=/^\ze%/me=s-1 keepend contains=defComment
syn region defScript start=/^%labels\>/ end=/^\ze%/me=s-1 keepend contains=defComment

highlight default link defSection Keyword
highlight default link defComment Comment
highlight default link defScript Normal

let b:current_syntax = "def"
