function confirm_action_n
    while true
        read -l response
        switch (string lower -- $response)
            case '' 'n' 'no'
                return 1
            case 'y' 'yes'
                return 0
            case '*'
                echo "Invalid response. Please try again. (y/N)"
        end
    end
end
