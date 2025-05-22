function apps --wraps='cd && cd /usr/share/applications && eza -a --icons --color' --description 'alias apps=cd && cd /usr/share/applications && eza -a --icons --color'
  cd && cd /usr/share/applications && eza -a --icons --color $argv
        
end
