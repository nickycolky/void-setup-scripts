function ls --wraps='eza -a -l --icons --group-directories-first' --description 'alias ls=eza -a -l --icons --group-directories-first'
  eza -a -l --icons --group-directories-first $argv
        
end
