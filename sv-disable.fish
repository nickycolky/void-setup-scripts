function sv-disable
    if not count $argv
        echo "Usage: sv-disable <service-name> [more-services...]"
        return 1
    end

    for service_name in $argv
        set -l service_link "/var/service/$service_name"

        if test -L $service_link
            doas rm $service_link
            echo "Service '$service_name' disabled."
        else
            echo "Service '$service_name' is not enabled (no symlink at /var/service/$service_name)."
        end
    end
end
