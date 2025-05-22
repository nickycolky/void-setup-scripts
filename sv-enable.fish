function sv-enable
    # Check if a service name is provided
    if test (count $argv) -eq 0
        echo "Usage: sv-enable <service_name>"
        return 1
    end

    # Store the service name in a variable
    set service_name $argv[1]

    # Create the symlink
    doas ln -s /etc/sv/$service_name /var/service/$service_name

    # Provide feedback
    echo "Service '$service_name' has been enabled."
end

