function lookup
    set -l query
    set -l directory_only false
    set -l search_dir

    # Parse arguments
    set -l arg_idx 1
    while test $arg_idx -le (count $argv)
        switch $argv[$arg_idx]
            case "in"
                # 'in' is found, so the next argument is the directory
                set search_dir $argv[(math $arg_idx + 1)]
                break # 'in <dir>' is the end of the options we need to parse for the lookup command
            case "directory" "-d"
                set directory_only true
            case "*"
                if test -z "$query"
                    set query $argv[$arg_idx]
                else
                    echo "Error: Unexpected argument '$argv[$arg_idx]'"
                    echo "Usage: lookup <query> [directory|-d] in <dir>"
                    return 1
                end
        end
        set arg_idx (math $arg_idx + 1)
    end

    if test -z "$query"
        echo "Error: Search query missing."
        echo "Usage: lookup <query> [directory|-d] in <dir>"
        return 1
    end

    if test -z "$search_dir"
        echo "Error: Search directory missing."
        echo "Usage: lookup <query> [directory|-d] in <dir>"
        return 1
    end

    # fd_command construction
    # Removed --max-depth to allow full recursion
    # --hidden to include hidden files and directories
    # --no-ignore to disregard .gitignore and other ignore files
    set -l fd_command "fd  --hidden"

    if $directory_only
        set fd_command "$fd_command --type d"
    else
        set fd_command "$fd_command --type f"
    end

    # Execute the fd command
    eval $fd_command "$query" "$search_dir"
end
