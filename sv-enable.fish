function sv-enable
    if not count $argv
        echo "Usage: sv-enable <service_name> [more_services...]"
        return 1
    end

    for service_name in $argv
        doas ln -s /etc/sv/$service_name /var/service/$service_name
        echo "Service '$service_name' has been enabled."
    end
end
