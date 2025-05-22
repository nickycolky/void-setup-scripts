function update --wraps='xi -Suy && cc && flatpak update -y && flatpak remove --unused -y' --description 'alias update=xi -Suy && cc && flatpak update -y && flatpak remove --unused -y'
  xi -Suy && cc && flatpak update -y && flatpak remove --unused -y $argv
        
end
