function fstab --wraps='doas nano /etc/fstab' --description 'alias fstab=doas nano /etc/fstab'
  doas nano /etc/fstab $argv
        
end
