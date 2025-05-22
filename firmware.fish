function firmware --wraps='cd && /usr/lib/firmware && ls' --description 'alias firmware=cd && /usr/lib/firmware && ls'
  cd && /usr/lib/firmware && ls $argv
        
end
