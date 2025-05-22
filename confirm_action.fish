function confirm_action
    while true
        read -l response
        switch (string lower $response)
            case "y" "yes" ""
                return 0  # Yes
            case "n" "no"
                return 1  # No
            case "*"
                echo "Invalid response. Please try again. (Y/n)"
        end
    end
end
