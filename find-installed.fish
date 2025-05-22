function find-installed --wraps='xbps-query -l | grep' --description 'alias find-installed=xbps-query -l | grep'
  xbps-query -l | grep $argv
        
end
