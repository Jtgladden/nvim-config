" ~/.config/nvim/syntax/chat.vim
syn match ChatUser /^USER:.*$/ containedin=ALL
syn match ChatAssistant /^ASSISTANT:.*$/ containedin=ALL
hi link ChatUser String
hi link ChatAssistant Constant


