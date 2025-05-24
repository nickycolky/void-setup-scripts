function rmexcept
    # Display usage if no arguments are provided
    if test (count $argv) -eq 0
        echo "Usage: rmexcept [-d | -f | -y]... <file_or_pattern1> [file_or_pattern2]..."
        echo "       -d: Apply the exclusion only to directories (leave files untouched)."
        echo "       -f: Apply the exclusion only to files (leave directories AND their contents untouched)."
        echo "       -y: Assume Yes; skip the confirmation prompt (useful for scripting)."
        return 1
    end

    set -l apply_to_type "" # "" for both, "d" for directories, "f" for files
    set -l assume_yes_flag false # New flag to control confirmation prompt
    set -l patterns
    set -l current_arg_index 1

    # Parse arguments for flags first. Flags can be anywhere.
    while test $current_arg_index -le (count $argv)
        set -l current_arg $argv[$current_arg_index]

        switch "$current_arg"
            # --- Explicitly handle specific combined flags first ---
            case "-fy" "-yf" # -f and -y combined
                if test -n "$apply_to_type" # Check if -d was already set
                    echo "Error: Cannot use -d and -f flags together. '-f' implied in '$current_arg' conflicts with prior '-d'."
                    return 1
                end
                set apply_to_type "f"
                set assume_yes_flag true
            case "-dy" "-yd" # -d and -y combined
                if test -n "$apply_to_type" # Check if -f was already set
                    echo "Error: Cannot use -d and -f flags together. '-d' implied in '$current_arg' conflicts with prior '-f'."
                    return 1
                end
                set apply_to_type "d"
                set assume_yes_flag true
            
            # --- Handle explicit mutually exclusive flag combinations ---
            case "-fd" "-df"
                echo "Error: Cannot use -d and -f flags together."
                return 1

            # --- Handle single flags ---
            case "-d"
                if test -n "$apply_to_type"
                    echo "Error: Cannot use -d and -f flags together."
                    return 1
                end
                set apply_to_type "d"
            case "-f"
                if test -n "$apply_to_type"
                    echo "Error: Cannot use -d and -f flags together."
                    return 1
                end
                set apply_to_type "f"
            case "-y"
                set assume_yes_flag true

            # --- Default: Treat as a pattern to keep ---
            case "*"
                set -a patterns $current_arg
        end
        set current_arg_index (math $current_arg_index + 1)
    end

    # If no patterns are provided after parsing flags, exit
    if test (count $patterns) -eq 0
        echo "Error: No files or patterns specified to keep."
        echo "Usage: rmexcept [-d | -f | -y]... <file_or_pattern1> [file_or_pattern2]..."
        return 1
    end

    # Check if ANY of the specified patterns actually exist and match the type ---
    set -l found_at_least_one_existing_item false
    for pattern in $patterns
        if test -e "$pattern" # Checks if the pattern (which is already shell-expanded) exists
            # Further refine the check based on -d or -f flags
            if test "$apply_to_type" = "d" # If only looking for directories
                if test -d "$pattern"
                    set found_at_least_one_existing_item true
                    break # Found one, no need to check further
                end
            else if test "$apply_to_type" = "f" # If only looking for files
                if test -f "$pattern"
                    set found_at_least_one_existing_item true
                    break # Found one, no need to check further
                end
            else # Default: no -d or -f, consider both files and directories
                # If it exists, and no type filter applies, it counts as a match
                set found_at_least_one_existing_item true
                break # Found one, no need to check further
            end
        end
    end

    # If after checking all patterns, none were found to exist with the correct type, then exit.
    if not $found_at_least_one_existing_item
        echo "Uh oh. The pattern you specified doesn't exist. Deletion aborted."
        return 1 #
    end

    set -l find_command "find . -mindepth 1"

    # Add type and depth filters based on flags
    switch "$apply_to_type"
        case "d"
            set find_command "$find_command -type d" # Only directories, recursive by default
        case "f"
            # -maxdepth 1 to only consider top-level files
            set find_command "$find_command -maxdepth 1 -type f"
        case ""
            # Default: operate on both, recursive by default. No -type or -maxdepth needed.
    end

    # Construct the exclusion logic for find
    for pattern in $patterns
        set find_command "$find_command ! -name '$pattern'"
    end

    if test -n "$apply_to_type"
        set -l type_word (switch "$apply_to_type"; case "d"; echo "directories"; case "f"; echo "files"; end)
        echo "Operating on: $type_word"
    else
        echo "Operating on: files and directories"
    end

    switch "$apply_to_type"
        case "d"
            echo "Directories to be kept: $patterns"
        case "f"
            echo "Files to be kept: $patterns"
        case "" # Default case
            echo "Items to be kept: $patterns"
    end

    # Confirmation Prompt
    if not $assume_yes_flag
        echo -n "Proceed with deletion? (Y/n) "
        read -l confirmation_input # -l reads a single line

        set confirmation_input (string lower "$confirmation_input")

        if test "$confirmation_input" = "n"
            echo "Deletion aborted by user."
            return 0 
        else if test ! "$confirmation_input" = "y" -a ! -z "$confirmation_input"
            # If input is neither 'y' nor empty (which defaults to 'y')
            echo "Invalid input. Deletion aborted."
            return 1 # Return 1 for an error due to invalid input
        end
    end

    # --- Actual Deletion Command ---
    eval "$find_command -print0 | doas xargs -0 rm -rf"

    echo ""
    echo "Contents after rmexcept:"
    ls -F
end
