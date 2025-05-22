function del --wraps='sudo xbps-remove' --wraps='doas xbps-remove' --wraps='doas xbps-remove -RoO' --description 'alias del=doas xbps-remove -RoO'
  doas xbps-remove -RoO $argv
        
end
