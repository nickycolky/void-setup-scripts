function untar
    # Check if a filename argument is provided
    if test -z "$argv[1]"
        echo "Usage: untar <filename>"
        echo "Extracts .tar, .tar.gz, .tgz, .tar.bz2, .tbz2, .tar.xz files."
        return 1
    end

    set -l filename $argv[1]

    # Check if the provided file actually exists
    if not test -f "$filename"
        echo "Error: File '$filename' not found."
        return 1
    end

    # Determine the extraction command based on the file extension
    switch "$filename"
        case '*.tar.xz' '*.txz'
            echo "Extracting '$filename'..."
            tar -xJf "$filename"
        case '*.tar.gz' '*.tgz'
            echo "Extracting '$filename'..."
            tar -xzf "$filename"
        case '*.tar.bz2' '*.tbz2'
            echo "Extracting '$filename'..."
            tar -xjf "$filename"
        case '*.tar'
            echo "Extracting '$filename'..."
            tar -xf "$filename"
        case '*'
            echo "Error: Unsupported file type for '$filename'."
            echo "Supported types: .tar, .tar.gz, .tgz, .tar.bz2, .tbz2, .tar.xz"
            return 1
    end

    # Check the exit status of the last command (tar)
    if test $status -eq 0
        echo "'$filename' successfully extracted."
    else
        echo "Extraction of '$filename' failed."
    end

    return $status
end
