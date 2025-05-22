function list-installed --wraps='xbps-query -l' --description 'alias list-installed=xbps-query -l'
  xbps-query -l $argv
        
end
