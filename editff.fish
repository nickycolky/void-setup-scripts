function editff --wraps='sudo nano /home/nic/.config/fastfetch/config.jsonc' --wraps='doas nano /home/nic/.config/fastfetch/config.jsonc' --description 'alias editff=doas nano /home/nic/.config/fastfetch/config.jsonc'
  doas nano /home/nic/.config/fastfetch/config.jsonc $argv
        
end
