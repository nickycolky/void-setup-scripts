function update --wraps='xi -Suy && cc && flatpak update -y && flatpak remove --unused -y' --wraps='xi -Suy && cc && flatpak update -y && flatpak remove --unused -y && doas hblock' --description 'alias update=xi -Suy && cc && flatpak update -y && flatpak remove --unused -y && doas hblock'
  xi -Suy && cc && flatpak update -y && flatpak remove --unused -y && doas hblock $argv
        
end
