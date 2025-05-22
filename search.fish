function search --wraps='sudo xbps-query -Rs' --wraps='doas xbps-query -Rs' --description 'alias search=doas xbps-query -Rs'
  doas xbps-query -Rs $argv
        
end
