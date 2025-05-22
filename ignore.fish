function ignore --wraps='doas nano /etc/xbps.d/10-ignore.conf' --description 'alias ignore=doas nano /etc/xbps.d/10-ignore.conf'
  doas nano /etc/xbps.d/10-ignore.conf $argv
        
end
