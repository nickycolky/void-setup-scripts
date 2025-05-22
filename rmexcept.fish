function rmexcept
    if test (count $argv) -eq 0
        echo "Usage: rmexcept <filename>"
        return 1
    end

    set filename $argv[1]

    find . -mindepth 1 ! -name $filename -exec doas rm -rf {} +
    ls
end
